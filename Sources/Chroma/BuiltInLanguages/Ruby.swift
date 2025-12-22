import Foundation

extension BuiltInLanguages {
    static let ruby: LanguageDefinition = {
        let keywords = [
            "BEGIN", "END", "alias", "and", "begin", "break", "case", "class", "def", "defined?", "do", "else",
            "elsif", "end", "ensure", "false", "for", "if", "in", "module", "next", "nil", "not", "or", "redo",
            "rescue", "retry", "return", "self", "super", "then", "true", "undef", "unless", "until", "when",
            "while", "yield",
        ]
        let types = [
            "String", "Integer", "Float", "Array", "Hash", "Symbol", "Object", "Module", "Class",
        ]

        var rules: [TokenRule] = []
        rules.append(try! TokenRule(kind: .comment, pattern: "#[^\\n\\r]*"))
        rules.append(try! TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""))
        rules.append(try! TokenRule(kind: .string, pattern: "'(?:\\\\.|[^'\\\\])*'"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b0x[0-9a-fA-F]+\\b"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b\\d+(?:\\.\\d+)?\\b"))
        rules.append(wordRule(kind: .keyword, words: keywords))
        rules.append(wordRule(kind: .type, words: types))
        rules.append(try! TokenRule(kind: .function, pattern: "\\b[A-Za-z_][A-Za-z0-9_]*\\b(?=\\s*\\()"))
        rules.append(try! TokenRule(kind: .operator, pattern: "[+\\-*/%&|^!~=<>?:]+"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[\\[\\]{}().,;:]"))

        let fastPath = LanguageFastPath(keywords: keywords, types: types)
        return LanguageDefinition(id: .ruby, displayName: "Ruby", rules: rules, fastPath: fastPath)
    }()
}
