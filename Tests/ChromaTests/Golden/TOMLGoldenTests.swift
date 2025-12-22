import Testing
@testable import Chroma

@Suite("Golden - TOML")
struct TOMLGoldenTests {
    @Test("Strings")
    func strings() throws {
        try assertGolden(
            "title = \"TOML\"",
            language: .toml,
            expected: [
                ExpectedToken(.property, "title"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "\"TOML\""),
            ]
        )
    }

    @Test("Dotted keys")
    func dottedKeys() throws {
        try assertGolden(
            "owner.name = \"Ada\"",
            language: .toml,
            expected: [
                ExpectedToken(.property, "owner.name"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "\"Ada\""),
            ]
        )
    }

    @Test("Numbers")
    func numbers() throws {
        try assertGolden(
            "count = 42",
            language: .toml,
            expected: [
                ExpectedToken(.property, "count"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "42"),
            ]
        )
    }

    @Test("Arrays")
    func arrays() throws {
        try assertGolden(
            "items = [1, 2]",
            language: .toml,
            expected: [
                ExpectedToken(.property, "items"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "["),
                ExpectedToken(.number, "1"),
                ExpectedToken(.punctuation, ","),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "2"),
                ExpectedToken(.punctuation, "]"),
            ]
        )
    }
}
