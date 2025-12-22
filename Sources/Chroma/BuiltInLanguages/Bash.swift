import Foundation

extension BuiltInLanguages {
    static let bash: LanguageDefinition = {
        let keywords = [
            "if", "then", "fi", "for", "do", "done", "while", "case", "esac", "in", "function", "select",
            "until", "elif", "else", "export", "return", "local", "readonly",
        ]

        var rules: [TokenRule] = []
        rules.append(try! TokenRule(kind: .comment, pattern: "#[^\\n\\r]*"))
        rules.append(try! TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""))
        rules.append(try! TokenRule(kind: .string, pattern: "'(?:\\\\.|[^'\\\\])*'"))
        rules.append(try! TokenRule(kind: .string, pattern: "`[^`]*`"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b\\d+(?:\\.\\d+)?\\b"))
        rules.append(wordRule(kind: .keyword, words: keywords))
        rules.append(try! TokenRule(kind: .property, pattern: "\\$\\{[^}]+\\}"))
        rules.append(try! TokenRule(kind: .property, pattern: "\\$[A-Za-z_][A-Za-z0-9_]*"))
        rules.append(try! TokenRule(kind: .operator, pattern: "[+\\-*/%&|^!~=<>?:]+"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[\\[\\]{}().,;]"))

        let fastPath = LanguageFastPath(keywords: keywords, types: [])
        return LanguageDefinition(id: .bash, displayName: "Bash", rules: rules, fastPath: fastPath)
    }()
}
