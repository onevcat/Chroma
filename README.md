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

### Inferring Language IDs

Infer a language from file names, paths, or URLs:

```swift
let language = LanguageID.fromFileName("MyFile.swift")
let output = try Chroma.highlight(code, language: language)
```

`language` is optional; passing `nil` skips syntax highlighting and returns the original text.

Fallback to plain text when the language is unavailable:

```swift
let options = HighlightOptions(missingLanguageHandling: .fallbackToPlainText)
let output = try Chroma.highlight(code, language: "unknown", options: options)
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

Chroma also offers an optional `ChromaBase46Themes` module with Base46 theme presets
([all themes](Sources/ChromaBase46Themes/Base46ThemeAccessors.swift)):

```swift
import ChromaBase46Themes

let theme = Base46Themes.rosepineDawn
// Or resolve by name: Base46Themes.theme(named: "rosepine-dawn")
let output3 = try Chroma.highlight(
    code,
    language: .swift,
    options: .init(theme: theme)
)
```

List all Base46 theme names:

```swift
import ChromaBase46Themes

let allThemes = Base46Themes.all
let names = allThemes.map(\.name).sorted()
print(names.joined(separator: "\n"))
```

Filter Base46 themes by appearance:

```swift
import ChromaBase46Themes

let darkThemes = Base46Themes.all.filter { $0.appearance == .dark }
let lightThemes = Base46Themes.all.filter { $0.appearance == .light }
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

### Color Output

Chroma defaults to auto-detecting ANSI output based on TTY, `TERM=dumb`, and common environment variables (`NO_COLOR`, `CHROMA_NO_COLOR`, `FORCE_COLOR`).

```swift
// Force ANSI output
let output = try Chroma.highlight(
    code,
    language: .swift,
    options: .init(colorMode: .always)
)

// Auto-detect for stderr output
let output = try Chroma.highlight(
    code,
    language: .swift,
    options: .init(colorMode: .auto(output: .stderr))
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
let patch = """
diff --git a/UserService.swift b/UserService.swift
index 1111111..2222222 100644
--- a/UserService.swift
+++ b/UserService.swift
@@ -5,7 +5,7 @@
     let id: Int
     let name: String
     let email: String
-    let isActive: Bool
+    var isActive: Bool
 }

 struct UserService {
@@ -14,8 +14,8 @@ struct UserService {
         return users.filter { $0.isActive }
     }

-    func findUser(id: Int) -> User? {
+    func find(id: Int) -> User? {
         users.first { $0.id == id }
     }
 }
"""

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
        try TokenRule.words(["let", "fn", "return", "if", "else", "while"], kind: .keyword),
        try TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""),
        try TokenRule(kind: .number, pattern: "\\b\\d+\\b"),
    ]
)

let registry = LanguageRegistry.builtIn()
registry.register(myLang)

let highlighter = Highlighter(registry: registry)
let code = """
# Calculate factorial
fn factorial(n) {
    if n <= 1 {
        return 1
    }
    return n * factorial(n - 1)
}

let result = factorial(5)
"""
let output = try highlighter.highlight(code, language: "my-lang")
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
        .keyword: .init(foreground: .named(.yellow), styles: [.bold]),
        .string: .init(foreground: .named(.red)),
        .comment: .init(foreground: .named(.lightGreen), styles: [.dim]),
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

You can also use [Rainbow's extended color modes](https://github.com/onevcat/Rainbow?tab=readme-ov-file#ansi-256-color-mode) for more color options:

```swift
.tokenStyles: [
    .keyword: .init(foreground: .bit8(226)),            // 256-color mode
    .string: .init(foreground: .bit24((255, 107, 107))), // Truecolor RGB tuple
]
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
