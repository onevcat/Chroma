import Foundation

extension BuiltInLanguages {
    static let c: LanguageDefinition = {
        let keywords = [
            "auto", "break", "case", "char", "const", "continue", "default", "do", "double", "else", "enum", "extern",
            "float", "for", "goto", "if", "inline", "int", "long", "register", "restrict", "return", "short", "signed",
            "sizeof", "static", "struct", "switch", "typedef", "union", "unsigned", "void", "volatile", "while",
        ]
        let types = [
            "size_t", "ptrdiff_t", "uint8_t", "uint16_t", "uint32_t", "uint64_t", "int8_t", "int16_t", "int32_t",
            "int64_t",
        ]
        let rules = cStyleRules(
            keywords: keywords,
            builtInTypes: types,
            strings: [
                "\"(?:\\\\.|[^\"\\\\])*\"",
                "'(?:\\\\.|[^'\\\\])*'",
            ],
            additionalRules: [
                try! TokenRule(kind: .keyword, pattern: "#\\s*(?:include|define|undef|if|ifdef|ifndef|elif|else|endif|pragma)\\b.*")
            ]
        )
        let fastPath = LanguageFastPath(keywords: keywords, types: types)
        return LanguageDefinition(id: .c, displayName: "C", rules: rules, fastPath: fastPath)
    }()
}
