import Foundation
import Testing
@testable import Chroma

private func performanceBaseline() -> Duration {
    let environment = ProcessInfo.processInfo.environment
    if let value = environment["CHROMA_PERF_BASELINE_SECONDS"],
       let seconds = Double(value),
       seconds > 0 {
        return .seconds(seconds)
    }
    return .seconds(1)
}

private func performanceLineCount() -> Int {
    let environment = ProcessInfo.processInfo.environment
    if let value = environment["CHROMA_PERF_LINES"],
       let count = Int(value),
       count > 0 {
        return count
    }
#if os(Linux)
    return 200
#else
    return 2000
#endif
}

@Suite("Performance")
struct PerformanceTests {
    @Test("Large Swift highlight stays under baseline")
    func largeSwiftHighlight() throws {
        let line = "let value = 123 // comment\n"
        let code = String(repeating: line, count: performanceLineCount())

        let clock = ContinuousClock()
        let start = clock.now
        _ = try highlightWithTestTheme(code, language: .swift)
        let elapsed = clock.now - start

        #expect(elapsed < performanceBaseline())
    }

    @Test("Diff highlight stays under baseline")
    func diffHighlightBaseline() throws {
        let header = "diff --git a/Foo.swift b/Foo.swift\n@@ -1 +1 @@\n"
        let line = "+let value = 123\n"
        let code = header + String(repeating: line, count: performanceLineCount())

        let clock = ContinuousClock()
        let start = clock.now
        _ = try highlightWithTestTheme(
            code,
            language: .swift,
            options: .init(diff: .patch())
        )
        let elapsed = clock.now - start

        #expect(elapsed < performanceBaseline())
    }
}
