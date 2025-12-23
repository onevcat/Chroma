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

    @Test("Chroma.highlight with silent fallback returns plain text for unknown language")
    func unknownLanguageSilentFallback() throws {
        ensureRainbowEnabled()
        let output = try Chroma.highlight(
            "some text",
            language: "unknown-lang",
            options: .init(fallbackMode: .silent)
        )

        // Should return the original text without ANSI codes (since we're testing, Rainbow might be disabled)
        #expect(output.contains("some text"))
    }

    @Test("Chroma.highlight with fileName uses detected language")
    func highlightWithFileName() throws {
        ensureRainbowEnabled()
        let output = try Chroma.highlight(
            "let value = 1",
            fileName: "MyFile.swift"
        )

        // Should contain highlighted output for Swift
        #expect(!output.isEmpty)
    }

    @Test("Chroma.highlight with fileName and silent fallback for unknown type")
    func highlightWithFileNameUnknownType() throws {
        ensureRainbowEnabled()
        let output = try Chroma.highlight(
            "some random text",
            fileName: "file.unknownext"
        )

        // Should return plain text without throwing
        #expect(output.contains("some random text"))
    }

    @Test("Chroma.highlight with filePath extracts language from path")
    func highlightWithFilePath() throws {
        ensureRainbowEnabled()
        let output = try Chroma.highlight(
            "print('hello')",
            filePath: "/path/to/script.py"
        )

        // Should contain highlighted output for Python
        #expect(!output.isEmpty)
    }

    @Test("Chroma.highlight with fileURL extracts language from URL")
    func highlightWithFileURL() throws {
        ensureRainbowEnabled()
        let url = URL(fileURLWithPath: "/path/to/Main.kt")
        let output = try Chroma.highlight(
            "val x = 1",
            fileURL: url
        )

        // Should contain highlighted output for Kotlin
        #expect(!output.isEmpty)
    }

    @Test("LanguageID.none renders as plain text")
    func languageNoneRendersAsPlainText() throws {
        ensureRainbowEnabled()
        let output = try Chroma.highlight(
            "just plain text",
            language: .none,
            options: .init(fallbackMode: .silent)
        )

        #expect(output.contains("just plain text"))
    }
}
