import Foundation
import Testing
@testable import Chroma

@Suite("Renderer")
struct RendererTests {
    @Test("Applies line highlight background")
    func appliesLineHighlight() {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(theme: theme, diff: .none, highlightLines: [2...2])
        let renderer = Renderer(theme: theme, options: options)

        let code = "let a\nlet b"
        let tokens = [
            Token(kind: .keyword, range: NSRange(location: 0, length: 3)),
            Token(kind: .plain, range: NSRange(location: 3, length: 2)),
            Token(kind: .plain, range: NSRange(location: 5, length: 1)),
            Token(kind: .keyword, range: NSRange(location: 6, length: 3)),
            Token(kind: .plain, range: NSRange(location: 9, length: 2)),
        ]

        let output = renderer.render(code: code, tokens: tokens)
        let expected = renderExpected([
            ExpectedToken(.keyword, "let"),
            ExpectedToken.plain(" a"),
            ExpectedToken.plain("\n"),
            ExpectedToken(.keyword, "let", background: theme.lineHighlightBackground),
            ExpectedToken(.plain, " b", background: theme.lineHighlightBackground),
        ])

        #expect(output == expected)
    }

    @Test("Line highlighting overrides diff backgrounds")
    func highlightOverridesDiff() throws {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(theme: theme, diff: .patch(), highlightLines: [1...1])
        let renderer = Renderer(theme: theme, options: options)

        let code = "+let a = 1"
        let language = BuiltInLanguages.all.first { $0.id == .swift }!
        let tokens = RegexTokenizer(rules: language.rules).tokenize(code)

        let output = renderer.render(code: code, tokens: tokens)
        let expected = renderExpected([
            ExpectedToken(.keyword, "let", background: theme.lineHighlightBackground)
        ])
        let unexpected = renderExpected([
            ExpectedToken(.keyword, "let", background: theme.diffAddedBackground)
        ])

        #expect(output.contains(expected))
        #expect(!output.contains(unexpected))
    }

    @Test("Diff foreground uses line foreground and ignores token styles")
    func diffForegroundUsesPlainStyle() throws {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(theme: theme, diff: .patch(style: .foreground()))
        let renderer = Renderer(theme: theme, options: options)

        let code = "let a\n+let value = 1"
        let language = BuiltInLanguages.all.first { $0.id == .swift }!
        let tokens = RegexTokenizer(rules: language.rules).tokenize(code)

        let output = renderer.render(code: code, tokens: tokens)
        let expectedContextPlain = renderExpected([
            ExpectedToken(.plain, "let")
        ])
        let expectedDiffPlain = renderExpected([
            ExpectedToken(.plain, "let", foreground: theme.diffAddedForeground)
        ])
        let unexpectedContextKeyword = renderExpected([
            ExpectedToken(.keyword, "let")
        ])
        let unexpectedKeyword = renderExpected([
            ExpectedToken(.keyword, "let", foreground: theme.diffAddedForeground)
        ])

        #expect(output.contains(expectedContextPlain))
        #expect(output.contains(expectedDiffPlain))
        #expect(!output.contains(unexpectedContextKeyword))
        #expect(!output.contains(unexpectedKeyword))
    }

    @Test("Diff foreground can keep syntax styling for context lines")
    func diffForegroundKeepsContextSyntax() throws {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(
            theme: theme,
            diff: .patch(style: .foreground(contextCode: .syntax))
        )
        let renderer = Renderer(theme: theme, options: options)

        let code = "let a\n+let b"
        let language = BuiltInLanguages.all.first { $0.id == .swift }!
        let tokens = RegexTokenizer(rules: language.rules).tokenize(code)

        let output = renderer.render(code: code, tokens: tokens)
        let expectedContext = renderExpected([
            ExpectedToken(.keyword, "let")
        ])

        #expect(output.contains(expectedContext))
    }

    @Test("Diff background can disable code styling")
    func diffBackgroundPlainStyle() throws {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(theme: theme, diff: .patch(style: .background(diffCode: .plain)))
        let renderer = Renderer(theme: theme, options: options)

        let code = "let a\n+let value = 1"
        let language = BuiltInLanguages.all.first { $0.id == .swift }!
        let tokens = RegexTokenizer(rules: language.rules).tokenize(code)

        let output = renderer.render(code: code, tokens: tokens)
        let expectedContextKeyword = renderExpected([
            ExpectedToken(.keyword, "let")
        ])
        let expectedDiffPlain = renderExpected([
            ExpectedToken(.plain, "let", background: theme.diffAddedBackground)
        ])
        let unexpectedKeyword = renderExpected([
            ExpectedToken(.keyword, "let", background: theme.diffAddedBackground)
        ])

        #expect(output.contains(expectedContextKeyword))
        #expect(output.contains(expectedDiffPlain))
        #expect(!output.contains(unexpectedKeyword))
    }

    @Test("Diff background can keep context plain while diff uses syntax")
    func diffBackgroundKeepsContextPlain() throws {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(
            theme: theme,
            diff: .patch(style: .background(diffCode: .syntax, contextCode: .plain))
        )
        let renderer = Renderer(theme: theme, options: options)

        let code = "let a\n+let b"
        let language = BuiltInLanguages.all.first { $0.id == .swift }!
        let tokens = RegexTokenizer(rules: language.rules).tokenize(code)

        let output = renderer.render(code: code, tokens: tokens)
        let expectedContextPlain = renderExpected([
            ExpectedToken(.plain, "let")
        ])
        let expectedDiffKeyword = renderExpected([
            ExpectedToken(.keyword, "let", background: theme.diffAddedBackground)
        ])
        let unexpectedContextKeyword = renderExpected([
            ExpectedToken(.keyword, "let")
        ])

        #expect(output.contains(expectedContextPlain))
        #expect(output.contains(expectedDiffKeyword))
        #expect(!output.contains(unexpectedContextKeyword))
    }

    @Test("Diff background defaults to syntax for diff and context")
    func diffBackgroundDefaultSyntax() throws {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(theme: theme, diff: .patch())
        let renderer = Renderer(theme: theme, options: options)

        let code = "let a\n+let b"
        let language = BuiltInLanguages.all.first { $0.id == .swift }!
        let tokens = RegexTokenizer(rules: language.rules).tokenize(code)

        let output = renderer.render(code: code, tokens: tokens)
        let expectedContextKeyword = renderExpected([
            ExpectedToken(.keyword, "let")
        ])
        let expectedDiffKeyword = renderExpected([
            ExpectedToken(.keyword, "let", background: theme.diffAddedBackground)
        ])

        #expect(output.contains(expectedContextKeyword))
        #expect(output.contains(expectedDiffKeyword))
    }

    @Test("Indent applies to empty lines")
    func indentAppliesToEmptyLines() {
        let theme = Theme(
            name: "plain",
            tokenStyles: [.plain: .init()],
            lineHighlightBackground: .named(.black),
            diffAddedBackground: .named(.black),
            diffRemovedBackground: .named(.black),
            diffAddedForeground: .named(.green),
            diffRemovedForeground: .named(.red)
        )
        let options = HighlightOptions(theme: theme, diff: .none, highlightLines: .init(), indent: 2)
        let renderer = Renderer(theme: theme, options: options)

        let code = "let a\n\nlet b\n"
        let ns = code as NSString
        let tokens = [Token(kind: .plain, range: NSRange(location: 0, length: ns.length))]

        let output = renderer.render(code: code, tokens: tokens)
        let expected = "  let a\n  \n  let b\n"

        #expect(output == expected)
    }

    @Test("Indent applies line highlight background")
    func indentAppliesLineHighlight() {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(theme: theme, diff: .none, highlightLines: [2...2], indent: 2)
        let renderer = Renderer(theme: theme, options: options)

        let code = "let a\nlet b"
        let tokens = [
            Token(kind: .keyword, range: NSRange(location: 0, length: 3)),
            Token(kind: .plain, range: NSRange(location: 3, length: 2)),
            Token(kind: .plain, range: NSRange(location: 5, length: 1)),
            Token(kind: .keyword, range: NSRange(location: 6, length: 3)),
            Token(kind: .plain, range: NSRange(location: 9, length: 2)),
        ]

        let output = renderer.render(code: code, tokens: tokens)
        let expected = renderExpected([
            ExpectedToken(.plain, "  "),
            ExpectedToken(.keyword, "let"),
            ExpectedToken.plain(" a"),
            ExpectedToken.plain("\n"),
            ExpectedToken(.plain, "  ", background: theme.lineHighlightBackground),
            ExpectedToken(.keyword, "let", background: theme.lineHighlightBackground),
            ExpectedToken(.plain, " b", background: theme.lineHighlightBackground),
        ])

        #expect(output == expected)
    }

    @Test("Indent applies diff backgrounds per line")
    func indentAppliesDiffBackgrounds() {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(theme: theme, diff: .patch(), highlightLines: .init(), indent: 1)
        let renderer = Renderer(theme: theme, options: options)

        let code = "+let a\n-let b"
        let ns = code as NSString
        let tokens = [Token(kind: .plain, range: NSRange(location: 0, length: ns.length))]

        let output = renderer.render(code: code, tokens: tokens)
        let expected = renderExpected([
            ExpectedToken(.plain, " ", background: theme.diffAddedBackground),
            ExpectedToken(.plain, "+let a", background: theme.diffAddedBackground),
            ExpectedToken.plain("\n"),
            ExpectedToken(.plain, " ", background: theme.diffRemovedBackground),
            ExpectedToken(.plain, "-let b", background: theme.diffRemovedBackground),
        ])

        #expect(output == expected)
    }
}
