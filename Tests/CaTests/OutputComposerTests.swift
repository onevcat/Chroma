import Testing
@testable import Ca

@Suite("OutputComposer")
struct OutputComposerTests {
    @Test("Empty documents returns empty output")
    func emptyDocuments() {
        let output = OutputComposer().compose(documents: [], showHeaders: true)
        #expect(output.isEmpty)
    }

    @Test("Single document ignores headers flag")
    func singleDocumentNoHeader() {
        let document = HighlightedDocument(title: "Only", lines: ["line-1", "line-2"])
        let output = OutputComposer().compose(documents: [document], showHeaders: true)
        #expect(output == ["line-1", "line-2"])
    }

    @Test("Multiple documents with headers")
    func multipleDocumentsWithHeaders() {
        let first = HighlightedDocument(title: "A.swift", lines: ["one", "two"])
        let second = HighlightedDocument(title: "B.swift", lines: ["three"])
        let output = OutputComposer().compose(documents: [first, second], showHeaders: true)
        #expect(output == ["==> A.swift <==", "one", "two", "", "==> B.swift <==", "three"])
    }

    @Test("Multiple documents without headers")
    func multipleDocumentsNoHeaders() {
        let first = HighlightedDocument(title: "A.swift", lines: ["one", "two"])
        let second = HighlightedDocument(title: "B.swift", lines: ["three"])
        let output = OutputComposer().compose(documents: [first, second], showHeaders: false)
        #expect(output == ["one", "two", "", "three"])
    }
}
