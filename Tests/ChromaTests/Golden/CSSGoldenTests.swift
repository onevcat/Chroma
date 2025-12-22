import Testing
@testable import Chroma

@Suite("Golden - CSS")
struct CSSGoldenTests {
    @Test("Properties and values")
    func propertiesAndValues() throws {
        try assertGolden(
            "color: #fff;",
            language: .css,
            expected: [
                ExpectedToken(.property, "color"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "#fff"),
                ExpectedToken(.punctuation, ";"),
            ]
        )
    }

    @Test("Selectors")
    func selectors() throws {
        try assertGolden(
            ".btn-primary { }",
            language: .css,
            expected: [
                ExpectedToken(.type, ".btn-primary"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "}"),
            ]
        )
    }

    @Test("At rules")
    func atRules() throws {
        try assertGolden(
            "@media screen {",
            language: .css,
            expected: [
                ExpectedToken(.keyword, "@media"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "screen"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{"),
            ]
        )
    }

    @Test("Strings")
    func strings() throws {
        try assertGolden(
            "content: \"hi\";",
            language: .css,
            expected: [
                ExpectedToken(.property, "content"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "\"hi\""),
                ExpectedToken(.punctuation, ";"),
            ]
        )
    }
}
