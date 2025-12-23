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
    private let fastPath: LanguageFastPath?
    private let fastPathSkipRules: [Bool]

    init(rules: [TokenRule], fastPath: LanguageFastPath? = nil) {
        self.rules = rules
        self.fastPath = fastPath
        self.fastPathSkipRules = RegexTokenizer.makeFastPathSkipRules(rules: rules, fastPath: fastPath)
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
        let fastPath = fastPath
        let useFastPath = isASCII && (fastPath?.isEmpty == false)
        let ns = code as NSString
        let length = ns.length

        if isASCII {
            if code.utf16.withContiguousStorageIfAvailable({ buffer in
                let source = UTF16BufferSource(buffer: buffer)
                scanCore(
                    code,
                    metrics: metrics,
                    emit: emit,
                    ns: ns,
                    length: length,
                    fastPath: fastPath,
                    isASCII: isASCII,
                    useFastPath: useFastPath,
                    source: source
                )
                return true
            }) == true {
                return
            }
        }

        let source = NSStringSource(ns: ns)
        scanCore(
            code,
            metrics: metrics,
            emit: emit,
            ns: ns,
            length: length,
            fastPath: fastPath,
            isASCII: isASCII,
            useFastPath: useFastPath,
            source: source
        )
    }

    private func scanCore<Source: CharacterSource>(
        _ code: String,
        metrics: UnsafeMutablePointer<TokenizerMetrics>?,
        emit: (Token) -> Void,
        ns: NSString,
        length: Int,
        fastPath: LanguageFastPath?,
        isASCII: Bool,
        useFastPath: Bool,
        source: Source
    ) {

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

        func isIdentStart(_ value: unichar) -> Bool {
            (value >= 65 && value <= 90) || (value >= 97 && value <= 122) || value == 95
        }

        func isIdentContinue(_ value: unichar) -> Bool {
            isIdentStart(value) || (value >= 48 && value <= 57)
        }

        func isOperatorChar(_ value: unichar) -> Bool {
            switch value {
            case 43, 45, 42, 47, 37, 38, 124, 94, 33, 126, 61, 60, 62, 63, 58:
                return true
            default:
                return false
            }
        }

        func isPunctuationChar(_ value: unichar) -> Bool {
            switch value {
            case 91, 93, 123, 125, 40, 41, 46, 44, 59:
                return true
            default:
                return false
            }
        }

        func fastPathKeywordMatch(at location: Int, end: Int, fastPath: LanguageFastPath) -> (TokenKind, NSRange)? {
            guard location < end else { return nil }
            let value = source.charAt(location)
            guard isIdentStart(value) else { return nil }

            var index = location + 1
            while index < end && isIdentContinue(source.charAt(index)) {
                index += 1
            }
            let wordRange = NSRange(location: location, length: index - location)
            let word = ns.substring(with: wordRange)
            guard let kind = fastPath.kind(for: word) else { return nil }
            return (kind, wordRange)
        }

        func appendPlainWithFastPath(_ range: NSRange, fastPath: LanguageFastPath) {
            guard range.length > 0 else { return }

            let end = range.location + range.length
            var index = range.location

            while index < end {
                let value = source.charAt(index)
                if isIdentStart(value) {
                    let start = index
                    index += 1
                    while index < end && isIdentContinue(source.charAt(index)) {
                        index += 1
                    }
                    let wordRange = NSRange(location: start, length: index - start)
                    let word = ns.substring(with: wordRange)
                    if let kind = fastPath.kind(for: word) {
                        appendToken(Token(kind: kind, range: wordRange))
                    } else {
                        appendPlainASCII(wordRange)
                    }
                } else if isOperatorChar(value) {
                    let start = index
                    index += 1
                    while index < end && isOperatorChar(source.charAt(index)) {
                        index += 1
                    }
                    let opRange = NSRange(location: start, length: index - start)
                    appendToken(Token(kind: .operator, range: opRange))
                } else if isPunctuationChar(value) {
                    let punctuationRange = NSRange(location: index, length: 1)
                    appendToken(Token(kind: .punctuation, range: punctuationRange))
                    index += 1
                } else {
                    let start = index
                    index += 1
                    while index < end &&
                            !isIdentStart(source.charAt(index)) &&
                            !isOperatorChar(source.charAt(index)) &&
                            !isPunctuationChar(source.charAt(index)) {
                        index += 1
                    }
                    let plainRange = NSRange(location: start, length: index - start)
                    appendPlainASCII(plainRange)
                }
            }
        }

        var cachedMatches: [NSTextCheckingResult?] = Array(repeating: nil, count: rules.count)
        var cachedSearchLocations: [Int] = Array(repeating: 0, count: rules.count)

        func updateMatch(for index: Int, from location: Int) {
            let searchRange = NSRange(location: location, length: length - location)
            cachedSearchLocations[index] = location
            if useFastPath && rules[index].isWordList {
                cachedMatches[index] = nil
                cachedSearchLocations[index] = location
                return
            }
            if useFastPath && fastPathSkipRules[index] {
                cachedMatches[index] = nil
                cachedSearchLocations[index] = location
                return
            }
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

            if useFastPath, let fastPath,
               let (kind, range) = fastPathKeywordMatch(at: location, end: length, fastPath: fastPath) {
                appendToken(Token(kind: kind, range: range))
                location += range.length
                continue
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
                    if useFastPath, let fastPath {
                        appendPlainWithFastPath(remainingRange, fastPath: fastPath)
                    } else if isASCII {
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
                if useFastPath, let fastPath {
                    appendPlainWithFastPath(plainRange, fastPath: fastPath)
                    location += plainRange.length
                    continue
                } else if isASCII {
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

private protocol CharacterSource {
    @inline(__always)
    func charAt(_ index: Int) -> unichar
}

private struct NSStringSource: CharacterSource {
    let ns: NSString

    @inline(__always)
    func charAt(_ index: Int) -> unichar {
        ns.character(at: index)
    }
}

private struct UTF16BufferSource: CharacterSource {
    let buffer: UnsafeBufferPointer<UInt16>

    @inline(__always)
    func charAt(_ index: Int) -> unichar {
        unichar(buffer[index])
    }
}

private extension RegexTokenizer {
    static let operatorPattern = "[+\\-*/%&|^!~=<>?:]+"
    static let punctuationPattern = "[\\[\\]{}().,;]"

    static func makeFastPathSkipRules(rules: [TokenRule], fastPath: LanguageFastPath?) -> [Bool] {
        var result = Array(repeating: false, count: rules.count)
        guard let fastPath, !fastPath.isEmpty else { return result }

        var hasCustomPunctuation = false
        for rule in rules where rule.kind == .punctuation {
            if rule.regex.pattern != punctuationPattern {
                hasCustomPunctuation = true
                break
            }
        }

        for (index, rule) in rules.enumerated() {
            switch rule.kind {
            case .operator:
                if rule.regex.pattern == operatorPattern && !hasCustomPunctuation {
                    result[index] = true
                }
            case .punctuation:
                if rule.regex.pattern == punctuationPattern {
                    result[index] = true
                }
            default:
                break
            }
        }
        return result
    }
}
