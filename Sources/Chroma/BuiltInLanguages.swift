import Foundation

enum BuiltInLanguages {
    static let all: [LanguageDefinition] = [
        swift,
        objectiveC,
        alias(objectiveC, id: .objc),
        c,
        javascript,
        alias(javascript, id: .js),
        typescript,
        alias(typescript, id: .ts),
        python,
        alias(python, id: .py),
        ruby,
        alias(ruby, id: .rb),
        go,
        alias(go, id: .golang),
        rust,
        kotlin,
        csharp,
        alias(csharp, id: .cs),
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

    private static func alias(_ base: LanguageDefinition, id: LanguageID, displayName: String? = nil) -> LanguageDefinition {
        var lang = base
        lang.id = id
        if let displayName {
            lang.displayName = displayName
        }
        return lang
    }
}
