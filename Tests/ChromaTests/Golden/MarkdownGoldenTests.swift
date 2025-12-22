import Testing
@testable import Chroma

@Suite("Golden - Markdown")
struct MarkdownGoldenTests {
    @Test("Headings")
    func headings() throws {
        try assertGolden(
            "# Title",
            language: .markdown,
            expected: [
                ExpectedToken(.keyword, "# Title"),
            ]
        )
    }

    @Test("Inline code")
    func inlineCode() throws {
        try assertGolden(
            "Use `code`",
            language: .markdown,
            expected: [
                ExpectedToken(.plain, "Use "),
                ExpectedToken(.string, "`code`"),
            ]
        )
    }

    @Test("Emphasis")
    func emphasis() throws {
        try assertGolden(
            "**bold**",
            language: .markdown,
            expected: [
                ExpectedToken(.keyword, "**bold**"),
            ]
        )
    }

    @Test("Fenced code blocks")
    func fencedCodeBlocks() throws {
        try assertGolden(
            "```swift\nlet value = 1\n```",
            language: .markdown,
            expected: [
                ExpectedToken(.keyword, "```swift"),
                ExpectedToken.plain("\n"),
                ExpectedToken(.keyword, "let"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "1"),
                ExpectedToken.plain("\n"),
                ExpectedToken(.keyword, "```"),
            ]
        )
    }
}
