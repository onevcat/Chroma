import Foundation

public extension TokenRule {
    /// Creates a word-boundary rule like `\\b(?:a|b|c)\\b`.
    static func words(_ words: [String], kind: TokenKind) throws -> TokenRule {
        let alternation = words
            .map(NSRegularExpression.escapedPattern(for:))
            .sorted { $0.count > $1.count }
            .joined(separator: "|")
        return try TokenRule(kind: kind, pattern: "\\b(?:\(alternation))\\b", isWordList: true)
    }
}
