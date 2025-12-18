# Chroma Design Notes

This document captures the initial design decisions for `Chroma`, so future iterations can stay consistent.

## Goals

- Provide a small, fast-enough, dependency-light syntax highlighter for terminal output.
- Keep the public API Swifty and easy to integrate into Swift-based TUI / CLI apps.
- Allow both built-in languages/themes and user-defined extensions (languages, keywords, themes).

## Non-goals (initially)

- Full, spec-accurate parsing (AST-level correctness) for each language.
- Advanced embedded languages (e.g. HTML with inline JS/CSS), template interpolation parsing, etc.
- Perfect semantic classification (variable vs property vs type) beyond heuristics.

## Tokenization approach

`Chroma` uses a regex-based tokenizer, broadly aligned with the core approach used by popular JS highlighters:

- **PrismJS** uses language grammars defined by regular expressions, producing a token stream.
- **highlight.js** uses a mode-based, regex-driven lexer.

This approach is a pragmatic trade-off for terminal highlighting:

- Easy to implement and extend (add rules/keywords).
- Fast enough for most console scenarios.
- Avoids pulling in heavyweight parsers per language.

### Engine behavior

- At each position, all rules are attempted with an anchored match.
- The longest match wins (ties favor earlier rules).
- If no rule matches, `Chroma` advances by one composed character and emits a `.plain` token.
- Adjacent tokens with the same kind are coalesced to reduce output segments.

## Rendering

`Chroma` renders tokens into ANSI sequences using `Rainbow` by constructing a `Rainbow.Entry` with segments:

- Each token becomes one or more segments (split by `\\n`) so line-level backgrounds can be applied.
- Each segment is reset by `Rainbow` (`CSI 0m`) to avoid leaking styles.

## Themes

- A `Theme` maps `TokenKind -> TextStyle`.
- Two built-ins are provided: `.dark` and `.light`.
- `TextStyle` is a thin wrapper around `Rainbow` types (`ColorType`, `BackgroundColorType`, `Style`).

## Diff highlighting

Diff highlighting is line-based:

- In `.auto`, it activates only if the text *looks like* a unified patch (e.g. `diff --git`, `@@`, `---/+++`).
- In `.patch`, it is always enabled.
- In `.none`, it is disabled.

When enabled:

- Lines starting with `+` (but not `+++ `) receive `Theme.diffAddedBackground`.
- Lines starting with `-` (but not `--- `) receive `Theme.diffRemovedBackground`.

Decision: `highlightLines` background overrides diff background if both apply.

## Extensibility

Users can:

- Register new languages via `LanguageRegistry.register`.
- Override built-in languages by re-registering the same `LanguageID` with `overwrite: true`.
- Add keywords/types by appending `TokenRule.words` rules.

## Known limitations (to revisit)

- Grammars are intentionally shallow; some constructs (raw strings, nested comments, generics) are best-effort.
- No capture-group token styling (e.g. highlight only the identifier part of `let name = ...`).
- Diff support does not try to strip `+`/`-` prefixes before tokenization.

