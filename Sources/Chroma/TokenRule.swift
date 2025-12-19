import Foundation

public struct TokenRule {
    public var kind: TokenKind
    public var regex: NSRegularExpression
    public var isWordList: Bool

    public init(kind: TokenKind, regex: NSRegularExpression, isWordList: Bool = false) {
        self.kind = kind
        self.regex = regex
        self.isWordList = isWordList
    }

    public init(
        kind: TokenKind,
        pattern: String,
        options: NSRegularExpression.Options = [],
        isWordList: Bool = false
    ) throws {
        self.init(kind: kind, regex: try NSRegularExpression(pattern: pattern, options: options), isWordList: isWordList)
    }
}
