import Foundation

enum BuiltInLanguages {
    static let all: [LanguageDefinition] = [
        swift,
        objectiveC,
        alias(objectiveC, id: .objc),
        c,
        cpp,
        alias(cpp, id: .cplusplus, displayName: "C++"),
        alias(cpp, id: .cxx, displayName: "C++"),
        javascript,
        jsx,
        alias(javascript, id: .js),
        typescript,
        tsx,
        alias(typescript, id: .ts),
        python,
        alias(python, id: .py),
        ruby,
        alias(ruby, id: .rb),
        go,
        alias(go, id: .golang),
        rust,
        kotlin,
        java,
        csharp,
        alias(csharp, id: .cs),
        php,
        dart,
        lua,
        bash,
        alias(bash, id: .sh, displayName: "Shell"),
        alias(bash, id: .zsh, displayName: "Shell"),
        sql,
        css,
        scss,
        sass,
        less,
        html,
        xml,
        json,
        yaml,
        alias(yaml, id: .yml),
        toml,
        markdown,
        alias(markdown, id: .md),
        dockerfile,
        makefile,
    ]

    static func wordAlternation(_ words: [String]) -> String {
        words
            .map(NSRegularExpression.escapedPattern(for:))
            .sorted { $0.count > $1.count }
            .joined(separator: "|")
    }

    static func wordRule(kind: TokenKind, words: [String]) -> TokenRule {
        let alternation = wordAlternation(words)
        return try! TokenRule(kind: kind, pattern: "\\b(?:\(alternation))\\b", isWordList: true)
    }

    static func cStyleRules(
        keywords: [String],
        builtInTypes: [String],
        strings: [String],
        additionalRules: [TokenRule] = []
    ) -> [TokenRule] {
        var rules: [TokenRule] = []

        // Comments
        rules.append(try! TokenRule(kind: .comment, pattern: "//[^\\n\\r]*"))
        rules.append(try! TokenRule(kind: .comment, pattern: "/\\*[\\s\\S]*?\\*/"))

        // Strings
        for pattern in strings {
            rules.append(try! TokenRule(kind: .string, pattern: pattern))
        }

        // Numbers
        rules.append(try! TokenRule(kind: .number, pattern: "\\b0x[0-9a-fA-F]+\\b"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b\\d+(?:\\.\\d+)?\\b"))

        // Keywords / Types
        rules.append(wordRule(kind: .keyword, words: keywords))
        rules.append(wordRule(kind: .type, words: builtInTypes))

        // Identifiers (heuristics)
        rules.append(try! TokenRule(kind: .function, pattern: "\\b[A-Za-z_][A-Za-z0-9_]*\\b(?=\\s*\\()"))
        rules.append(try! TokenRule(kind: .property, pattern: "\\.[A-Za-z_][A-Za-z0-9_]*\\b"))

        // Operators / punctuation
        rules.append(try! TokenRule(kind: .operator, pattern: "[+\\-*/%&|^!~=<>?:]+"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[\\[\\]{}().,;]"))

        rules.append(contentsOf: additionalRules)
        return rules
    }

    static func markupRules(additionalRules: [TokenRule] = []) -> [TokenRule] {
        var rules: [TokenRule] = []

        rules.append(try! TokenRule(kind: .comment, pattern: "<!--[\\s\\S]*?-->"))
        rules.append(try! TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""))
        rules.append(try! TokenRule(kind: .string, pattern: "'(?:\\\\.|[^'\\\\])*'"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b\\d+(?:\\.\\d+)?\\b"))
        rules.append(try! TokenRule(kind: .keyword, pattern: "</?[A-Za-z][A-Za-z0-9:_-]*"))
        rules.append(try! TokenRule(kind: .property, pattern: "\\b[A-Za-z_:][A-Za-z0-9:._-]*\\b(?=\\s*=)"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[<>/=]"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[\\[\\]{}().,;:]"))

        rules.append(contentsOf: additionalRules)
        return rules
    }

    static func cssRules(additionalRules: [TokenRule] = []) -> [TokenRule] {
        var rules: [TokenRule] = []

        rules.append(try! TokenRule(kind: .comment, pattern: "/\\*[\\s\\S]*?\\*/"))
        rules.append(try! TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""))
        rules.append(try! TokenRule(kind: .string, pattern: "'(?:\\\\.|[^'\\\\])*'"))
        rules.append(try! TokenRule(kind: .number, pattern: "#[0-9a-fA-F]{3,8}\\b"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b\\d+(?:\\.\\d+)?\\b"))
        rules.append(try! TokenRule(kind: .keyword, pattern: "@[A-Za-z_-]+"))
        rules.append(try! TokenRule(kind: .property, pattern: "\\b[A-Za-z_-]+(?=\\s*:)"))
        rules.append(try! TokenRule(kind: .type, pattern: "[.#][A-Za-z_-][A-Za-z0-9_-]*"))
        rules.append(try! TokenRule(kind: .operator, pattern: "[+\\-*/%&|^!~=<>?:]+"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[\\[\\]{}().,;:]"))

        rules.append(contentsOf: additionalRules)
        return rules
    }

    private static func alias(_ base: LanguageDefinition, id: LanguageID, displayName: String? = nil) -> LanguageDefinition {
        var lang = base
        lang.id = id
        if let displayName {
            lang.displayName = displayName
        }
        return lang
    }
}
