import Foundation

extension BuiltInLanguages {
    static let dart: LanguageDefinition = {
        let keywords = [
            "abstract", "as", "assert", "async", "await", "break", "case", "catch", "class", "const", "continue",
            "default", "do", "else", "enum", "export", "extends", "extension", "external", "false", "final",
            "finally", "for", "function", "get", "if", "implements", "import", "in", "is", "late", "mixin",
            "new", "null", "on", "operator", "required", "return", "set", "static", "super", "switch", "this",
            "throw", "true", "try", "var", "void", "while", "with", "yield",
        ]
        let types = [
            "int", "double", "bool", "String", "List", "Map", "Set", "Object", "Future", "Stream",
        ]
        let rules = cStyleRules(
            keywords: keywords,
            builtInTypes: types,
            strings: [
                "r\"[\\s\\S]*?\"",
                "r'[\\s\\S]*?'",
                "\"\"\"[\\s\\S]*?\"\"\"",
                "'''[\\s\\S]*?'''",
                "\"(?:\\\\.|[^\"\\\\])*\"",
                "'(?:\\\\.|[^'\\\\])*'",
            ]
        )
        let fastPath = LanguageFastPath(keywords: keywords, types: types)
        return LanguageDefinition(id: .dart, displayName: "Dart", rules: rules, fastPath: fastPath)
    }()
}
