import Foundation
import Testing
@testable import Chroma

@Suite("Renderer")
struct RendererTests {
    @Test("Applies line highlight background")
    func appliesLineHighlight() {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(theme: theme, colorMode: .always, diff: .none, highlightLines: [2...2])
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
        let options = HighlightOptions(theme: theme, colorMode: .always, diff: .patch(), highlightLines: [1...1])
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
        let options = HighlightOptions(theme: theme, colorMode: .always, diff: .patch(style: .foreground()))
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
            colorMode: .always,
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
        let options = HighlightOptions(
            theme: theme,
            colorMode: .always,
            diff: .patch(style: .background(diffCode: .plain))
        )
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
            colorMode: .always,
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
        let options = HighlightOptions(theme: theme, colorMode: .always, diff: .patch())
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

    @Test("Compact diff hides headers and inserts separators")
    func compactDiffHidesHeadersAndInsertsSeparators() {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(
            theme: theme,
            colorMode: .always,
            diff: .patch(presentation: .compact),
            lineNumbers: .init(start: 1)
        )
        let renderer = Renderer(theme: theme, options: options)

        let code = """
        diff --git a/A.swift b/A.swift
        --- a/A.swift
        +++ b/A.swift
        @@ -1,1 +1,1 @@
        -let a = 1
        +let a = 2
        @@ -4,1 +4,1 @@
        -let b = 1
        +let b = 2
        """
        let ns = code as NSString
        let tokens = [Token(kind: .plain, range: NSRange(location: 0, length: ns.length))]

        let output = stripAnsi(renderer.render(code: code, tokens: tokens))
        #expect(!output.contains("diff --git"))
        #expect(!output.contains("@@ -1,1 +1,1 @@"))
        #expect(output.contains("⋮"))
    }

    @Test("Compact diff inserts double separators between files")
    func compactDiffInsertsDoubleSeparatorsBetweenFiles() {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(
            theme: theme,
            colorMode: .always,
            diff: .patch(presentation: .compact),
            lineNumbers: .init(start: 1)
        )
        let renderer = Renderer(theme: theme, options: options)

        let code = """
        diff --git a/A.swift b/A.swift
        --- a/A.swift
        +++ b/A.swift
        @@ -1,1 +1,1 @@
        -let a = 1
        +let a = 2
        diff --git a/B.swift b/B.swift
        --- a/B.swift
        +++ b/B.swift
        @@ -1,1 +1,1 @@
        -let b = 1
        +let b = 2
        """
        let ns = code as NSString
        let tokens = [Token(kind: .plain, range: NSRange(location: 0, length: ns.length))]

        let output = stripAnsi(renderer.render(code: code, tokens: tokens))
        #expect(maxConsecutiveSeparatorLines(in: output) >= 2)
    }

    @Test("Verbose diff keeps headers")
    func verboseDiffKeepsHeaders() {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(
            theme: theme,
            colorMode: .always,
            diff: .patch(presentation: .verbose),
            lineNumbers: .init(start: 1)
        )
        let renderer = Renderer(theme: theme, options: options)

        let code = """
        diff --git a/A.swift b/A.swift
        --- a/A.swift
        +++ b/A.swift
        @@ -1,1 +1,1 @@
        -let a = 1
        +let a = 2
        """
        let ns = code as NSString
        let tokens = [Token(kind: .plain, range: NSRange(location: 0, length: ns.length))]

        let output = stripAnsi(renderer.render(code: code, tokens: tokens))
        #expect(output.contains("diff --git"))
        #expect(output.contains("@@ -1,1 +1,1 @@"))
    }

    @Test("Line numbers render for plain text")
    func lineNumbersRender() {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(
            theme: theme,
            colorMode: .always,
            diff: .none,
            lineNumbers: .init(start: 1)
        )
        let renderer = Renderer(theme: theme, options: options)

        let code = "let a\nlet b"
        let ns = code as NSString
        let tokens = [Token(kind: .plain, range: NSRange(location: 0, length: ns.length))]

        let output = renderer.render(code: code, tokens: tokens)
        let expected = renderExpected([
            ExpectedToken(.comment, "1", foreground: theme.lineNumberForeground),
            ExpectedToken(.plain, " "),
            ExpectedToken(.plain, "let a"),
            ExpectedToken.plain("\n"),
            ExpectedToken(.comment, "2", foreground: theme.lineNumberForeground),
            ExpectedToken(.plain, " "),
            ExpectedToken(.plain, "let b"),
        ])

        #expect(output == expected)
    }

    @Test("Line numbers align to max width and honor indent")
    func lineNumbersAlignmentAndIndent() {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(
            theme: theme,
            colorMode: .always,
            diff: .none,
            lineNumbers: .init(start: 9),
            indent: 2
        )
        let renderer = Renderer(theme: theme, options: options)

        let code = "a\nb"
        let ns = code as NSString
        let tokens = [Token(kind: .plain, range: NSRange(location: 0, length: ns.length))]

        let output = renderer.render(code: code, tokens: tokens)
        let expected = renderExpected([
            ExpectedToken(.plain, "  "),
            ExpectedToken(.comment, " 9", foreground: theme.lineNumberForeground),
            ExpectedToken(.plain, " "),
            ExpectedToken(.plain, "a"),
            ExpectedToken.plain("\n"),
            ExpectedToken(.plain, "  "),
            ExpectedToken(.comment, "10", foreground: theme.lineNumberForeground),
            ExpectedToken(.plain, " "),
            ExpectedToken(.plain, "b"),
        ])

        #expect(output == expected)
    }

    @Test("Line numbers follow diff hunk positions")
    func lineNumbersFollowDiffHunks() {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(
            theme: theme,
            colorMode: .always,
            diff: .none,
            lineNumbers: .init(start: 1)
        )
        let renderer = Renderer(theme: theme, options: options)

        let code = """
        @@ -10,2 +20,2 @@
        -let a
        +let b
         let c
        """
        let ns = code as NSString
        let tokens = [Token(kind: .plain, range: NSRange(location: 0, length: ns.length))]

        let output = renderer.render(code: code, tokens: tokens)
        let expected = renderExpected([
            ExpectedToken(.comment, "  ", foreground: theme.lineNumberForeground),
            ExpectedToken(.plain, " "),
            ExpectedToken(.plain, "@@ -10,2 +20,2 @@"),
            ExpectedToken.plain("\n"),
            ExpectedToken(.comment, "10", foreground: theme.lineNumberForeground),
            ExpectedToken(.plain, " "),
            ExpectedToken(.plain, "-let a"),
            ExpectedToken.plain("\n"),
            ExpectedToken(.comment, "20", foreground: theme.lineNumberForeground),
            ExpectedToken(.plain, " "),
            ExpectedToken(.plain, "+let b"),
            ExpectedToken.plain("\n"),
            ExpectedToken(.comment, "21", foreground: theme.lineNumberForeground),
            ExpectedToken(.plain, " "),
            ExpectedToken(.plain, " let c"),
        ])

        #expect(output == expected)
    }

    @Test("Line numbers use white on diff background")
    func lineNumbersUseWhiteOnDiffBackground() {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(
            theme: theme,
            colorMode: .always,
            diff: .patch(),
            lineNumbers: .init(start: 1)
        )
        let renderer = Renderer(theme: theme, options: options)

        let code = """
        @@ -10,1 +20,1 @@
        -let a
        +let b
        """
        let ns = code as NSString
        let tokens = [Token(kind: .plain, range: NSRange(location: 0, length: ns.length))]

        let output = renderer.render(code: code, tokens: tokens)
        let expectedRemovedNumber = renderExpected([
            ExpectedToken(
                .plain,
                "10",
                foreground: .named(.white),
                background: theme.diffRemovedBackground
            )
        ])
        let expectedAddedNumber = renderExpected([
            ExpectedToken(
                .plain,
                "20",
                foreground: .named(.white),
                background: theme.diffAddedBackground
            )
        ])

        #expect(output.contains(expectedRemovedNumber))
        #expect(output.contains(expectedAddedNumber))
    }

    @Test("Line numbers use diff foreground colors")
    func lineNumbersUseDiffForegroundColors() {
        ensureRainbowEnabled()
        let theme = TestThemes.stable
        let options = HighlightOptions(
            theme: theme,
            colorMode: .always,
            diff: .patch(style: .foreground()),
            lineNumbers: .init(start: 1)
        )
        let renderer = Renderer(theme: theme, options: options)

        let code = """
        @@ -10,1 +20,1 @@
        -let a
        +let b
        """
        let ns = code as NSString
        let tokens = [Token(kind: .plain, range: NSRange(location: 0, length: ns.length))]

        let output = renderer.render(code: code, tokens: tokens)
        let expectedRemovedNumber = renderExpected([
            ExpectedToken(.comment, "10", foreground: theme.diffRemovedForeground)
        ])
        let expectedAddedNumber = renderExpected([
            ExpectedToken(.comment, "20", foreground: theme.diffAddedForeground)
        ])

        #expect(output.contains(expectedRemovedNumber))
        #expect(output.contains(expectedAddedNumber))
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
            diffRemovedForeground: .named(.red),
            lineNumberForeground: .named(.white)
        )
        let options = HighlightOptions(
            theme: theme,
            colorMode: .always,
            diff: .none,
            highlightLines: .init(),
            indent: 2
        )
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
        let options = HighlightOptions(
            theme: theme,
            colorMode: .always,
            diff: .none,
            highlightLines: [2...2],
            indent: 2
        )
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
        let options = HighlightOptions(
            theme: theme,
            colorMode: .always,
            diff: .patch(),
            highlightLines: .init(),
            indent: 1
        )
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

private func stripAnsi(_ text: String) -> String {
    let pattern = "\\u001B\\[[0-9;]*m"
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return text }
    let range = NSRange(text.startIndex..<text.endIndex, in: text)
    return regex.stringByReplacingMatches(in: text, range: range, withTemplate: "")
}

private func maxConsecutiveSeparatorLines(in text: String) -> Int {
    let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
    var current = 0
    var maxRun = 0
    for line in lines {
        if line.trimmingCharacters(in: .whitespaces) == "⋮" {
            current += 1
            if current > maxRun { maxRun = current }
        } else {
            current = 0
        }
    }
    return maxRun
}
