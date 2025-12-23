import Foundation
import Testing
@testable import Chroma

@Suite("Identifiers")
struct IdentifierTests {
    @Test("LanguageID supports string literal init")
    func languageIDLiteral() {
        let id: LanguageID = "swift"
        #expect(id.rawValue == "swift")
        #expect(id.description == "swift")
    }

    @Test("TokenKind supports string literal init")
    func tokenKindLiteral() {
        let kind: TokenKind = "keyword"
        #expect(kind.rawValue == "keyword")
        #expect(kind.description == "keyword")
    }

    @Test("LanguageID infers from file names")
    func languageIDFromFileName() {
        #expect(LanguageID.fromFileName("MyFile.swift") == .swift)
        #expect(LanguageID.fromFileName("hello.kt") == .kotlin)
        #expect(LanguageID.fromFileName("Dockerfile") == .dockerfile)
        #expect(LanguageID.fromFileName("Dockerfile.dev") == .dockerfile)
        #expect(LanguageID.fromFileName("Makefile") == .makefile)
        #expect(LanguageID.fromFileName("Makefile.local") == .makefile)
        #expect(LanguageID.fromFileName("unknown.ext") == nil)
    }

    @Test("LanguageID infers from paths and URLs")
    func languageIDFromPathAndURL() {
        #expect(LanguageID.fromFilePath("/tmp/project/Foo.tsx") == .tsx)
        #expect(LanguageID.fromFilePath("/tmp/project/GNUmakefile") == .makefile)

        let url = URL(fileURLWithPath: "/tmp/project/App.jsx")
        #expect(LanguageID.fromURL(url) == .jsx)
    }
}
