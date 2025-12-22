import Testing
@testable import Chroma

@Suite("Golden - Swift")
struct SwiftGoldenTests {
    @Test("Basic keywords and numbers")
    func basicKeywords() throws {
        try assertGolden(
            "let value = 42",
            language: .swift,
            expected: [
                ExpectedToken(.keyword, "let"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "42"),
            ]
        )
    }

    @Test("Functions, strings, and comments")
    func functionStringComment() throws {
        try assertGolden(
            "print(\"hi\") // note",
            language: .swift,
            expected: [
                ExpectedToken(.function, "print"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.string, "\"hi\""),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.comment, "// note"),
            ]
        )
    }

    @Test("Structs and types")
    func structsAndTypes() throws {
        try assertGolden(
            "struct User { let id: Int }",
            language: .swift,
            expected: [
                ExpectedToken(.keyword, "struct"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "User"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "let"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "id"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.type, "Int"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "}"),
            ]
        )
    }

    @Test("Attributes")
    func attributes() throws {
        try assertGolden(
            "@available(iOS 13, *)",
            language: .swift,
            expected: [
                ExpectedToken(.keyword, "@available"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "iOS"),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "13"),
                ExpectedToken(.punctuation, ","),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "*"),
                ExpectedToken(.punctuation, ")"),
            ]
        )
    }
}
