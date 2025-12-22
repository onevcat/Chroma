import Foundation

extension BuiltInLanguages {
    static let cpp: LanguageDefinition = {
        let keywords = [
            "alignas", "alignof", "and", "and_eq", "asm", "auto", "bitand", "bitor", "bool", "break", "case",
            "catch", "char", "char16_t", "char32_t", "class", "compl", "const", "constexpr", "consteval",
            "constinit", "continue", "decltype", "default", "delete", "do", "double", "dynamic_cast", "else",
            "enum", "explicit", "export", "extern", "false", "float", "for", "friend", "goto", "if", "inline",
            "int", "long", "mutable", "namespace", "new", "noexcept", "not", "not_eq", "nullptr", "operator",
            "or", "or_eq", "private", "protected", "public", "register", "reinterpret_cast", "return", "short",
            "signed", "sizeof", "static", "static_cast", "struct", "switch", "template", "this", "thread_local",
            "throw", "true", "try", "typedef", "typeid", "typename", "union", "unsigned", "using", "virtual",
            "void", "volatile", "wchar_t", "while", "xor", "xor_eq",
        ]
        let types = [
            "size_t", "std", "string", "vector", "map", "unordered_map", "unique_ptr", "shared_ptr", "weak_ptr",
            "optional", "variant",
        ]
        let rules = cStyleRules(
            keywords: keywords,
            builtInTypes: types,
            strings: [
                "R\\\"[\\s\\S]*?\\\"",
                "\"(?:\\\\.|[^\"\\\\])*\"",
                "'(?:\\\\.|[^'\\\\])*'",
            ],
            additionalRules: [
                try! TokenRule(kind: .keyword, pattern: "#\\s*(?:include|define|undef|if|ifdef|ifndef|elif|else|endif|pragma)\\b.*")
            ]
        )
        let fastPath = LanguageFastPath(keywords: keywords, types: types)
        return LanguageDefinition(id: .cpp, displayName: "C++", rules: rules, fastPath: fastPath)
    }()
}
