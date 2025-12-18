import Testing
import Rainbow
@testable import Chroma

@Suite("Chroma highlighting")
struct ChromaHighlightingTests {
    @Test("Swift keyword styling uses theme")
    func swiftKeywordStyling() throws {
        Rainbow.enabled = true

        let output = try Chroma.highlight("struct User {}", language: .swift)
        #expect(output.contains("\u{001B}[95;1mstruct\u{001B}[0m"))
    }

    @Test("Swift string and comment styling uses theme")
    func swiftStringAndCommentStyling() throws {
        Rainbow.enabled = true

        let code = """
        let s = "hello"
        // comment
        """
        let output = try Chroma.highlight(code, language: .swift)

        #expect(output.contains("\u{001B}[92m\"hello\"\u{001B}[0m"))
        #expect(output.contains("\u{001B}[90;2m// comment\u{001B}[0m"))
    }

    @Test("Line highlighting applies background to styled tokens")
    func lineHighlighting() throws {
        Rainbow.enabled = true

        let code = """
        struct A {}
        struct B {}
        """
        let output = try Chroma.highlight(
            code,
            language: .swift,
            options: .init(highlightLines: [2...2])
        )

        // `Theme.dark` uses background `lightBlack` (100) for highlighted lines.
        #expect(output.contains("\u{001B}[95;100;1mstruct\u{001B}[0m"))
    }

    @Test("Diff highlighting uses patch rules for +/- lines")
    func diffHighlightingPatch() throws {
        Rainbow.enabled = true

        let patch = """
        diff --git a/Foo.swift b/Foo.swift
        --- a/Foo.swift
        +++ b/Foo.swift
        @@ -1,1 +1,1 @@
        -let a = 1
        +let a = 2
        """

        let output = try Chroma.highlight(
            patch,
            language: .swift,
            options: .init(diff: .patch)
        )

        // `Theme.dark` uses background `green` (42) for added lines.
        #expect(output.contains("\u{001B}[95;42;1mlet\u{001B}[0m"))
        #expect(!output.contains("\u{001B}[42m+++"))
    }

    @Test("Language aliases resolve in the built-in registry")
    func languageAliases() throws {
        Rainbow.enabled = true

        #expect(throws: Never.self) {
            _ = try Chroma.highlight("const x = 1", language: .js)
        }
        #expect(throws: Never.self) {
            _ = try Chroma.highlight("class A {}", language: .objc)
        }
        #expect(throws: Never.self) {
            _ = try Chroma.highlight("var x = 1", language: .cs)
        }
    }
}
