import Benchmark
import Chroma
import Foundation
import Rainbow

let theme = Theme.dark
let registry = LanguageRegistry.builtIn()

let swiftLine = "let value = 123 // comment\n"
let swiftLarge = String(repeating: swiftLine, count: 5000)

let diffHeader = "diff --git a/Foo.swift b/Foo.swift\n@@ -1 +1 @@\n"
let diffLine = "+let value = 123\n"
let diffLarge = diffHeader + String(repeating: diffLine, count: 5000)

let benchmarks: @Sendable () -> Void = {
    Benchmark("Highlight Swift (Rainbow on)") { _ in
        Rainbow.enabled = true
        let highlighter = Highlighter(theme: theme, registry: registry)
        _ = try highlighter.highlight(swiftLarge, language: .swift)
    }

    Benchmark("Highlight Swift (Rainbow off)") { _ in
        Rainbow.enabled = false
        let highlighter = Highlighter(theme: theme, registry: registry)
        _ = try highlighter.highlight(swiftLarge, language: .swift)
    }

    Benchmark("Highlight diff (Rainbow on)") { _ in
        Rainbow.enabled = true
        let highlighter = Highlighter(theme: theme, registry: registry)
        _ = try highlighter.highlight(
            diffLarge,
            language: .swift,
            options: .init(diff: .patch)
        )
    }
}
