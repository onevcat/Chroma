import Foundation

extension BuiltInLanguages {
    static let toml: LanguageDefinition = {
        let keywords = ["true", "false"]

        var rules: [TokenRule] = []
        rules.append(try! TokenRule(kind: .comment, pattern: "#[^\\n\\r]*"))
        rules.append(try! TokenRule(kind: .string, pattern: "\"\"\"[\\s\\S]*?\"\"\""))
        rules.append(try! TokenRule(kind: .string, pattern: "'''[\\s\\S]*?'''"))
        rules.append(try! TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""))
        rules.append(try! TokenRule(kind: .string, pattern: "'(?:\\\\.|[^'\\\\])*'"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b-?\\d+(?:\\.\\d+)?\\b"))
        rules.append(wordRule(kind: .keyword, words: keywords))
        rules.append(try! TokenRule(kind: .property, pattern: "(?m)^[A-Za-z0-9_.-]+(?=\\s*=)"))
        rules.append(try! TokenRule(kind: .operator, pattern: "[+\\-*/%&|^!~=<>?:]+"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[\\[\\]{}(),;]"))

        return LanguageDefinition(id: .toml, displayName: "TOML", rules: rules)
    }()
}
