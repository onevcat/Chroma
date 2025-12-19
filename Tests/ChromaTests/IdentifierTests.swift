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
}
