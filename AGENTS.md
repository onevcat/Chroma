# Repository Guidelines

## Project Structure & Module Organization

- `Sources/Chroma`: Core syntax highlighting library (tokenizer, themes, renderer).
- `Sources/ChromaDemo`: SwiftPM executable used for demo output.
- `Tests/ChromaTests`: Test suite using Swift Testing.
- `Package.swift`: SwiftPM manifest (products, targets, dependencies).
- `README.md`: Public usage examples and feature list.

## Build, Test, and Development Commands

- `swift build`: Compile the library and demo executable.
- `swift test`: Run the full test suite.
- `swift run ChromaDemo`: Print highlighted samples to the terminal.
- `swift package benchmark --target ChromaBenchmarks`: Run performance benchmarks (jemalloc recommended).
- `BENCHMARK_DISABLE_JEMALLOC=1 swift package benchmark --target ChromaBenchmarks`: Run benchmarks without jemalloc if it is not installed.

## Coding Style & Naming Conventions

- Indentation: 4 spaces, no tabs.
- Follow Swift API Design Guidelines; types in UpperCamelCase, functions/properties in lowerCamelCase.
- Keep file names aligned with primary types (e.g., `Highlighter.swift`).
- Public APIs use `///` doc comments when intent is non-obvious.
- No enforced formatter; keep formatting consistent with existing files.

## Testing Guidelines

- Tests use Swift Testing (`import Testing`) with `@Suite` and `@Test` annotations.
- Keep test names descriptive and behavior-focused (use the string labels on `@Test`).
- Add tests for changes that affect ANSI output, diff handling, or line highlighting.
- Run `swift test` before submitting changes.

## Commit & Pull Request Guidelines

- Commit messages are short, imperative, and capitalized (e.g., "Add ChromaDemo executable").
- PRs should include:
  - A brief summary of behavior changes.
  - Test commands run (e.g., `swift test`).
  - Updates to `README.md` when public API or usage changes.
  - Sample terminal output for changes that affect styling or colors.

## Configuration & Dependencies

- Swift 5.9+ (see `Package.swift`).
- External dependency: `Rainbow` for ANSI styling.
- Benchmarks use `package-benchmark`; install jemalloc for memory stats or set `BENCHMARK_DISABLE_JEMALLOC=1`.
- Supported platforms: macOS 13+, Linux.
