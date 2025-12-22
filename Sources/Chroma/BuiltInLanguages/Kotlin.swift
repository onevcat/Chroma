import Foundation

extension BuiltInLanguages {
    static let kotlin: LanguageDefinition = {
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
        let rules = cStyleRules(
            keywords: keywords,
            builtInTypes: types,
            strings: [
                "\"\"\"[\\s\\S]*?\"\"\"",
                "\"(?:\\\\.|[^\"\\\\])*\"",
                "'(?:\\\\.|[^'\\\\])*'",
            ]
        )
        let fastPath = LanguageFastPath(keywords: keywords, types: types)
        return LanguageDefinition(id: .kotlin, displayName: "Kotlin", rules: rules, fastPath: fastPath)
    }()
}
