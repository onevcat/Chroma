import Foundation

extension BuiltInLanguages {
    static let markdown: LanguageDefinition = {
        var rules: [TokenRule] = []

        rules.append(try! TokenRule(kind: .keyword, pattern: "(?m)^\\s*```.*$"))
        rules.append(try! TokenRule(kind: .keyword, pattern: "(?m)^\\s*~~~.*$"))
        rules.append(try! TokenRule(kind: .keyword, pattern: "(?m)^#{1,6}\\s+.*$"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "(?m)^\\s*>\\s+"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "(?m)^\\s*(?:[-*+]\\s+|\\d+\\.\\s+)"))
        rules.append(try! TokenRule(kind: .string, pattern: "`[^`]+`"))
        rules.append(try! TokenRule(kind: .keyword, pattern: "\\*\\*[^*]+\\*\\*"))
        rules.append(try! TokenRule(kind: .keyword, pattern: "__[^_]+__"))
        rules.append(try! TokenRule(kind: .keyword, pattern: "\\*[^*]+\\*"))
        rules.append(try! TokenRule(kind: .keyword, pattern: "_[^_]+_"))
        rules.append(try! TokenRule(kind: .string, pattern: "\\[[^\\]]+\\]\\([^\\)]+\\)"))

        return LanguageDefinition(id: .markdown, displayName: "Markdown", rules: rules)
    }()
}
