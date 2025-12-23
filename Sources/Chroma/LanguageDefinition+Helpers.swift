public extension LanguageDefinition {
    mutating func appendWords(_ words: [String], kind: TokenKind) throws {
        rules.append(try TokenRule.words(words, kind: kind))

        switch kind {
        case .keyword:
            var updated = ensureFastPath()
            updated.appendWords(words, kind: .keyword)
            fastPath = updated
        case .type:
            var updated = ensureFastPath()
            updated.appendWords(words, kind: .type)
            fastPath = updated
        default:
            break
        }
    }

    mutating func appendKeywords(_ keywords: [String]) throws {
        try appendWords(keywords, kind: .keyword)
    }

    mutating func appendBuiltInTypes(_ types: [String]) throws {
        try appendWords(types, kind: .type)
    }

    private mutating func ensureFastPath() -> LanguageFastPath {
        if let fastPath {
            return fastPath
        }
        let newValue = LanguageFastPath()
        fastPath = newValue
        return newValue
    }
}
