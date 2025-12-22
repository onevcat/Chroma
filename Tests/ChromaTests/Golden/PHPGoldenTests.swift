import Testing
@testable import Chroma

@Suite("Golden - PHP")
struct PHPGoldenTests {
    @Test("Open tag and echo")
    func openTagAndEcho() throws {
        try assertGolden(
            "<?php echo $name;",
            language: .php,
            expected: [
                ExpectedToken(.keyword, "<?php"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "echo"),
                ExpectedToken.plain(" "),
                ExpectedToken(.property, "$name"),
                ExpectedToken(.punctuation, ";"),
            ]
        )
    }

    @Test("Functions and variables")
    func functionsAndVariables() throws {
        try assertGolden(
            "function greet($name) {}",
            language: .php,
            expected: [
                ExpectedToken(.keyword, "function"),
                ExpectedToken.plain(" "),
                ExpectedToken(.function, "greet"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.property, "$name"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{}"),
            ]
        )
    }

    @Test("Line comments")
    func lineComments() throws {
        try assertGolden(
            "// note",
            language: .php,
            expected: [
                ExpectedToken(.comment, "// note"),
            ]
        )
    }

    @Test("Null values")
    func nullValues() throws {
        try assertGolden(
            "$value = null",
            language: .php,
            expected: [
                ExpectedToken(.property, "$value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "null"),
            ]
        )
    }
}
