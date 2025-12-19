import Benchmark
@_spi(Benchmarking) import Chroma
import Foundation
import Rainbow

let theme = Theme.dark
let registry = LanguageRegistry.builtIn()
let highlighter = Highlighter(theme: theme, registry: registry)

let fixturesDirectory = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appendingPathComponent("Fixtures")

func loadFixture(_ name: String) -> String {
    let url = fixturesDirectory.appendingPathComponent(name)
    do {
        return try String(contentsOf: url, encoding: .utf8)
    } catch {
        fatalError("Failed to load fixture: \(name) (\(error))")
    }
}

let swiftLine = "let value = 123 // comment\n"
let swiftLarge = String(repeating: swiftLine, count: 5000)

let diffHeader = "diff --git a/Foo.swift b/Foo.swift\n@@ -1 +1 @@\n"
let diffLine = "+let value = 123\n"
let diffLarge = diffHeader + String(repeating: diffLine, count: 5000)

let repoSwift = loadFixture("repo-swift.txt")
let curatedSwift = loadFixture("curated-swift.txt")
let curatedDiff = loadFixture("curated-diff.txt")

let swiftTokens = try! BenchmarkSupport.tokenize(swiftLarge, language: .swift, registry: registry)
let diffTokens = try! BenchmarkSupport.tokenize(diffLarge, language: .swift, registry: registry)
let repoSwiftTokens = try! BenchmarkSupport.tokenize(repoSwift, language: .swift, registry: registry)
let curatedSwiftTokens = try! BenchmarkSupport.tokenize(curatedSwift, language: .swift, registry: registry)
let curatedDiffTokens = try! BenchmarkSupport.tokenize(curatedDiff, language: .swift, registry: registry)

let defaultOptions = HighlightOptions()
let diffOptions = HighlightOptions(diff: .patch)

let shouldPrintMetrics = ProcessInfo.processInfo.environment["CHROMA_BENCH_PRINT_METRICS"] == "1"

@inline(never)
func printTokenizerMetricsIfNeeded() {
    guard shouldPrintMetrics else { return }

    func printMetrics(name: String, code: String) {
        var metrics = TokenizerMetrics()
        _ = try! BenchmarkSupport.tokenize(code, language: .swift, registry: registry, metrics: &metrics)

        let averageRulesPerIteration = metrics.iterations == 0
            ? 0
            : Double(metrics.rulesEvaluated) / Double(metrics.iterations)
        let fallbackRate = metrics.iterations == 0
            ? 0
            : (Double(metrics.fallbackComposed) / Double(metrics.iterations)) * 100
        let matchRate = metrics.rulesEvaluated == 0
            ? 0
            : (Double(metrics.matchesFound) / Double(metrics.rulesEvaluated)) * 100

        print(
            """
            [Chroma] Tokenizer metrics (\(name))
            - length: \(code.count)
            - iterations: \(metrics.iterations)
            - rulesEvaluated: \(metrics.rulesEvaluated) (avg \(String(format: "%.2f", averageRulesPerIteration)) per iteration)
            - matchesFound: \(metrics.matchesFound) (\(String(format: "%.2f", matchRate))%)
            - bestMatchUpdates: \(metrics.bestMatchUpdates)
            - fallbackComposed: \(metrics.fallbackComposed) (\(String(format: "%.2f", fallbackRate))%)
            - tokensEmitted: \(metrics.tokensEmitted)
            - coalescedTokens: \(metrics.coalescedTokens)
            - coalescedMerges: \(metrics.coalescedMerges)
            """
        )
    }

    printMetrics(name: "repeated-swift", code: swiftLarge)
    printMetrics(name: "repo-swift", code: repoSwift)
    printMetrics(name: "curated-swift", code: curatedSwift)
}

@inline(never)
func blackHole<T>(_ value: T) {
    withUnsafePointer(to: value) { _ = $0 }
}

let benchmarks: @Sendable () -> Void = {
    Benchmark(
        "Tokenize Swift",
        closure: { _, _ in
            _ = try BenchmarkSupport.tokenize(swiftLarge, language: .swift, registry: registry)
        },
        setup: {
            printTokenizerMetricsIfNeeded()
            return ()
        }
    )

    Benchmark("Tokenize Swift (repo fixture)") { _ in
        _ = try BenchmarkSupport.tokenize(repoSwift, language: .swift, registry: registry)
    }

    Benchmark("Tokenize Swift (curated fixture)") { _ in
        _ = try BenchmarkSupport.tokenize(curatedSwift, language: .swift, registry: registry)
    }

    Benchmark("Render Swift (Rainbow on)") { _ in
        Rainbow.enabled = true
        _ = BenchmarkSupport.render(swiftLarge, tokens: swiftTokens, theme: theme, options: defaultOptions)
    }

    Benchmark("Render Swift (Rainbow off)") { _ in
        Rainbow.enabled = false
        _ = BenchmarkSupport.render(swiftLarge, tokens: swiftTokens, theme: theme, options: defaultOptions)
    }

    Benchmark("Render Swift (repo, Rainbow off)") { _ in
        Rainbow.enabled = false
        _ = BenchmarkSupport.render(repoSwift, tokens: repoSwiftTokens, theme: theme, options: defaultOptions)
    }

    Benchmark("Render Swift (curated, Rainbow off)") { _ in
        Rainbow.enabled = false
        _ = BenchmarkSupport.render(curatedSwift, tokens: curatedSwiftTokens, theme: theme, options: defaultOptions)
    }

    Benchmark("Split lines (Swift)") { _ in
        let lines = BenchmarkSupport.splitLinesForBenchmark(swiftLarge)
        blackHole(lines.count)
    }

    Benchmark("Diff detect (diff)") { _ in
        let isPatch = BenchmarkSupport.diffLooksLikePatch(diffLarge)
        blackHole(isPatch)
    }

    Benchmark("Diff line kinds (diff)") { _ in
        let lines = BenchmarkSupport.splitLinesForBenchmark(diffLarge)
        let count = BenchmarkSupport.diffLineKindCount(lines: lines)
        blackHole(count)
    }

    Benchmark("Highlight Swift (Rainbow on)") { _ in
        Rainbow.enabled = true
        _ = try highlighter.highlight(swiftLarge, language: .swift, options: defaultOptions)
    }

    Benchmark("Highlight Swift (Rainbow off)") { _ in
        Rainbow.enabled = false
        _ = try highlighter.highlight(swiftLarge, language: .swift, options: defaultOptions)
    }

    Benchmark("Highlight Swift (repo, Rainbow off)") { _ in
        Rainbow.enabled = false
        _ = try highlighter.highlight(repoSwift, language: .swift, options: defaultOptions)
    }

    Benchmark("Highlight Swift (curated, Rainbow off)") { _ in
        Rainbow.enabled = false
        _ = try highlighter.highlight(curatedSwift, language: .swift, options: defaultOptions)
    }

    Benchmark("Highlight diff (Rainbow on)") { _ in
        Rainbow.enabled = true
        _ = try highlighter.highlight(diffLarge, language: .swift, options: diffOptions)
    }

    Benchmark("Highlight diff (curated, Rainbow on)") { _ in
        Rainbow.enabled = true
        _ = try highlighter.highlight(curatedDiff, language: .swift, options: diffOptions)
    }

    Benchmark("Render diff (Rainbow on)") { _ in
        Rainbow.enabled = true
        _ = BenchmarkSupport.render(diffLarge, tokens: diffTokens, theme: theme, options: diffOptions)
    }

    Benchmark("Render diff (curated, Rainbow on)") { _ in
        Rainbow.enabled = true
        _ = BenchmarkSupport.render(curatedDiff, tokens: curatedDiffTokens, theme: theme, options: diffOptions)
    }
}
