import Testing
@testable import Chroma

@Suite("Golden - Ruby")
struct RubyGoldenTests {
    @Test("Functions and punctuation")
    func functionsAndPunctuation() throws {
        try assertGolden(
            "def greet(name)",
            language: .ruby,
            expected: [
                ExpectedToken(.keyword, "def"),
                ExpectedToken.plain(" "),
                ExpectedToken(.function, "greet"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "name"),
                ExpectedToken(.punctuation, ")"),
            ]
        )
    }

    @Test("Strings and comments")
    func stringsAndComments() throws {
        try assertGolden(
            "greet(\"hi\") # note",
            language: .ruby,
            expected: [
                ExpectedToken(.function, "greet"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.string, "\"hi\""),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.comment, "# note"),
            ]
        )
    }

    @Test("Classes and types")
    func classesAndTypes() throws {
        try assertGolden(
            "class User < Object; end",
            language: .ruby,
            expected: [
                ExpectedToken(.keyword, "class"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "User"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "<"),
                ExpectedToken.plain(" "),
                ExpectedToken(.type, "Object"),
                ExpectedToken(.punctuation, ";"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "end"),
            ]
        )
    }

    @Test("Self and numbers")
    func selfAndNumbers() throws {
        try assertGolden(
            "self.name = 1",
            language: .ruby,
            expected: [
                ExpectedToken(.keyword, "self"),
                ExpectedToken(.punctuation, "."),
                ExpectedToken(.plain, "name"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "1"),
            ]
        )
    }
}
