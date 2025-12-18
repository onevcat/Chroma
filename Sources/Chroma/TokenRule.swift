import Foundation

public struct TokenRule {
    public var kind: TokenKind
    public var regex: NSRegularExpression

    public init(kind: TokenKind, regex: NSRegularExpression) {
        self.kind = kind
        self.regex = regex
    }

    public init(
        kind: TokenKind,
        pattern: String,
        options: NSRegularExpression.Options = []
    ) throws {
        self.init(kind: kind, regex: try NSRegularExpression(pattern: pattern, options: options))
    }
}

