import Foundation

extension BuiltInLanguages {
    static let python: LanguageDefinition = {
        let keywords = [
            "and", "as", "assert", "async", "await", "break", "class", "continue", "def", "del", "elif", "else",
            "except", "False", "finally", "for", "from", "global", "if", "import", "in", "is", "lambda", "None",
            "nonlocal", "not", "or", "pass", "raise", "return", "True", "try", "while", "with", "yield",
        ]
        let types = [
            "int", "float", "str", "bytes", "bool", "list", "dict", "set", "tuple", "object", "type",
        ]

        var rules: [TokenRule] = []
        rules.append(try! TokenRule(kind: .comment, pattern: "#[^\\n\\r]*"))
        rules.append(try! TokenRule(kind: .string, pattern: "\"\"\"[\\s\\S]*?\"\"\""))
        rules.append(try! TokenRule(kind: .string, pattern: "'''[\\s\\S]*?'''"))
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
        return LanguageDefinition(id: .python, displayName: "Python", rules: rules, fastPath: fastPath)
    }()
}
