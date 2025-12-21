import Testing
@testable import Chroma

@Suite("HighlightOptions")
struct HighlightOptionsTests {
    @Test("Defaults are stable")
    func defaults() {
        let options = HighlightOptions()
        #expect(options.theme == nil)
        #expect(options.diff == .auto())
        #expect(options.highlightLines == LineRangeSet())
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
}
