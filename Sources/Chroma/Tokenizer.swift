import Foundation

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

