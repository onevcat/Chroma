public extension LanguageDefinition {
    mutating func appendWords(_ words: [String], kind: TokenKind) throws {
        rules.append(try TokenRule.words(words, kind: kind))
    }

    mutating func appendKeywords(_ keywords: [String]) throws {
        try appendWords(keywords, kind: .keyword)
    }

    mutating func appendBuiltInTypes(_ types: [String]) throws {
        try appendWords(types, kind: .type)
    }
}

