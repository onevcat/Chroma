![](https://github.com/user-attachments/assets/36afa20e-265c-4a00-bb54-d6a9e4954ba0)

# Chroma

**Chroma** is a Swift package for syntax highlighting code in terminal output. It takes a code string plus a language identifier, and returns an ANSI-colored string ready for printing in your TUI or CLI application.

ANSI styling is powered by [`Rainbow`](https://github.com/onevcat/Rainbow).

## Features

- **30+ Built-in Languages** — Includes almost all popular languages. [See all languages](Sources/Chroma/BuiltInLanguages).

- **High Performance** — Minimal memory footprint with fast tokenization using optimized regex-based scanning and keyword fast-path lookups.

- **Flexible Highlighting** — Built-in support for line highlighting with background colors, line numbers, and output indentation.

- **Diff Highlighting** — Automatic detection and rendering of unified patches with configurable styles (foreground/background) and presentation modes (compact/verbose).

- **Customizable** — Register custom languages via `LanguageRegistry` and define custom themes with full control over token styles and colors.

## Usage

### Quick Start

```swift
import Chroma

let code = """
struct User {
    let id: Int
    let name: String
}
"""

let output = try Chroma.highlight(code, language: .swift)
print(output)
```

### Running the Demo

Clone the repository and run the built-in demo to see Chroma in action:

```bash
git clone https://github.com/onevcat/Chroma.git
cd Chroma
swift run ChromaDemo --lang swift
# Or use `--light` to apply the default light theme
# swift run ChromaDemo --lang swift --light
```

To list all supported languages:

```bash
swift run ChromaDemo --list-languages
```

### Installation

Add Chroma as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/onevcat/Chroma.git", from: "0.1.0")
]
```

Then add it to your target:

```swift
targets: [
    .target(
        name: "MyApp",
        dependencies: ["Chroma"]
    )
]
```

### Basic Usage

The simplest way to highlight code:

```swift
import Chroma

let code = "let x = 42"
let output = try Chroma.highlight(code, language: .swift)
print(output)
```

### Themes

Chroma includes two built-in themes:

```swift
// Use the dark theme (default)
let output1 = try Chroma.highlight(code, language: .swift)

// Use the light theme
let output2 = try Chroma.highlight(
    code,
    language: .swift,
    options: .init(theme: .light)
)
```

### Line Highlighting

Highlight specific lines with a background color:

```swift
let output = try Chroma.highlight(
    code,
    language: .swift,
    options: .init(highlightLines: [2...5, 10...12])
)
```

### Line Numbers

Add line numbers to the output:

```swift
let output = try Chroma.highlight(
    code,
    language: .swift,
    options: .init(lineNumbers: .init(start: 1))
)
```

### Output Indentation

Indent the entire output by a specified number of spaces:

```swift
let output = try Chroma.highlight(
    code,
    language: .swift,
    options: .init(indent: 4)
)
```

### Diff Highlighting

Chroma can highlight unified patches (like `git diff` output) automatically. It detects patch format and renders additions/deletions with appropriate styling.

#### Automatic Detection

```swift
let patch = """
diff --git a/File.swift b/File.swift
index 1111111..2222222 100644
--- a/File.swift
+++ b/File.swift
@@ -1,3 +1,3 @@
-let a = 1
+let a = 2
"""

// Automatically detected and highlighted
let output = try Chroma.highlight(patch, language: .swift)
```

#### Diff Styles

Configure how diffs are rendered:

```swift
// Background highlighting with syntax-colored code (default)
let output1 = try Chroma.highlight(
    patch,
    language: .swift,
    options: .init(diff: .patch(style: .background()))
)

// Foreground highlighting (red/green text only)
let output2 = try Chroma.highlight(
    patch,
    language: .swift,
    options: .init(diff: .patch(style: .foreground()))
)

// Foreground diff with syntax-highlighted context
let output3 = try Chroma.highlight(
    patch,
    language: .swift,
    options: .init(diff: .patch(style: .foreground(contextCode: .syntax)))
)
```

#### Diff Presentation

```swift
// Compact mode (default) - uses "⋮" separators between hunks
let output1 = try Chroma.highlight(
    patch,
    language: .swift,
    options: .init(diff: .patch(presentation: .compact))
)

// Verbose mode - shows full patch headers
let output2 = try Chroma.highlight(
    patch,
    language: .swift,
    options: .init(diff: .patch(presentation: .verbose))
)
```

### Using a Highlighter Instance

For more control, create a `Highlighter` instance:

```swift
import Chroma

let highlighter = Highlighter(theme: .dark)

let output1 = try highlighter.highlight(code1, language: .swift)
let output2 = try highlighter.highlight(code2, language: .python)
```

### Combining Options

```swift
let output = try Chroma.highlight(
    code,
    language: .swift,
    options: .init(
        theme: .light,
        highlightLines: [5...10],
        lineNumbers: .init(start: 1),
        indent: 2
    )
)
```

### Custom Languages

Register custom language definitions using regex-based token rules:

```swift
import Chroma

var myLang = LanguageDefinition(
    id: "my-lang",
    displayName: "MyLang",
    rules: [
        try TokenRule(kind: .comment, pattern: "#[^\\n\\r]*"),
        try TokenRule.words(["let", "fn", "return", "if", "else"], kind: .keyword),
        try TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""),
    ]
)

let registry = LanguageRegistry.builtIn()
registry.register(myLang)

let highlighter = Highlighter(registry: registry)
let output = try highlighter.highlight("let x = 1", language: "my-lang")
```

### Custom Themes

Define your own theme with full control over token styles:

```swift
import Chroma
import Rainbow

let customTheme = Theme(
    name: "custom",
    tokenStyles: [
        .plain: .init(foreground: .named(.white)),
        .keyword: .init(foreground: .named(.lightMagenta), styles: [.bold]),
        .string: .init(foreground: .named(.lightGreen)),
        .comment: .init(foreground: .named(.black), styles: [.dim]),
    ],
    lineHighlightBackground: .named(.lightBlack),
    diffAddedBackground: .named(.green),
    diffRemovedBackground: .named(.red),
    diffAddedForeground: .named(.lightGreen),
    diffRemovedForeground: .named(.lightRed),
    lineNumberForeground: .named(.white)
)

let highlighter = Highlighter(theme: customTheme)
let output = try highlighter.highlight(code, language: .swift)
```

## Advanced

### Tokenizing Only

To get tokens without rendering:

```swift
let tokens = try Chroma.tokenize(code, language: .swift)
```

### Streaming Tokens

For large files, process tokens as they are generated:

```swift
try Chroma.tokenize(code, language: .swift) { token in
    print(token.kind, token.range)
}
```

### Custom Rendering

Render pre-tokenized code with custom options:

```swift
let tokens = try Chroma.tokenize(code, language: .swift)
let output = Chroma.render(
    code,
    tokens: tokens,
    options: .init(theme: .light, lineNumbers: .init(start: 1))
)
```

## Benchmarks

To run performance benchmarks:

```bash
# Install jemalloc for memory tracking
brew install jemalloc

# Run benchmarks
swift package benchmark --target ChromaBenchmarks
```

On Ubuntu:

```bash
sudo apt-get update
sudo apt-get install -y libjemalloc-dev
swift package benchmark --target ChromaBenchmarks
```

If jemalloc is not available, memory stats will be skipped:

```bash
BENCHMARK_DISABLE_JEMALLOC=1 swift package benchmark --target ChromaBenchmarks
```

## License

MIT License (c) 2025 Wei Wang, [onevcat@gmail.com](mailto:onevcat@gmail.com)

## Related

- [`Rainbow`](https://github.com/onevcat/Rainbow) — String coloring for Swift that powers Chroma's ANSI output
