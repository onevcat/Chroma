import Testing
@testable import Chroma

@Suite("HighlightOptions")
struct HighlightOptionsTests {
    @Test("Defaults are stable")
    func defaults() {
        let options = HighlightOptions()
        #expect(options.theme == nil)
        #expect(options.colorMode == .auto(output: .stdout))
        #expect(options.missingLanguageHandling == .error)
        #expect(options.diff == .auto())
        #expect(options.highlightLines == LineRangeSet())
        #expect(options.lineNumbers == .none)
        #expect(options.indent == 0)
    }

    @Test("Indent clamps to zero")
    func indentClamp() {
        let options = HighlightOptions(indent: -2)
        #expect(options.indent == 0)

        var mutable = HighlightOptions()
        mutable.indent = -4
        #expect(mutable.indent == 0)
    }

    @Test("Line numbers clamp to one")
    func lineNumberClamp() {
        let options = HighlightOptions(lineNumbers: .init(start: 0))
        #expect(options.lineNumbers.start == 1)

        var mutable = HighlightOptions(lineNumbers: .init(start: 3))
        mutable.lineNumbers.start = -2
        #expect(mutable.lineNumbers.start == 1)
    }
}
