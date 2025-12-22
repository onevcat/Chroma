import Foundation

extension BuiltInLanguages {
    static let objectiveC: LanguageDefinition = {
        let cKeywords = [
            "auto", "break", "case", "char", "const", "continue", "default", "do", "double", "else", "enum", "extern",
            "float", "for", "goto", "if", "inline", "int", "long", "register", "restrict", "return", "short", "signed",
            "sizeof", "static", "struct", "switch", "typedef", "union", "unsigned", "void", "volatile", "while",
            "self",
        ]

        let atKeywords = [
            "@interface", "@implementation", "@end", "@protocol", "@class", "@public", "@private", "@protected",
            "@package", "@property", "@synthesize", "@dynamic", "@selector", "@try", "@catch", "@finally", "@throw",
            "@autoreleasepool", "@import", "@synchronized",
        ]

        let types = [
            "id", "BOOL", "NSInteger", "NSUInteger", "CGFloat", "NSObject", "NSString", "NSArray", "NSDictionary",
            "NSSet", "NSData", "NSError",
        ]

        let atKeywordNames = atKeywords.map { String($0.dropFirst()) }
        let rules = cStyleRules(
            keywords: cKeywords,
            builtInTypes: types,
            strings: [
                "@\"(?:\\\\.|[^\"\\\\])*\"",
                "\"(?:\\\\.|[^\"\\\\])*\"",
                "'(?:\\\\.|[^'\\\\])*'",
            ],
            additionalRules: [
                try! TokenRule(kind: .keyword, pattern: "#\\s*(?:import|include|define|undef|if|ifdef|ifndef|elif|else|endif|pragma)\\b.*"),
                try! TokenRule(kind: .keyword, pattern: "@(?:\(wordAlternation(atKeywordNames)))\\b"),
            ]
        )
        let fastPath = LanguageFastPath(keywords: cKeywords, types: types)
        return LanguageDefinition(id: .objectiveC, displayName: "Objective-C", rules: rules, fastPath: fastPath)
    }()
}
