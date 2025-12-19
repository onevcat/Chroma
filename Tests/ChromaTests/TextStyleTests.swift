import Rainbow
import Testing
@testable import Chroma

@Suite("TextStyle")
struct TextStyleTests {
    @Test("makeSegment respects background override")
    func backgroundOverride() {
        let style = TextStyle(
            foreground: .named(.red),
            background: .named(.blue),
            styles: [.bold]
        )

        let segment = style.makeSegment(text: "hi", backgroundOverride: .named(.green))

        #expect(segment.text == "hi")
        #expect(segment.color == .named(.red))
        #expect(segment.backgroundColor == .named(.green))
        #expect(segment.styles == [.bold])
    }
}
