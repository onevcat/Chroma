import Foundation

@_spi(Benchmarking)
public struct TokenizerMetrics: Equatable {
    public var iterations: Int
    public var rulesEvaluated: Int
    public var matchesFound: Int
    public var bestMatchUpdates: Int
    public var fallbackComposed: Int
    public var tokensEmitted: Int
    public var coalescedTokens: Int
    public var coalescedMerges: Int

    public init() {
        self.iterations = 0
        self.rulesEvaluated = 0
        self.matchesFound = 0
        self.bestMatchUpdates = 0
        self.fallbackComposed = 0
        self.tokensEmitted = 0
        self.coalescedTokens = 0
        self.coalescedMerges = 0
    }

    public mutating func reset() {
        self = .init()
    }
}

public struct Token: Equatable {
    public var kind: TokenKind
    public var range: NSRange

    public init(kind: TokenKind, range: NSRange) {
        self.kind = kind
        self.range = range
    }
}

final class RegexTokenizer {
    private let rules: [TokenRule]

    init(rules: [TokenRule]) {
        self.rules = rules
    }

    func tokenize(_ code: String) -> [Token] {
        var tokens: [Token] = []
        scan(code) { token in
            tokens.append(token)
        }
        return tokens
    }

    func tokenize(_ code: String, metrics: inout TokenizerMetrics) -> [Token] {
        metrics.reset()

        var tokens: [Token] = []
        withUnsafeMutablePointer(to: &metrics) { pointer in
            scan(code, metrics: pointer) { token in
                tokens.append(token)
            }
        }
        return tokens
    }

    func scan(_ code: String, emit: (Token) -> Void) {
        scan(code, metrics: nil, emit: emit)
    }

    private func scan(
        _ code: String,
        metrics: UnsafeMutablePointer<TokenizerMetrics>?,
        emit: (Token) -> Void
    ) {
        let isASCII = code.unicodeScalars.allSatisfy { $0.isASCII }
        let ns = code as NSString
        let length = ns.length

        var pending: Token?

        func flushPending() {
            guard let current = pending else { return }
            emit(current)
            metrics?.pointee.coalescedTokens += 1
            pending = nil
        }

        func appendToken(_ token: Token) {
            metrics?.pointee.tokensEmitted += 1

            if var current = pending,
               current.kind == token.kind,
               current.range.location + current.range.length == token.range.location {
                current.range.length += token.range.length
                pending = current
                metrics?.pointee.coalescedMerges += 1
                return
            }

            if pending != nil {
                flushPending()
            }
            pending = token
        }

        func recordFallbackComposed(in range: NSRange) {
            guard let metrics = metrics, range.length > 0 else { return }

            var index = range.location
            let end = range.location + range.length
            while index < end {
                let composed = ns.rangeOfComposedCharacterSequence(at: index)
                metrics.pointee.fallbackComposed += 1
                index = composed.location + composed.length
            }
        }

        func appendPlainASCII(_ range: NSRange) {
            guard range.length > 0 else { return }
            appendToken(Token(kind: .plain, range: range))
            metrics?.pointee.fallbackComposed += range.length
        }

        var cachedMatches: [NSTextCheckingResult?] = Array(repeating: nil, count: rules.count)
        var cachedSearchLocations: [Int] = Array(repeating: 0, count: rules.count)

        func updateMatch(for index: Int, from location: Int) {
            let searchRange = NSRange(location: location, length: length - location)
            cachedSearchLocations[index] = location
            metrics?.pointee.rulesEvaluated += 1
            guard let match = rules[index].regex.firstMatch(in: code, options: [], range: searchRange) else {
                cachedMatches[index] = nil
                return
            }
            cachedMatches[index] = match
            metrics?.pointee.matchesFound += 1
        }

        var location = 0
        if length > 0 {
            for index in rules.indices {
                updateMatch(for: index, from: location)
            }
        }

        while location < length {
            metrics?.pointee.iterations += 1

            for index in rules.indices {
                if let match = cachedMatches[index] {
                    if match.range.location < location {
                        updateMatch(for: index, from: location)
                    }
                } else if cachedSearchLocations[index] < location {
                    continue
                }
            }

            var earliestLocation: Int?
            for match in cachedMatches {
                guard let match, match.range.length > 0 else { continue }
                let matchLocation = match.range.location
                if earliestLocation == nil || matchLocation < earliestLocation! {
                    earliestLocation = matchLocation
                }
            }

            guard let earliestLocation else {
                let remainingRange = NSRange(location: location, length: length - location)
                if remainingRange.length > 0 {
                    if isASCII {
                        appendPlainASCII(remainingRange)
                    } else {
                        let safeRange = ns.rangeOfComposedCharacterSequences(for: remainingRange)
                        if safeRange.length > 0 {
                            appendToken(Token(kind: .plain, range: safeRange))
                            recordFallbackComposed(in: safeRange)
                        }
                    }
                }
                break
            }

            if earliestLocation > location {
                let plainRange = NSRange(location: location, length: earliestLocation - location)
                if isASCII {
                    appendPlainASCII(plainRange)
                    location += plainRange.length
                    continue
                } else {
                    let safeRange = ns.rangeOfComposedCharacterSequences(for: plainRange)
                    if safeRange.length > 0 {
                        appendToken(Token(kind: .plain, range: safeRange))
                        recordFallbackComposed(in: safeRange)
                        location = safeRange.location + safeRange.length
                        continue
                    }

                    let composed = ns.rangeOfComposedCharacterSequence(at: location)
                    appendToken(Token(kind: .plain, range: composed))
                    recordFallbackComposed(in: composed)
                    location += composed.length
                    continue
                }
            }

            var bestMatch: NSTextCheckingResult?
            var bestRuleIndex: Int?
            for (index, match) in cachedMatches.enumerated() {
                guard let match, match.range.location == location, match.range.length > 0 else { continue }
                if bestMatch == nil || match.range.length > bestMatch!.range.length {
                    bestMatch = match
                    bestRuleIndex = index
                    metrics?.pointee.bestMatchUpdates += 1
                }
            }

            if let bestMatch, let bestRuleIndex {
                appendToken(Token(kind: rules[bestRuleIndex].kind, range: bestMatch.range))
                location += bestMatch.range.length
                continue
            }

            if isASCII {
                appendPlainASCII(NSRange(location: location, length: 1))
                location += 1
            } else {
                let composed = ns.rangeOfComposedCharacterSequence(at: location)
                appendToken(Token(kind: .plain, range: composed))
                recordFallbackComposed(in: composed)
                location += composed.length
            }
        }

        flushPending()
    }
}
