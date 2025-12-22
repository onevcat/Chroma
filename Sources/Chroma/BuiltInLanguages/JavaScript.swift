import Foundation

extension BuiltInLanguages {
    static let javascript: LanguageDefinition = {
        let keywords = [
            "await", "break", "case", "catch", "class", "const", "continue", "debugger", "default", "delete", "do",
            "else", "export", "extends", "finally", "for", "function", "if", "import", "in", "instanceof", "let",
            "new", "return", "super", "switch", "this", "throw", "try", "typeof", "var", "void", "while", "with",
            "yield", "true", "false", "null", "undefined",
        ]
        let types = [
            "String", "Number", "Boolean", "Object", "Array", "Map", "Set", "Date", "RegExp", "Promise", "Error",
            "Symbol", "BigInt",
        ]
        let rules = cStyleRules(
            keywords: keywords,
            builtInTypes: types,
            strings: [
                "`[\\s\\S]*?`",
                "\"(?:\\\\.|[^\"\\\\])*\"",
                "'(?:\\\\.|[^'\\\\])*'",
            ]
        )
        let fastPath = LanguageFastPath(keywords: keywords, types: types)
        return LanguageDefinition(id: .javascript, displayName: "JavaScript", rules: rules, fastPath: fastPath)
    }()
}
