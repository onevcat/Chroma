import Testing
@testable import Chroma

@Suite("Golden - Objective-C")
struct ObjectiveCGoldenTests {
    @Test("Types and strings")
    func typesAndStrings() throws {
        try assertGolden(
            "NSString *name = @\"hi\"",
            language: .objectiveC,
            expected: [
                ExpectedToken(.type, "NSString"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "*"),
                ExpectedToken(.plain, "name"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "@\"hi\""),
            ]
        )
    }

    @Test("Keywords, operators, and numbers")
    func keywordsOperatorsNumbers() throws {
        try assertGolden(
            "if (value == 0) {}",
            language: .objectiveC,
            expected: [
                ExpectedToken(.keyword, "if"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "=="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "0"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{}"),
            ]
        )
    }

    @Test("@keywords")
    func atKeywords() throws {
        try assertGolden(
            "@property (nonatomic, copy) NSString *name;",
            language: .objectiveC,
            expected: [
                ExpectedToken(.keyword, "@property"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "nonatomic"),
                ExpectedToken(.punctuation, ","),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "copy"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.type, "NSString"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "*"),
                ExpectedToken(.plain, "name"),
                ExpectedToken(.punctuation, ";"),
            ]
        )
    }

    @Test("@implementation and @end")
    func implementationBlocks() throws {
        try assertGolden(
            "@implementation Foo\n@end",
            language: .objectiveC,
            expected: [
                ExpectedToken(.keyword, "@implementation"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "Foo"),
                ExpectedToken.plain("\n"),
                ExpectedToken(.keyword, "@end"),
            ]
        )
    }

    @Test("self keyword")
    func selfKeyword() throws {
        try assertGolden(
            "self.name = @\"hi\"",
            language: .objectiveC,
            expected: [
                ExpectedToken(.keyword, "self"),
                ExpectedToken(.property, ".name"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "@\"hi\""),
            ]
        )
    }

    @Test("@import and @synchronized")
    func importAndSynchronized() throws {
        try assertGolden(
            "@import Foundation\n@synchronized(self) {}",
            language: .objectiveC,
            expected: [
                ExpectedToken(.keyword, "@import"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "Foundation"),
                ExpectedToken.plain("\n"),
                ExpectedToken(.keyword, "@synchronized"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.keyword, "self"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{}"),
            ]
        )
    }
}
