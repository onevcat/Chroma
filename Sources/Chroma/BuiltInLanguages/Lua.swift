import Foundation

extension BuiltInLanguages {
    static let lua: LanguageDefinition = {
        let keywords = [
            "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local",
            "nil", "not", "or", "repeat", "return", "then", "true", "until", "while",
        ]
        let types = [
            "string", "number", "table", "boolean", "function",
        ]

        var rules: [TokenRule] = []
        rules.append(try! TokenRule(kind: .comment, pattern: "--\\[\\[[\\s\\S]*?\\]\\]"))
        rules.append(try! TokenRule(kind: .comment, pattern: "--[^\\n\\r]*"))
        rules.append(try! TokenRule(kind: .string, pattern: "\\[\\[[\\s\\S]*?\\]\\]"))
        rules.append(try! TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""))
        rules.append(try! TokenRule(kind: .string, pattern: "'(?:\\\\.|[^'\\\\])*'"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b\\d+(?:\\.\\d+)?\\b"))
        rules.append(wordRule(kind: .keyword, words: keywords))
        rules.append(wordRule(kind: .type, words: types))
        rules.append(try! TokenRule(kind: .function, pattern: "\\b[A-Za-z_][A-Za-z0-9_]*\\b(?=\\s*\\()"))
        rules.append(try! TokenRule(kind: .operator, pattern: "[+\\-*/%&|^!~=<>?:]+"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[\\[\\]{}().,;:]"))

        let fastPath = LanguageFastPath(keywords: keywords, types: types)
        return LanguageDefinition(id: .lua, displayName: "Lua", rules: rules, fastPath: fastPath)
    }()
}
