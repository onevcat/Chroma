import Foundation

extension BuiltInLanguages {
    static let json: LanguageDefinition = {
        let keywords = ["true", "false", "null"]

        var rules: [TokenRule] = []
        rules.append(try! TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b-?\\d+(?:\\.\\d+)?\\b"))
        rules.append(wordRule(kind: .keyword, words: keywords))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[\\[\\]{}(),:]"))

        return LanguageDefinition(id: .json, displayName: "JSON", rules: rules)
    }()
}
