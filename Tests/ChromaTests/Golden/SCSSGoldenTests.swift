import Testing
@testable import Chroma

@Suite("Golden - SCSS")
struct SCSSGoldenTests {
    @Test("Variables")
    func variables() throws {
        try assertGolden(
            "$primary: #fff;",
            language: .scss,
            expected: [
                ExpectedToken(.property, "$primary"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "#fff"),
                ExpectedToken(.punctuation, ";"),
            ]
        )
    }

    @Test("Mixins")
    func mixins() throws {
        try assertGolden(
            "@mixin rounded($r) {}",
            language: .scss,
            expected: [
                ExpectedToken(.keyword, "@mixin"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "rounded"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.property, "$r"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{}"),
            ]
        )
    }

    @Test("Selectors")
    func selectors() throws {
        try assertGolden(
            ".card { }",
            language: .scss,
            expected: [
                ExpectedToken(.type, ".card"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "}"),
            ]
        )
    }

    @Test("Strings")
    func strings() throws {
        try assertGolden(
            "content: \"hi\";",
            language: .scss,
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
