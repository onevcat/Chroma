# Chroma

`Chroma` is a Swift package for syntax highlighting code in terminal output (TUI / CLI apps).

It takes a code string plus a language identifier (e.g. Swift / JavaScript / C#), and returns an ANSI-colored string.
ANSI styling is generated via [`Rainbow`](https://github.com/onevcat/Rainbow).

## Features

- Built-in languages: Swift, Objective-C, C, JavaScript, TypeScript, Python, Ruby, Go, Rust, Kotlin, C#
- Built-in themes: `Theme.dark` and `Theme.light`
- Custom language registration (`LanguageRegistry`)
- Custom themes (`Theme`)
- Line highlighting via `HighlightOptions.highlightLines`
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

### Themes

```swift
let output = try Chroma.highlight(
    code,
    language: .swift,
    options: .init(theme: .light)
)
```

### Highlight lines

Line numbers are 1-based.

```swift
let output = try Chroma.highlight(
    code,
    language: .swift,
    options: .init(highlightLines: [2...3, 6...6])
)
```

### Diff highlighting (unified patch)

`Chroma` can highlight `+` / `-` lines with green / red background, following the common `git diff` patch rules.

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
    options: .init(diff: .patch)
)
print(output)
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
