import Foundation

extension BuiltInLanguages {
    static let swift: LanguageDefinition = {
        let keywords = [
            "associatedtype", "class", "deinit", "enum", "extension", "fileprivate", "func", "import", "init",
            "inout", "internal", "let", "operator", "private", "protocol", "public", "static", "struct", "subscript",
            "typealias", "var", "break", "case", "continue", "default", "defer", "do", "else", "fallthrough", "for",
            "guard", "if", "in", "repeat", "return", "switch", "where", "while", "as", "catch", "false", "is", "nil",
            "rethrows", "super", "self", "Self", "throw", "throws", "true", "try", "Any",
        ]
        let types = [
            "Bool", "Int", "Int8", "Int16", "Int32", "Int64", "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
            "Float", "Double", "String", "Character", "Substring", "Array", "Dictionary", "Set", "Optional",
            "Result", "Error", "Never", "Void",
        ]

        let rules = cStyleRules(
            keywords: keywords,
            builtInTypes: types,
            strings: [
                "\"\"\"[\\s\\S]*?\"\"\"",
                "\"(?:\\\\.|[^\"\\\\])*\"",
            ],
            additionalRules: [
                try! TokenRule(kind: .keyword, pattern: "#\\w+"),
                try! TokenRule(kind: .keyword, pattern: "@[A-Za-z_][A-Za-z0-9_]*\\b"),
            ]
        )

        let fastPath = LanguageFastPath(keywords: keywords, types: types)
        return LanguageDefinition(id: .swift, displayName: "Swift", rules: rules, fastPath: fastPath)
    }()
}
