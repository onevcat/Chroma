import Testing
@testable import Chroma

@Suite("Golden - Rust")
struct RustGoldenTests {
    @Test("Functions and types")
    func functionsAndTypes() throws {
        try assertGolden(
            "fn greet(name: &str) -> String",
            language: .rust,
            expected: [
                ExpectedToken(.keyword, "fn"),
                ExpectedToken.plain(" "),
                ExpectedToken(.function, "greet"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "name"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "&"),
                ExpectedToken(.type, "str"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "->"),
                ExpectedToken.plain(" "),
                ExpectedToken(.type, "String"),
            ]
        )
    }

    @Test("Keywords and hex numbers")
    func keywordsNumbers() throws {
        try assertGolden(
            "let value = 0x2A",
            language: .rust,
            expected: [
                ExpectedToken(.keyword, "let"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "0x2A"),
            ]
        )
    }

    @Test("Raw strings")
    func rawStrings() throws {
        try assertGolden(
            "let path = r#\"/tmp\"#",
            language: .rust,
            expected: [
                ExpectedToken(.keyword, "let"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "path"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "r#\"/tmp\"#"),
            ]
        )
    }

    @Test("Self and properties")
    func selfAndProperties() throws {
        try assertGolden(
            "self.value = 1",
            language: .rust,
            expected: [
                ExpectedToken(.keyword, "self"),
                ExpectedToken(.property, ".value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "1"),
            ]
        )
    }
}
