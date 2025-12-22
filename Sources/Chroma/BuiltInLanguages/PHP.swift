import Foundation

extension BuiltInLanguages {
    static let php: LanguageDefinition = {
        let keywords = [
            "abstract", "array", "as", "break", "case", "catch", "class", "clone", "const", "continue",
            "declare", "default", "do", "echo", "else", "elseif", "empty", "enddeclare", "endfor", "endforeach",
            "endif", "endswitch", "endwhile", "eval", "exit", "extends", "final", "finally", "for", "foreach",
            "function", "global", "goto", "if", "implements", "include", "include_once", "instanceof", "interface",
            "isset", "list", "namespace", "new", "null", "print", "private", "protected", "public", "require",
            "require_once", "return", "static", "switch", "throw", "trait", "try", "unset", "use", "var", "while",
            "true", "false",
        ]
        let types = [
            "string", "int", "float", "bool", "array", "callable", "iterable", "object", "void", "mixed",
        ]

        var rules: [TokenRule] = []
        rules.append(try! TokenRule(kind: .comment, pattern: "//[^\\n\\r]*"))
        rules.append(try! TokenRule(kind: .comment, pattern: "#[^\\n\\r]*"))
        rules.append(try! TokenRule(kind: .comment, pattern: "/\\*[\\s\\S]*?\\*/"))
        rules.append(try! TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""))
        rules.append(try! TokenRule(kind: .string, pattern: "'(?:\\\\.|[^'\\\\])*'"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b\\d+(?:\\.\\d+)?\\b"))
        rules.append(try! TokenRule(kind: .keyword, pattern: "<\\?php"))
        rules.append(wordRule(kind: .keyword, words: keywords))
        rules.append(wordRule(kind: .type, words: types))
        rules.append(try! TokenRule(kind: .property, pattern: "\\$[A-Za-z_][A-Za-z0-9_]*"))
        rules.append(try! TokenRule(kind: .function, pattern: "\\b[A-Za-z_][A-Za-z0-9_]*\\b(?=\\s*\\()"))
        rules.append(try! TokenRule(kind: .operator, pattern: "[+\\-*/%&|^!~=<>?:]+"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[\\[\\]{}().,;]"))

        let fastPath = LanguageFastPath(keywords: keywords, types: types)
        return LanguageDefinition(id: .php, displayName: "PHP", rules: rules, fastPath: fastPath)
    }()
}
