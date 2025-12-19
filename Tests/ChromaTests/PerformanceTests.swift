import Testing
@testable import Chroma

@Suite("Performance")
struct PerformanceTests {
    @Test("Large Swift highlight stays under baseline")
    func largeSwiftHighlight() throws {
        let line = "let value = 123 // comment\n"
        let code = String(repeating: line, count: 2000)

        let clock = ContinuousClock()
        let start = clock.now
        _ = try highlightWithTestTheme(code, language: .swift)
        let elapsed = clock.now - start

        #expect(elapsed < .seconds(1))
    }

    @Test("Diff highlight stays under baseline")
    func diffHighlightBaseline() throws {
        let header = "diff --git a/Foo.swift b/Foo.swift\n@@ -1 +1 @@\n"
        let line = "+let value = 123\n"
        let code = header + String(repeating: line, count: 2000)

        let clock = ContinuousClock()
        let start = clock.now
        _ = try highlightWithTestTheme(
            code,
            language: .swift,
            options: .init(diff: .patch)
        )
        let elapsed = clock.now - start

        #expect(elapsed < .seconds(1))
    }
}
