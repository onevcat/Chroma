import Testing
@testable import Chroma

@Suite("Golden - TypeScript")
struct TypeScriptGoldenTests {
    @Test("Keywords and object shapes")
    func keywordsAndObjects() throws {
        try assertGolden(
            "type User = { id: number }",
            language: .typescript,
            expected: [
                ExpectedToken(.keyword, "type"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "User"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "id"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "number"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "}"),
            ]
        )
    }

    @Test("Generics and arrays")
    func genericsAndArrays() throws {
        try assertGolden(
            "const list: Array<string> = []",
            language: .typescript,
            expected: [
                ExpectedToken(.keyword, "const"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "list"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.type, "Array"),
                ExpectedToken(.operator, "<"),
                ExpectedToken(.keyword, "string"),
                ExpectedToken(.operator, ">"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "[]"),
            ]
        )
    }

    @Test("Interfaces")
    func interfaces() throws {
        try assertGolden(
            "interface User { id: number }",
            language: .typescript,
            expected: [
                ExpectedToken(.keyword, "interface"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "User"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "id"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "number"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "}"),
            ]
        )
    }

    @Test("Union types")
    func unionTypes() throws {
        try assertGolden(
            "let value: string | null = null",
            language: .typescript,
            expected: [
                ExpectedToken(.keyword, "let"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "value"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "string"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "|"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "null"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "null"),
            ]
        )
    }
}
