import Foundation

enum BuiltInLanguages {
    static let all: [LanguageDefinition] = [
        swift,
        objectiveC,
        alias(objectiveC, id: .objc),
        c,
        javascript,
        alias(javascript, id: .js),
        typescript,
        alias(typescript, id: .ts),
        python,
        alias(python, id: .py),
        ruby,
        alias(ruby, id: .rb),
        go,
        alias(go, id: .golang),
        rust,
        kotlin,
        csharp,
        alias(csharp, id: .cs),
    ]

    private static func alias(_ base: LanguageDefinition, id: LanguageID, displayName: String? = nil) -> LanguageDefinition {
        var lang = base
        lang.id = id
        if let displayName {
            lang.displayName = displayName
        }
        return lang
    }

    private static func wordAlternation(_ words: [String]) -> String {
        words
            .map(NSRegularExpression.escapedPattern(for:))
            .sorted { $0.count > $1.count }
            .joined(separator: "|")
    }

    private static func wordRule(kind: TokenKind, words: [String]) -> TokenRule {
        let alternation = wordAlternation(words)
        return try! TokenRule(kind: kind, pattern: "\\b(?:\(alternation))\\b")
    }

    private static func cStyleRules(
        keywords: [String],
        builtInTypes: [String],
        strings: [String],
        additionalRules: [TokenRule] = []
    ) -> [TokenRule] {
        var rules: [TokenRule] = []

        // Comments
        rules.append(try! TokenRule(kind: .comment, pattern: "//[^\\n\\r]*"))
        rules.append(try! TokenRule(kind: .comment, pattern: "/\\*[\\s\\S]*?\\*/"))

        // Strings
        for pattern in strings {
            rules.append(try! TokenRule(kind: .string, pattern: pattern))
        }

        // Numbers
        rules.append(try! TokenRule(kind: .number, pattern: "\\b0x[0-9a-fA-F]+\\b"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b\\d+(?:\\.\\d+)?\\b"))

        // Keywords / Types
        rules.append(wordRule(kind: .keyword, words: keywords))
        rules.append(wordRule(kind: .type, words: builtInTypes))

        // Identifiers (heuristics)
        rules.append(try! TokenRule(kind: .function, pattern: "\\b[A-Za-z_][A-Za-z0-9_]*\\b(?=\\s*\\()"))
        rules.append(try! TokenRule(kind: .property, pattern: "\\.[A-Za-z_][A-Za-z0-9_]*\\b"))

        // Operators / punctuation
        rules.append(try! TokenRule(kind: .operator, pattern: "[+\\-*/%&|^!~=<>?:]+"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[\\[\\]{}().,;]"))

        rules.append(contentsOf: additionalRules)
        return rules
    }

    private static let swift: LanguageDefinition = {
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

        return LanguageDefinition(id: .swift, displayName: "Swift", rules: rules)
    }()

    private static let objectiveC: LanguageDefinition = {
        let keywords = [
            "auto", "break", "case", "char", "const", "continue", "default", "do", "double", "else", "enum", "extern",
            "float", "for", "goto", "if", "inline", "int", "long", "register", "restrict", "return", "short", "signed",
            "sizeof", "static", "struct", "switch", "typedef", "union", "unsigned", "void", "volatile", "while",
            "@interface", "@implementation", "@end", "@protocol", "@class", "@public", "@private", "@protected",
            "@package", "@property", "@synthesize", "@dynamic", "@selector", "@try", "@catch", "@finally", "@throw",
            "@autoreleasepool",
        ]

        let types = [
            "id", "BOOL", "NSInteger", "NSUInteger", "CGFloat", "NSObject", "NSString", "NSArray", "NSDictionary",
            "NSSet", "NSData", "NSError",
        ]

        let rules = cStyleRules(
            keywords: keywords,
            builtInTypes: types,
            strings: [
                "@\"(?:\\\\.|[^\"\\\\])*\"",
                "\"(?:\\\\.|[^\"\\\\])*\"",
                "'(?:\\\\.|[^'\\\\])*'",
            ],
            additionalRules: [
                try! TokenRule(kind: .keyword, pattern: "#\\s*(?:import|include|define|undef|if|ifdef|ifndef|elif|else|endif|pragma)\\b.*")
            ]
        )
        return LanguageDefinition(id: .objectiveC, displayName: "Objective-C", rules: rules)
    }()

    private static let c: LanguageDefinition = {
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
        return LanguageDefinition(id: .c, displayName: "C", rules: rules)
    }()

    private static let javascript: LanguageDefinition = {
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
        return LanguageDefinition(id: .javascript, displayName: "JavaScript", rules: rules)
    }()

    private static let typescript: LanguageDefinition = {
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
            ]
        )
        return LanguageDefinition(id: .typescript, displayName: "TypeScript", rules: rules)
    }()

    private static let python: LanguageDefinition = {
        let keywords = [
            "and", "as", "assert", "async", "await", "break", "class", "continue", "def", "del", "elif", "else",
            "except", "False", "finally", "for", "from", "global", "if", "import", "in", "is", "lambda", "None",
            "nonlocal", "not", "or", "pass", "raise", "return", "True", "try", "while", "with", "yield",
        ]
        let types = [
            "int", "float", "str", "bytes", "bool", "list", "dict", "set", "tuple", "object", "type",
        ]

        var rules: [TokenRule] = []
        rules.append(try! TokenRule(kind: .comment, pattern: "#[^\\n\\r]*"))
        rules.append(try! TokenRule(kind: .string, pattern: "\"\"\"[\\s\\S]*?\"\"\""))
        rules.append(try! TokenRule(kind: .string, pattern: "'''[\\s\\S]*?'''"))
        rules.append(try! TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""))
        rules.append(try! TokenRule(kind: .string, pattern: "'(?:\\\\.|[^'\\\\])*'"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b0x[0-9a-fA-F]+\\b"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b\\d+(?:\\.\\d+)?\\b"))
        rules.append(wordRule(kind: .keyword, words: keywords))
        rules.append(wordRule(kind: .type, words: types))
        rules.append(try! TokenRule(kind: .function, pattern: "\\b[A-Za-z_][A-Za-z0-9_]*\\b(?=\\s*\\()"))
        rules.append(try! TokenRule(kind: .operator, pattern: "[+\\-*/%&|^!~=<>?:]+"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[\\[\\]{}().,;:]"))

        return LanguageDefinition(id: .python, displayName: "Python", rules: rules)
    }()

    private static let ruby: LanguageDefinition = {
        let keywords = [
            "BEGIN", "END", "alias", "and", "begin", "break", "case", "class", "def", "defined?", "do", "else",
            "elsif", "end", "ensure", "false", "for", "if", "in", "module", "next", "nil", "not", "or", "redo",
            "rescue", "retry", "return", "self", "super", "then", "true", "undef", "unless", "until", "when",
            "while", "yield",
        ]
        let types = [
            "String", "Integer", "Float", "Array", "Hash", "Symbol", "Object", "Module", "Class",
        ]

        var rules: [TokenRule] = []
        rules.append(try! TokenRule(kind: .comment, pattern: "#[^\\n\\r]*"))
        rules.append(try! TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""))
        rules.append(try! TokenRule(kind: .string, pattern: "'(?:\\\\.|[^'\\\\])*'"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b0x[0-9a-fA-F]+\\b"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b\\d+(?:\\.\\d+)?\\b"))
        rules.append(wordRule(kind: .keyword, words: keywords))
        rules.append(wordRule(kind: .type, words: types))
        rules.append(try! TokenRule(kind: .function, pattern: "\\b[A-Za-z_][A-Za-z0-9_]*\\b(?=\\s*\\()"))
        rules.append(try! TokenRule(kind: .operator, pattern: "[+\\-*/%&|^!~=<>?:]+"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[\\[\\]{}().,;:]"))

        return LanguageDefinition(id: .ruby, displayName: "Ruby", rules: rules)
    }()

    private static let go: LanguageDefinition = {
        let keywords = [
            "break", "case", "chan", "const", "continue", "default", "defer", "else", "fallthrough", "for", "func",
            "go", "goto", "if", "import", "interface", "map", "package", "range", "return", "select", "struct",
            "switch", "type", "var",
        ]
        let types = [
            "bool", "byte", "complex64", "complex128", "error", "float32", "float64", "int", "int8", "int16",
            "int32", "int64", "rune", "string", "uint", "uint8", "uint16", "uint32", "uint64", "uintptr",
        ]
        let rules = cStyleRules(
            keywords: keywords,
            builtInTypes: types,
            strings: [
                "`[\\s\\S]*?`",
                "\"(?:\\\\.|[^\"\\\\])*\"",
            ]
        )
        return LanguageDefinition(id: .go, displayName: "Go", rules: rules)
    }()

    private static let rust: LanguageDefinition = {
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
        return LanguageDefinition(id: .rust, displayName: "Rust", rules: rules)
    }()

    private static let kotlin: LanguageDefinition = {
        let keywords = [
            "as", "break", "class", "continue", "do", "else", "false", "for", "fun", "if", "in", "interface", "is",
            "null", "object", "package", "return", "super", "this", "throw", "true", "try", "typealias", "val",
            "var", "when", "while", "by", "catch", "constructor", "delegate", "dynamic", "field", "file",
            "finally", "get", "import", "init", "param", "property", "receiver", "set", "setparam", "where",
        ]
        let types = [
            "Any", "Boolean", "Byte", "Char", "Double", "Float", "Int", "Long", "Short", "String", "Unit",
            "List", "Map", "Set",
        ]
        var rules = cStyleRules(
            keywords: keywords,
            builtInTypes: types,
            strings: [
                "\"\"\"[\\s\\S]*?\"\"\"",
                "\"(?:\\\\.|[^\"\\\\])*\"",
                "'(?:\\\\.|[^'\\\\])*'",
            ]
        )
        return LanguageDefinition(id: .kotlin, displayName: "Kotlin", rules: rules)
    }()

    private static let csharp: LanguageDefinition = {
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

        return LanguageDefinition(id: .csharp, displayName: "C#", rules: rules)
    }()
}
