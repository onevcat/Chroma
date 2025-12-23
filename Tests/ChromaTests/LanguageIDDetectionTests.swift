import Testing
@testable import Chroma

@Suite("LanguageID file detection")
struct LanguageIDDetectionTests {
    @Test("fromFileName detects language from common extensions")
    func fromFileNameCommonExtensions() {
        #expect(LanguageID.fromFileName("MyFile.swift") == .swift)
        #expect(LanguageID.fromFileName("script.py") == .python)
        #expect(LanguageID.fromFileName("Main.kt") == .kotlin)
        #expect(LanguageID.fromFileName("app.go") == .go)
        #expect(LanguageID.fromFileName("lib.rs") == .rust)
        #expect(LanguageID.fromFileName("style.css") == .css)
        #expect(LanguageID.fromFileName("config.json") == .json)
        #expect(LanguageID.fromFileName("README.md") == .markdown)
    }

    @Test("fromFileName is case-insensitive for extensions")
    func fromFileNameCaseInsensitive() {
        #expect(LanguageID.fromFileName("MyFile.SWIFT") == .swift)
        #expect(LanguageID.fromFileName("Script.PY") == .python)
        #expect(LanguageID.fromFileName("Main.KT") == .kotlin)
        #expect(LanguageID.fromFileName("README.MD") == .markdown)
    }

    @Test("fromFileName detects special filenames without extensions")
    func fromFileNameSpecialFilenames() {
        #expect(LanguageID.fromFileName("Makefile") == .makefile)
        #expect(LanguageID.fromFileName("Dockerfile") == .dockerfile)
        #expect(LanguageID.fromFileName("Gemfile") == .ruby)
        #expect(LanguageID.fromFileName("Rakefile") == .ruby)
        #expect(LanguageID.fromFileName("Podfile") == .ruby)
    }

    @Test("fromFileName is case-insensitive for special filenames")
    func fromFileNameSpecialFilenamesCaseInsensitive() {
        #expect(LanguageID.fromFileName("MAKEFILE") == .makefile)
        #expect(LanguageID.fromFileName("DOCKERFILE") == .dockerfile)
        #expect(LanguageID.fromFileName("GEMFILE") == .ruby)
    }

    @Test("fromFileName returns none for unknown extensions")
    func fromFileNameUnknownExtensions() {
        #expect(LanguageID.fromFileName("file.xyz") == .none)
        #expect(LanguageID.fromFileName("unknown") == .none)
        #expect(LanguageID.fromFileName("archive.tar.gz") == .none)  // Only checks last extension
    }

    @Test("fromFilePath extracts filename from path")
    func fromFilePath() {
        #expect(LanguageID.fromFilePath("/path/to/MyFile.swift") == .swift)
        #expect(LanguageID.fromFilePath("./script.py") == .python)
        #expect(LanguageID.fromFilePath("../src/Main.kt") == .kotlin)
        #expect(LanguageID.fromFilePath("/absolute/path/Makefile") == .makefile)
    }

    @Test("fromFilePath handles edge cases")
    func fromFilePathEdgeCases() {
        #expect(LanguageID.fromFilePath("") == .none)
        #expect(LanguageID.fromFilePath("/") == .none)
        #expect(LanguageID.fromFilePath("/path/.hidden") == .none)
    }

    @Test("fromFileURL extracts filename from URL")
    func fromFileURL() {
        #expect(LanguageID.fromFileURL(URL(fileURLWithPath: "/path/to/MyFile.swift")) == .swift)
        #expect(LanguageID.fromFileURL(URL(fileURLWithPath: "./script.py")) == .python)
        #expect(LanguageID.fromFileURL(URL(fileURLWithPath: "/path/Makefile")) == .makefile)
    }

    @Test("plain is alias for none")
    func plainIsAliasForNone() {
        #expect(LanguageID.plain.rawValue == LanguageID.none.rawValue)
        #expect(LanguageID.plain == .none)
    }
}
