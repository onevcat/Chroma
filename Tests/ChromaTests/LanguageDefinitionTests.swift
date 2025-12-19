import Foundation
import Testing
@testable import Chroma

@Suite("LanguageDefinition helpers")
struct LanguageDefinitionTests {
    @Test("appendKeywords adds keyword rules")
    func appendKeywords() throws {
        var language = LanguageDefinition(id: "mini", displayName: "Mini", rules: [])
        try language.appendKeywords(["let"])

        let tokenizer = RegexTokenizer(rules: language.rules)
        let tokens = tokenizer.tokenize("let x")

        #expect(tokens.first?.kind == .keyword)
    }

    @Test("appendBuiltInTypes adds type rules")
    func appendBuiltInTypes() throws {
        var language = LanguageDefinition(id: "mini", displayName: "Mini", rules: [])
        try language.appendBuiltInTypes(["Foo"])

        let tokenizer = RegexTokenizer(rules: language.rules)
        let tokens = tokenizer.tokenize("Foo")

        #expect(tokens.first?.kind == .type)
    }

    @Test("appendWords supports custom kinds")
    func appendWords() throws {
        var language = LanguageDefinition(id: "mini", displayName: "Mini", rules: [])
        try language.appendWords(["note"], kind: .comment)

        let tokenizer = RegexTokenizer(rules: language.rules)
        let tokens = tokenizer.tokenize("note")

        #expect(tokens.first?.kind == .comment)
    }
}
