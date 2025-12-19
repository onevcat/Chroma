import Testing
@testable import Chroma

@Suite("Highlighter output")
struct HighlighterOutputTests {
    @Test("Swift keyword styling uses provided theme")
    func swiftKeywordStyling() throws {
        let output = try highlightWithTestTheme("struct User {}", language: .swift)
        let expected = renderExpected([ExpectedToken(.keyword, "struct")])
        #expect(output.contains(expected))
    }

    @Test("Swift string and comment styling uses provided theme")
    func swiftStringAndCommentStyling() throws {
        let code = """
        let s = "hello"
        // comment
        """
        let output = try highlightWithTestTheme(code, language: .swift)

        let expectedString = renderExpected([ExpectedToken(.string, "\"hello\"")])
        let expectedComment = renderExpected([ExpectedToken(.comment, "// comment")])
        #expect(output.contains(expectedString))
        #expect(output.contains(expectedComment))
    }

    @Test("Options theme overrides the highlighter theme")
    func themeOverride() throws {
        let customTheme = Theme(
            name: "override",
            tokenStyles: [
                .plain: .init(),
                .comment: .init(foreground: .named(.white), styles: [.bold]),
            ],
            lineHighlightBackground: .named(.lightYellow),
            diffAddedBackground: .named(.lightGreen),
            diffRemovedBackground: .named(.lightRed)
        )
        let output = try highlightWithTestTheme(
            "// comment",
            language: .swift,
            options: .init(theme: customTheme)
        )
        let expected = renderExpected([ExpectedToken(.comment, "// comment")], theme: customTheme)
        #expect(output.contains(expected))
    }

    @Test("Line highlighting applies background to styled tokens")
    func lineHighlighting() throws {
        let code = """
        struct A {}
        struct B {}
        """
        let output = try highlightWithTestTheme(
            code,
            language: .swift,
            options: .init(highlightLines: [2...2])
        )

        let expected = renderExpected([
            ExpectedToken(.keyword, "struct", background: TestThemes.stable.lineHighlightBackground)
        ])
        #expect(output.contains(expected))
    }

    @Test("Diff highlighting uses patch rules for +/- lines")
    func diffHighlightingPatch() throws {
        let patch = """
        diff --git a/Foo.swift b/Foo.swift
        --- a/Foo.swift
        +++ b/Foo.swift
        @@ -1,1 +1,1 @@
        -let a = 1
        +let a = 2
        """

        let output = try highlightWithTestTheme(
            patch,
            language: .swift,
            options: .init(diff: .patch)
        )

        let expectedAdded = renderExpected([
            ExpectedToken(.keyword, "let", background: TestThemes.stable.diffAddedBackground)
        ])
        let unexpectedHeader = renderExpected([
            ExpectedToken(.operator, "+++", background: TestThemes.stable.diffAddedBackground)
        ])
        #expect(output.contains(expectedAdded))
        #expect(!output.contains(unexpectedHeader))
    }

    @Test("Language aliases resolve in the built-in registry")
    func languageAliases() throws {
        #expect(throws: Never.self) {
            _ = try highlightWithTestTheme("const x = 1", language: .js)
        }
        #expect(throws: Never.self) {
            _ = try highlightWithTestTheme("class A {}", language: .objc)
        }
        #expect(throws: Never.self) {
            _ = try highlightWithTestTheme("var x = 1", language: .cs)
        }
    }
}
