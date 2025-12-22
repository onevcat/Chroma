import Foundation

extension BuiltInLanguages {
    static let tsx: LanguageDefinition = {
        let keywords = [
            "any", "as", "asserts", "async", "await", "bigint", "boolean", "break", "case", "catch", "class", "const",
            "continue", "debugger", "declare", "default", "delete", "do", "else", "enum", "export", "extends",
            "false", "finally", "for", "from", "function", "get", "if", "implements", "import", "in", "infer",
            "instanceof", "interface", "is", "keyof", "let", "module", "namespace", "never", "new", "null",
            "number", "object", "package", "private", "protected", "public", "readonly", "return", "satisfies",
            "set", "static", "string", "super", "switch", "symbol", "this", "throw", "true", "try", "type",
            "typeof", "undefined", "unique", "unknown", "var", "void", "while", "with", "yield",
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
            ],
            additionalRules: [
                try! TokenRule(kind: .keyword, pattern: "</?[A-Za-z][A-Za-z0-9:_-]*"),
                try! TokenRule(kind: .property, pattern: "\\b[A-Za-z_:][A-Za-z0-9:._-]*\\b(?=\\s*=)"),
            ]
        )
        let fastPath = LanguageFastPath(keywords: keywords, types: types)
        return LanguageDefinition(id: .tsx, displayName: "TSX", rules: rules, fastPath: fastPath)
    }()
}
