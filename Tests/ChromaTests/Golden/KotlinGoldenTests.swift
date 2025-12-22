import Testing
@testable import Chroma

@Suite("Golden - Kotlin")
struct KotlinGoldenTests {
    @Test("Functions and types")
    func functionsAndTypes() throws {
        try assertGolden(
            "fun greet(name: String): Int",
            language: .kotlin,
            expected: [
                ExpectedToken(.keyword, "fun"),
                ExpectedToken.plain(" "),
                ExpectedToken(.function, "greet"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "name"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.type, "String"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.type, "Int"),
            ]
        )
    }

    @Test("Keywords and numbers")
    func keywordsNumbers() throws {
        try assertGolden(
            "val count = 42",
            language: .kotlin,
            expected: [
                ExpectedToken(.keyword, "val"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "count"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "42"),
            ]
        )
    }

    @Test("Properties and strings")
    func propertiesAndStrings() throws {
        try assertGolden(
            "val name: String = \"Ada\"",
            language: .kotlin,
            expected: [
                ExpectedToken(.keyword, "val"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "name"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.type, "String"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "\"Ada\""),
            ]
        )
    }

    @Test("Triple-quoted strings")
    func tripleQuotedStrings() throws {
        try assertGolden(
            "val text = \"\"\"hi\"\"\"",
            language: .kotlin,
            expected: [
                ExpectedToken(.keyword, "val"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "text"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "\"\"\"hi\"\"\""),
            ]
        )
    }
}
