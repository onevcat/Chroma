import Foundation

extension BuiltInLanguages {
    static let java: LanguageDefinition = {
        let keywords = [
            "abstract", "assert", "boolean", "break", "byte", "case", "catch", "char", "class", "const",
            "continue", "default", "do", "double", "else", "enum", "extends", "final", "finally", "float",
            "for", "goto", "if", "implements", "import", "instanceof", "int", "interface", "long", "native",
            "new", "null", "package", "private", "protected", "public", "return", "short", "static",
            "strictfp", "super", "switch", "synchronized", "this", "throw", "throws", "transient", "try",
            "void", "volatile", "while", "true", "false",
        ]
        let types = [
            "String", "Object", "List", "Map", "Set", "Optional", "Integer", "Long", "Double", "Float", "Boolean",
        ]
        let rules = cStyleRules(
            keywords: keywords,
            builtInTypes: types,
            strings: [
                "\"(?:\\\\.|[^\"\\\\])*\"",
                "'(?:\\\\.|[^'\\\\])*'",
            ],
            additionalRules: [
                try! TokenRule(kind: .keyword, pattern: "@[A-Za-z_][A-Za-z0-9_]*\\b")
            ]
        )
        let fastPath = LanguageFastPath(keywords: keywords, types: types)
        return LanguageDefinition(id: .java, displayName: "Java", rules: rules, fastPath: fastPath)
    }()
}
