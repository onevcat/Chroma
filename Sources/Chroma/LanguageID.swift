public struct LanguageID: Hashable, RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }

    public var description: String { rawValue }
}

public extension LanguageID {
    static let swift: Self = "swift"
    static let objectiveC: Self = "objective-c"
    static let objc: Self = "objc"
    static let c: Self = "c"
    static let javascript: Self = "javascript"
    static let js: Self = "js"
    static let typescript: Self = "typescript"
    static let ts: Self = "ts"
    static let python: Self = "python"
    static let py: Self = "py"
    static let ruby: Self = "ruby"
    static let rb: Self = "rb"
    static let go: Self = "go"
    static let golang: Self = "golang"
    static let rust: Self = "rust"
    static let kotlin: Self = "kotlin"
    static let csharp: Self = "csharp"
    static let cs: Self = "cs"
}
