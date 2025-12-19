import Testing
@testable import Chroma

@Suite("LineRangeSet")
struct LineRangeSetTests {
    @Test("contains checks multiple ranges")
    func contains() {
        let ranges = LineRangeSet([1...2, 4...6])
        #expect(ranges.contains(1))
        #expect(ranges.contains(2))
        #expect(!ranges.contains(3))
        #expect(ranges.contains(5))
    }

    @Test("Array literal init")
    func arrayLiteralInit() {
        let ranges: LineRangeSet = [3...3, 7...9]
        #expect(ranges.contains(3))
        #expect(ranges.contains(8))
        #expect(!ranges.contains(1))
    }
}
