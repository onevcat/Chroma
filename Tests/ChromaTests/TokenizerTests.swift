import Foundation
import Testing
@testable import Chroma

@Suite("RegexTokenizer")
struct TokenizerTests {
    @Test("Prefers the longest match")
    func longestMatchWins() throws {
        let rules = [
            try TokenRule(kind: .keyword, pattern: "let"),
            try TokenRule(kind: .type, pattern: "letter")
        ]
        let tokenizer = RegexTokenizer(rules: rules)
        let code = "letter let"
        let tokens = tokenizer.tokenize(code)
        let ns = code as NSString

        #expect(tokens.first?.kind == .type)
        #expect(ns.substring(with: tokens.first!.range) == "letter")
    }

    @Test("Coalesces adjacent tokens of the same kind")
    func coalescesAdjacentTokens() throws {
        let rules = [
            try TokenRule(kind: .number, pattern: "\\d")
        ]
        let tokenizer = RegexTokenizer(rules: rules)
        let tokens = tokenizer.tokenize("12345")

        #expect(tokens.count == 1)
        #expect(tokens.first?.kind == .number)
        #expect(tokens.first?.range.length == 5)
    }

    @Test("Falls back to plain when no rules match")
    func fallbackToPlain() {
        let tokenizer = RegexTokenizer(rules: [])
        let tokens = tokenizer.tokenize("?")

        #expect(tokens.count == 1)
        #expect(tokens.first?.kind == .plain)
    }
}
