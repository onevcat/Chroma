import Testing
@testable import Chroma

@Suite("Golden - C")
struct CGoldenTests {
    @Test("Keywords and hex numbers")
    func keywordsNumbers() throws {
        try assertGolden(
            "int value = 0x2A",
            language: .c,
            expected: [
                ExpectedToken(.keyword, "int"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "0x2A"),
            ]
        )
    }

    @Test("Functions, strings, and punctuation")
    func functionsAndStrings() throws {
        try assertGolden(
            "printf(\"hi\");",
            language: .c,
            expected: [
                ExpectedToken(.function, "printf"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.string, "\"hi\""),
                ExpectedToken(.punctuation, ");"),
            ]
        )
    }

    @Test("Comments and numbers")
    func commentsAndNumbers() throws {
        try assertGolden(
            "/* note */ int value = 1;",
            language: .c,
            expected: [
                ExpectedToken(.comment, "/* note */"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "int"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "1"),
                ExpectedToken(.punctuation, ";"),
            ]
        )
    }

    @Test("Preprocessor directives")
    func preprocessorDirectives() throws {
        try assertGolden(
            "#define MAX 10",
            language: .c,
            expected: [
                ExpectedToken(.keyword, "#define MAX 10"),
            ]
        )
    }
}
