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

struct Token {
    var kind: TokenKind
    var range: NSRange
}

final class RegexTokenizer {
    private let rules: [TokenRule]

    init(rules: [TokenRule]) {
        self.rules = rules
    }

    func tokenize(_ code: String) -> [Token] {
        let ns = code as NSString
        let length = ns.length

        var tokens: [Token] = []
        tokens.reserveCapacity(max(16, length / 4))

        var location = 0
        while location < length {
            var bestMatch: NSTextCheckingResult?
            var bestRuleIndex: Int?

            let searchRange = NSRange(location: location, length: length - location)
            for (index, rule) in rules.enumerated() {
                guard let match = rule.regex.firstMatch(in: code, options: [.anchored], range: searchRange) else {
                    continue
                }
                if bestMatch == nil || match.range.length > bestMatch!.range.length {
                    bestMatch = match
                    bestRuleIndex = index
                }
            }

            if let bestMatch, let bestRuleIndex {
                tokens.append(Token(kind: rules[bestRuleIndex].kind, range: bestMatch.range))
                location += bestMatch.range.length
                continue
            }

            let composed = ns.rangeOfComposedCharacterSequence(at: location)
            tokens.append(Token(kind: .plain, range: composed))
            location += composed.length
        }

        return coalescingAdjacentTokens(tokens)
    }

    func tokenize(_ code: String, metrics: inout TokenizerMetrics) -> [Token] {
        metrics.reset()

        let ns = code as NSString
        let length = ns.length

        var tokens: [Token] = []
        tokens.reserveCapacity(max(16, length / 4))

        var location = 0
        while location < length {
            metrics.iterations += 1

            var bestMatch: NSTextCheckingResult?
            var bestRuleIndex: Int?

            let searchRange = NSRange(location: location, length: length - location)
            for (index, rule) in rules.enumerated() {
                metrics.rulesEvaluated += 1
                guard let match = rule.regex.firstMatch(in: code, options: [.anchored], range: searchRange) else {
                    continue
                }
                metrics.matchesFound += 1
                if bestMatch == nil || match.range.length > bestMatch!.range.length {
                    bestMatch = match
                    bestRuleIndex = index
                    metrics.bestMatchUpdates += 1
                }
            }

            if let bestMatch, let bestRuleIndex {
                tokens.append(Token(kind: rules[bestRuleIndex].kind, range: bestMatch.range))
                location += bestMatch.range.length
                continue
            }

            let composed = ns.rangeOfComposedCharacterSequence(at: location)
            tokens.append(Token(kind: .plain, range: composed))
            metrics.fallbackComposed += 1
            location += composed.length
        }

        let result = coalescingAdjacentTokens(tokens)
        metrics.tokensEmitted = tokens.count
        metrics.coalescedTokens = result.count
        metrics.coalescedMerges = tokens.count - result.count
        return result
    }

    private func coalescingAdjacentTokens(_ tokens: [Token]) -> [Token] {
        guard var current = tokens.first else { return [] }

        var result: [Token] = []
        result.reserveCapacity(tokens.count)

        for token in tokens.dropFirst() {
            if token.kind == current.kind && current.range.location + current.range.length == token.range.location {
                current.range.length += token.range.length
            } else {
                result.append(current)
                current = token
            }
        }
        result.append(current)

        return result
    }
}
