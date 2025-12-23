import Foundation

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

public extension LanguageID {
    /// Infers a language from a file name or returns `nil` when no match is found.
    static func fromFileName(_ fileName: String) -> LanguageID? {
        let trimmed = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let name = trimmed
            .split(whereSeparator: { $0 == "/" || $0 == "\\" })
            .last
            .map(String.init) ?? trimmed

        let lowercased = name.lowercased()
        if let direct = fileNameLookup[lowercased] {
            return direct
        }
        if lowercased.hasPrefix("dockerfile.") {
            return .dockerfile
        }
        if lowercased.hasPrefix("makefile.") {
            return .makefile
        }

        guard let ext = fileExtension(from: lowercased),
              let language = extensionLookup[ext] else {
            return nil
        }
        return language
    }

    /// Infers a language from a file path or returns `nil` when no match is found.
    static func fromFilePath(_ path: String) -> LanguageID? {
        fromFileName(URL(fileURLWithPath: path).lastPathComponent)
    }

    /// Infers a language from a file URL or returns `nil` when no match is found.
    static func fromURL(_ url: URL) -> LanguageID? {
        fromFileName(url.lastPathComponent)
    }
}

private extension LanguageID {
    static let fileNameLookup: [String: LanguageID] = [
        "makefile": .makefile,
        "gnumakefile": .makefile,
        "dockerfile": .dockerfile,
    ]

    static let extensionLookup: [String: LanguageID] = [
        "swift": .swift,
        "m": .objectiveC,
        "mm": .objectiveC,
        "c": .c,
        "cpp": .cpp,
        "cxx": .cxx,
        "cc": .cpp,
        "c++": .cplusplus,
        "hpp": .cpp,
        "hxx": .cxx,
        "hh": .cpp,
        "js": .js,
        "jsx": .jsx,
        "ts": .ts,
        "tsx": .tsx,
        "py": .py,
        "rb": .rb,
        "go": .go,
        "rs": .rust,
        "kt": .kotlin,
        "kts": .kotlin,
        "java": .java,
        "cs": .cs,
        "php": .php,
        "dart": .dart,
        "lua": .lua,
        "sh": .sh,
        "bash": .bash,
        "zsh": .zsh,
        "sql": .sql,
        "css": .css,
        "scss": .scss,
        "sass": .sass,
        "less": .less,
        "html": .html,
        "htm": .html,
        "xml": .xml,
        "json": .json,
        "yaml": .yaml,
        "yml": .yml,
        "toml": .toml,
        "md": .md,
        "markdown": .markdown,
        "dockerfile": .dockerfile,
        "mk": .makefile,
    ]

    static func fileExtension(from name: String) -> String? {
        guard let dotIndex = name.lastIndex(of: ".") else { return nil }
        let nextIndex = name.index(after: dotIndex)
        guard nextIndex < name.endIndex else { return nil }
        return String(name[nextIndex...])
    }
}
