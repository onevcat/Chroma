import Testing
@testable import Chroma

@Suite("HighlightOptions")
struct HighlightOptionsTests {
    @Test("Defaults are stable")
    func defaults() {
        let options = HighlightOptions()
        #expect(options.theme == nil)
        #expect(options.diff == .auto)
        #expect(options.highlightLines == LineRangeSet())
    }
}
