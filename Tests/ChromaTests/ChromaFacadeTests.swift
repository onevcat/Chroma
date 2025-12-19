import Testing
@testable import Chroma

@Suite("Chroma facade")
struct ChromaFacadeTests {
    @Test("Chroma.highlight applies options theme")
    func highlightUsesOptionsTheme() throws {
        let theme = TestThemes.stable
        let output = try Chroma.highlight(
            "let value = 1",
            language: .swift,
            options: .init(theme: theme)
        )

        let expected = renderExpected([
            ExpectedToken(.keyword, "let")
        ], theme: theme)

        #expect(output.contains(expected))
    }

    @Test("Chroma.highlight throws on unknown language")
    func unknownLanguageThrows() {
        #expect(throws: Highlighter.Error.self) {
            _ = try Chroma.highlight("value", language: "unknown")
        }
    }
}
