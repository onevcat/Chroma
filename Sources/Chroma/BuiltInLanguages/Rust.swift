import Foundation

extension BuiltInLanguages {
    static let rust: LanguageDefinition = {
        let keywords = [
            "as", "async", "await", "break", "const", "continue", "crate", "dyn", "else", "enum", "extern", "false",
            "fn", "for", "if", "impl", "in", "let", "loop", "match", "mod", "move", "mut", "pub", "ref", "return",
            "self", "Self", "static", "struct", "super", "trait", "true", "type", "unsafe", "use", "where", "while",
        ]
        let types = [
            "bool", "char", "str", "String", "usize", "isize", "u8", "u16", "u32", "u64", "u128", "i8", "i16",
            "i32", "i64", "i128", "f32", "f64", "Option", "Result",
        ]
        let rules = cStyleRules(
            keywords: keywords,
            builtInTypes: types,
            strings: [
                "r#*\"[\\s\\S]*?\"#*",
                "\"(?:\\\\.|[^\"\\\\])*\"",
                "'(?:\\\\.|[^'\\\\])*'",
            ]
        )
        let fastPath = LanguageFastPath(keywords: keywords, types: types)
        return LanguageDefinition(id: .rust, displayName: "Rust", rules: rules, fastPath: fastPath)
    }()
}
