import Testing
@testable import Chroma

@Suite("Golden - Python")
struct PythonGoldenTests {
    @Test("Functions and punctuation")
    func functionsAndPunctuation() throws {
        try assertGolden(
            "def greet(name):",
            language: .python,
            expected: [
                ExpectedToken(.keyword, "def"),
                ExpectedToken.plain(" "),
                ExpectedToken(.function, "greet"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "name"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken(.operator, ":"),
            ]
        )
    }

    @Test("Strings and comments")
    func stringsAndComments() throws {
        try assertGolden(
            "return \"hi\" # note",
            language: .python,
            expected: [
                ExpectedToken(.keyword, "return"),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "\"hi\""),
                ExpectedToken.plain(" "),
                ExpectedToken(.comment, "# note"),
            ]
        )
    }

    @Test("Classes and blocks")
    func classesAndBlocks() throws {
        try assertGolden(
            "class User:\n    pass",
            language: .python,
            expected: [
                ExpectedToken(.keyword, "class"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "User"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain("\n    "),
                ExpectedToken(.keyword, "pass"),
            ]
        )
    }

    @Test("Types and collections")
    func typesAndCollections() throws {
        try assertGolden(
            "items: list[str] = []",
            language: .python,
            expected: [
                ExpectedToken(.plain, "items"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.type, "list"),
                ExpectedToken(.punctuation, "["),
                ExpectedToken(.type, "str"),
                ExpectedToken(.punctuation, "]"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "[]"),
            ]
        )
    }
}
