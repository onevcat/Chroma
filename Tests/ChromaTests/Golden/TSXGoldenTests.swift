import Testing
@testable import Chroma

@Suite("Golden - TSX")
struct TSXGoldenTests {
    @Test("TSX tags")
    func tsxTags() throws {
        try assertGolden(
            "<Button disabled={true} />",
            language: .tsx,
            expected: [
                ExpectedToken(.keyword, "<Button"),
                ExpectedToken.plain(" "),
                ExpectedToken(.property, "disabled"),
                ExpectedToken(.operator, "="),
                ExpectedToken(.punctuation, "{"),
                ExpectedToken(.keyword, "true"),
                ExpectedToken(.punctuation, "}"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "/>"),
            ]
        )
    }

    @Test("Type annotations")
    func typeAnnotations() throws {
        try assertGolden(
            "const value: string = \"hi\"",
            language: .tsx,
            expected: [
                ExpectedToken(.keyword, "const"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "value"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "string"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "\"hi\""),
            ]
        )
    }

    @Test("Interfaces")
    func interfaces() throws {
        try assertGolden(
            "interface User { id: number }",
            language: .tsx,
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

    @Test("Functions")
    func functions() throws {
        try assertGolden(
            "function greet(): void {}",
            language: .tsx,
            expected: [
                ExpectedToken(.keyword, "function"),
                ExpectedToken.plain(" "),
                ExpectedToken(.function, "greet"),
                ExpectedToken(.punctuation, "()"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "void"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{}"),
            ]
        )
    }
}
