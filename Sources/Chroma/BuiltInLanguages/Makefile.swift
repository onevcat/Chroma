import Foundation

extension BuiltInLanguages {
    static let makefile: LanguageDefinition = {
        var rules: [TokenRule] = []
        rules.append(try! TokenRule(kind: .comment, pattern: "#[^\\n\\r]*"))
        rules.append(try! TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""))
        rules.append(try! TokenRule(kind: .string, pattern: "'(?:\\\\.|[^'\\\\])*'"))
        rules.append(try! TokenRule(kind: .keyword, pattern: "(?m)^[A-Za-z0-9_.-]+(?=\\s*:)"))
        rules.append(try! TokenRule(kind: .property, pattern: "\\$\\([A-Za-z0-9_.-]+\\)"))
        rules.append(try! TokenRule(kind: .property, pattern: "\\$\\{[^}]+\\}"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b\\d+(?:\\.\\d+)?\\b"))
        rules.append(try! TokenRule(kind: .operator, pattern: "[+\\-*/%&|^!~=<>?:]+"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[\\[\\]{}().,;:]"))

        return LanguageDefinition(id: .makefile, displayName: "Makefile", rules: rules)
    }()
}
