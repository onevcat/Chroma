import Testing
@testable import Chroma

@Suite("Golden - JSX")
struct JSXGoldenTests {
    @Test("JSX tags")
    func jsxTags() throws {
        try assertGolden(
            "<App title=\"Hi\" />",
            language: .jsx,
            expected: [
                ExpectedToken(.keyword, "<App"),
                ExpectedToken.plain(" "),
                ExpectedToken(.property, "title"),
                ExpectedToken(.operator, "="),
                ExpectedToken(.string, "\"Hi\""),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "/>"),
            ]
        )
    }

    @Test("Keywords and numbers")
    func keywordsAndNumbers() throws {
        try assertGolden(
            "const value = 1",
            language: .jsx,
            expected: [
                ExpectedToken(.keyword, "const"),
                ExpectedToken.plain(" "),
                ExpectedToken(.property, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "1"),
            ]
        )
    }

    @Test("Functions")
    func functions() throws {
        try assertGolden(
            "function greet() {}",
            language: .jsx,
            expected: [
                ExpectedToken(.keyword, "function"),
                ExpectedToken.plain(" "),
                ExpectedToken(.function, "greet"),
                ExpectedToken(.punctuation, "()"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{}"),
            ]
        )
    }

    @Test("Closing tags")
    func closingTags() throws {
        try assertGolden(
            "</App>",
            language: .jsx,
            expected: [
                ExpectedToken(.keyword, "</App"),
                ExpectedToken(.operator, ">"),
            ]
        )
    }
}
