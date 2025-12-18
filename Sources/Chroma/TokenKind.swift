public struct TokenKind: Hashable, RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }

    public var description: String { rawValue }
}

public extension TokenKind {
    static let plain: Self = "plain"
    static let keyword: Self = "keyword"
    static let type: Self = "type"
    static let number: Self = "number"
    static let string: Self = "string"
    static let comment: Self = "comment"
    static let function: Self = "function"
    static let property: Self = "property"
    static let punctuation: Self = "punctuation"
    static let `operator`: Self = "operator"
}

