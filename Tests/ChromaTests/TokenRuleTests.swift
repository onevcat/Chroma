import Foundation
import Testing
@testable import Chroma

@Suite("TokenRule")
struct TokenRuleTests {
    @Test("words builds word-boundary matches")
    func wordsRuleBoundaries() throws {
        let rule = try TokenRule.words(["let", "letter"], kind: .keyword)
        let match = rule.regex.firstMatch(
            in: "letter",
            options: [],
            range: NSRange(location: 0, length: 6)
        )
        let noMatch = rule.regex.firstMatch(
            in: "letters",
            options: [],
            range: NSRange(location: 0, length: 7)
        )

        #expect(match?.range.length == 6)
        #expect(noMatch == nil)
    }

    @Test("init with pattern compiles regex")
    func initWithPattern() throws {
        let rule = try TokenRule(kind: .number, pattern: "\\b\\d+\\b")
        let match = rule.regex.firstMatch(
            in: "value 42",
            options: [],
            range: NSRange(location: 0, length: 8)
        )
        #expect(match?.range.length == 2)
    }
}
