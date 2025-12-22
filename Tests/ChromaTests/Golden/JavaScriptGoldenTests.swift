import Testing
@testable import Chroma

@Suite("Golden - JavaScript")
struct JavaScriptGoldenTests {
    @Test("Keywords and numbers")
    func keywordsNumbers() throws {
        try assertGolden(
            "const value = 42",
            language: .javascript,
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

    @Test("Properties and strings")
    func propertiesAndStrings() throws {
        try assertGolden(
            "console.log(\"hi\")",
            language: .javascript,
            expected: [
                ExpectedToken(.plain, "console"),
                ExpectedToken(.property, ".log"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.string, "\"hi\""),
                ExpectedToken(.punctuation, ")"),
            ]
        )
    }

    @Test("Template strings")
    func templateStrings() throws {
        try assertGolden(
            "const msg = `hi`",
            language: .javascript,
            expected: [
                ExpectedToken(.keyword, "const"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "msg"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "`hi`"),
            ]
        )
    }

    @Test("Classes and punctuation")
    func classesAndPunctuation() throws {
        try assertGolden(
            "class User {}",
            language: .javascript,
            expected: [
                ExpectedToken(.keyword, "class"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "User"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{}"),
            ]
        )
    }
}
