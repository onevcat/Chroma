import Testing
@testable import Chroma

@Suite("Golden - Go")
struct GoGoldenTests {
    @Test("Functions and types")
    func functionsAndTypes() throws {
        try assertGolden(
            "func greet(name string) {",
            language: .go,
            expected: [
                ExpectedToken(.keyword, "func"),
                ExpectedToken.plain(" "),
                ExpectedToken(.function, "greet"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "name"),
                ExpectedToken.plain(" "),
                ExpectedToken(.type, "string"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{"),
            ]
        )
    }

    @Test("Operators and numbers")
    func operatorsAndNumbers() throws {
        try assertGolden(
            "value := 10",
            language: .go,
            expected: [
                ExpectedToken(.plain, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, ":="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "10"),
            ]
        )
    }

    @Test("Constants")
    func constants() throws {
        try assertGolden(
            "const value = 42",
            language: .go,
            expected: [
                ExpectedToken(.keyword, "const"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "42"),
            ]
        )
    }

    @Test("Raw strings")
    func rawStrings() throws {
        try assertGolden(
            "path := `~/data`",
            language: .go,
            expected: [
                ExpectedToken(.plain, "path"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, ":="),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "`~/data`"),
            ]
        )
    }
}
