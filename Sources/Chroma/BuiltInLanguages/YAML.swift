import Foundation

extension BuiltInLanguages {
    static let yaml: LanguageDefinition = {
        let keywords = ["true", "false", "null", "yes", "no", "on", "off"]

        var rules: [TokenRule] = []
        rules.append(try! TokenRule(kind: .comment, pattern: "#[^\\n\\r]*"))
        rules.append(try! TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""))
        rules.append(try! TokenRule(kind: .string, pattern: "'(?:\\\\.|[^'\\\\])*'"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b-?\\d+(?:\\.\\d+)?\\b"))
        rules.append(wordRule(kind: .keyword, words: keywords))
        rules.append(try! TokenRule(kind: .property, pattern: "(?m)^[\\s-]*[A-Za-z0-9_-]+(?=\\s*:)"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[\\[\\]{}(),:]"))

        return LanguageDefinition(id: .yaml, displayName: "YAML", rules: rules)
    }()
}
