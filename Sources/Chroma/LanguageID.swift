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
    static let jsx: Self = "jsx"
    static let typescript: Self = "typescript"
    static let ts: Self = "ts"
    static let tsx: Self = "tsx"
    static let python: Self = "python"
    static let py: Self = "py"
    static let ruby: Self = "ruby"
    static let rb: Self = "rb"
    static let go: Self = "go"
    static let golang: Self = "golang"
    static let rust: Self = "rust"
    static let kotlin: Self = "kotlin"
    static let java: Self = "java"
    static let cpp: Self = "cpp"
    static let cxx: Self = "cxx"
    static let cplusplus: Self = "c++"
    static let csharp: Self = "csharp"
    static let cs: Self = "cs"
    static let php: Self = "php"
    static let dart: Self = "dart"
    static let lua: Self = "lua"
    static let bash: Self = "bash"
    static let sh: Self = "sh"
    static let zsh: Self = "zsh"
    static let sql: Self = "sql"
    static let css: Self = "css"
    static let scss: Self = "scss"
    static let sass: Self = "sass"
    static let less: Self = "less"
    static let html: Self = "html"
    static let xml: Self = "xml"
    static let json: Self = "json"
    static let yaml: Self = "yaml"
    static let yml: Self = "yml"
    static let toml: Self = "toml"
    static let markdown: Self = "markdown"
    static let md: Self = "md"
    static let dockerfile: Self = "dockerfile"
    static let makefile: Self = "makefile"
}
