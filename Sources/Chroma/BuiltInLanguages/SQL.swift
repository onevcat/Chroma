import Foundation

extension BuiltInLanguages {
    static let sql: LanguageDefinition = {
        let keywords = [
            "select", "from", "where", "join", "left", "right", "inner", "outer", "on", "insert", "into",
            "update", "delete", "create", "table", "alter", "drop", "values", "group", "by", "order", "limit",
            "offset", "distinct", "as", "and", "or", "not", "null", "is", "in", "like", "between", "case",
            "when", "then", "else", "end", "having", "union", "all",
        ]
        let keywordPattern = "(?i)\\b(?:\(wordAlternation(keywords)))\\b"

        var rules: [TokenRule] = []
        rules.append(try! TokenRule(kind: .comment, pattern: "--[^\\n\\r]*"))
        rules.append(try! TokenRule(kind: .comment, pattern: "/\\*[\\s\\S]*?\\*/"))
        rules.append(try! TokenRule(kind: .string, pattern: "'(?:\\\\.|[^'\\\\])*'"))
        rules.append(try! TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b\\d+(?:\\.\\d+)?\\b"))
        rules.append(try! TokenRule(kind: .keyword, pattern: keywordPattern, isWordList: true))
        rules.append(try! TokenRule(kind: .operator, pattern: "[+\\-*/%&|^!~=<>?:]+"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[\\[\\]{}().,;]"))

        let fastPath = LanguageFastPath()
        return LanguageDefinition(id: .sql, displayName: "SQL", rules: rules, fastPath: fastPath)
    }()
}
