![](https://github.com/user-attachments/assets/36afa20e-265c-4a00-bb54-d6a9e4954ba0)

`Chroma` is a Swift package for syntax highlighting code in terminal output (TUI / CLI apps).

It takes a code string plus a language identifier (e.g. Swift / JavaScript / C#), and returns an ANSI-colored string.
ANSI styling is generated via [`Rainbow`](https://github.com/onevcat/Rainbow).

## Features

- Built-in languages: Swift, Objective-C, C, C++, Java, C#, JavaScript, JSX, TypeScript, TSX, Python, Ruby, Go, Rust, Kotlin, PHP, Dart, Lua, Bash, SQL, CSS, SCSS, Sass, Less, HTML, XML, JSON, YAML, TOML, Markdown, Dockerfile, Makefile
- Built-in themes: `Theme.dark` and `Theme.light`
- Custom language registration (`LanguageRegistry`)
- Custom themes (`Theme`)
- Line highlighting via `HighlightOptions.highlightLines`
- Line numbers via `HighlightOptions.lineNumbers`
- Output indentation via `HighlightOptions.indent`
- Diff highlighting (unified patch) via `HighlightOptions.diff`

## Usage

```swift
import Chroma

let code = """
struct User {
    let id: Int
}
"""

let output = try Chroma.highlight(code, language: .swift)
print(output)
```

## Demo

This package includes a small SwiftPM executable target that prints highlighted sample code for multiple languages.

```bash
swift run ChromaDemo
```

## Benchmarks

Benchmarks use `package-benchmark`. Install jemalloc to enable memory stats.

```bash
brew install jemalloc
swift package benchmark --target ChromaBenchmarks
```

On Ubuntu:

```bash
sudo apt-get update
sudo apt-get install -y libjemalloc-dev
swift package benchmark --target ChromaBenchmarks
```

If jemalloc is not available, run:

```bash
BENCHMARK_DISABLE_JEMALLOC=1 swift package benchmark --target ChromaBenchmarks
```

### Themes

```swift
let output = try Chroma.highlight(
    code,
    language: .swift,
    options: .init(theme: .light)
)
```

### Highlight lines

Line numbers are 1-based and include empty lines.

```swift
let output = try Chroma.highlight(
    code,
    language: .swift,
    options: .init(highlightLines: [2...3, 6...6])
)
```

### Line numbers

```swift
let output = try Chroma.highlight(
    code,
    language: .swift,
    options: .init(lineNumbers: .init(start: 1))
)
```

### Indent output

```swift
let output = try Chroma.highlight(
    code,
    language: .swift,
    options: .init(indent: 2)
)
```

### Diff highlighting (unified patch)

`Chroma` can highlight `+` / `-` lines in unified patches, following the common `git diff` patch rules.
By default it renders a compact view with `⋮` separators between hunks.

```swift
let patch = """
diff --git a/Foo.swift b/Foo.swift
index 1111111..2222222 100644
--- a/Foo.swift
+++ b/Foo.swift
@@ -1,3 +1,3 @@
-let a = 1
+let a = 2
"""

let output = try Chroma.highlight(
    patch,
    language: .swift,
    options: .init(diff: .patch())
)
print(output)
```

Verbose (full patch headers):

```swift
let output = try Chroma.highlight(
    patch,
    language: .swift,
    options: .init(diff: .patch(presentation: .verbose))
)
```

Foreground-only diff (plain text, no token styling):

```swift
let output = try Chroma.highlight(
    patch,
    language: .swift,
    options: .init(diff: .patch(style: .foreground()))
)
```

Foreground diff with syntax-highlighted context lines:

```swift
let output = try Chroma.highlight(
    patch,
    language: .swift,
    options: .init(diff: .patch(style: .foreground(contextCode: .syntax)))
)
```

Background diff without code styling:

```swift
let output = try Chroma.highlight(
    patch,
    language: .swift,
    options: .init(diff: .patch(style: .background(diffCode: .plain)))
)
```

## Custom languages

`Chroma` uses a regex-based tokenizer (similar to Prism / highlight.js) so new languages can be defined by rules.

```swift
var myLang = LanguageDefinition(
    id: "my-lang",
    displayName: "MyLang",
    rules: [
        try TokenRule(kind: .comment, pattern: "#[^\\n\\r]*"),
        try TokenRule.words(["let", "fn", "return"], kind: .keyword),
        try TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""),
    ]
)

let registry = LanguageRegistry.builtIn()
registry.register(myLang)

let highlighter = Highlighter(registry: registry)
let output = try highlighter.highlight("let x = 1", language: "my-lang")
```

## Notes

- This is an intentionally lightweight, console-focused highlighter.
- The built-in grammars are best-effort heuristics and will be refined over time.
