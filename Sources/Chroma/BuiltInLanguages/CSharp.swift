import Foundation

extension BuiltInLanguages {
    static let csharp: LanguageDefinition = {
        let keywords = [
            "abstract", "as", "base", "bool", "break", "byte", "case", "catch", "char", "checked", "class", "const",
            "continue", "decimal", "default", "delegate", "do", "double", "else", "enum", "event", "explicit",
            "extern", "false", "finally", "fixed", "float", "for", "foreach", "goto", "if", "implicit", "in",
            "int", "interface", "internal", "is", "lock", "long", "namespace", "new", "null", "object", "operator",
            "out", "override", "params", "private", "protected", "public", "readonly", "ref", "return", "sbyte",
            "sealed", "short", "sizeof", "stackalloc", "static", "string", "struct", "switch", "this", "throw",
            "true", "try", "typeof", "uint", "ulong", "unchecked", "unsafe", "ushort", "using", "virtual", "void",
            "volatile", "while", "var", "record", "init", "required", "with", "when",
        ]
        let types = [
            "bool", "byte", "sbyte", "short", "ushort", "int", "uint", "long", "ulong", "float", "double", "decimal",
            "char", "string", "object", "dynamic", "DateTime", "Guid", "Task", "ValueTask",
        ]

        let rules = cStyleRules(
            keywords: keywords,
            builtInTypes: types,
            strings: [
                "\\$@\"(?:\"\"|[\\s\\S])*?\"",
                "@\"(?:\"\"|[\\s\\S])*?\"",
                "\\$\"(?:\\\\.|[^\"\\\\])*\"",
                "\"(?:\\\\.|[^\"\\\\])*\"",
                "'(?:\\\\.|[^'\\\\])*'",
            ]
        )

        let fastPath = LanguageFastPath(keywords: keywords, types: types)
        return LanguageDefinition(id: .csharp, displayName: "C#", rules: rules, fastPath: fastPath)
    }()
}
