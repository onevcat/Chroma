import Testing
@testable import Chroma

@Suite("Golden - Less")
struct LessGoldenTests {
    @Test("Variables")
    func variables() throws {
        try assertGolden(
            "@color: #fff;",
            language: .less,
            expected: [
                ExpectedToken(.keyword, "@color"),
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
            ".card { }",
            language: .less,
            expected: [
                ExpectedToken(.type, ".card"),
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
            "@import \"base\";",
            language: .less,
            expected: [
                ExpectedToken(.keyword, "@import"),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "\"base\""),
                ExpectedToken(.punctuation, ";"),
            ]
        )
    }

    @Test("Properties")
    func properties() throws {
        try assertGolden(
            "padding: 10px;",
            language: .less,
            expected: [
                ExpectedToken(.property, "padding"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "10px"),
                ExpectedToken(.punctuation, ";"),
            ]
        )
    }
}
