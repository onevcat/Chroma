import Testing
@testable import Chroma

@Suite("Chroma facade")
struct ChromaFacadeTests {
    @Test("Chroma.highlight applies options theme")
    func highlightUsesOptionsTheme() throws {
        ensureRainbowEnabled()
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

    @Test("Chroma.highlight falls back to plain text when configured")
    func unknownLanguageFallback() throws {
        let code = "value"
        let output = try Chroma.highlight(
            code,
            language: "unknown",
            options: .init(missingLanguageHandling: .fallbackToPlainText)
        )
        #expect(output == code)
    }

    @Test("Chroma.highlight returns plain text when language is nil")
    func nilLanguageReturnsPlainText() throws {
        let code = "let value = 1"
        let output = try Chroma.highlight(code, language: nil)
        #expect(output == code)
    }
}
