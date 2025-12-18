# TODO

## High priority

- Improve diff rendering: dedicated styling for `diff --git`, `@@` hunk headers, `---/+++` file headers.
- Provide capture-group based rules (Prism-like) for better variable/type/function classification.
- Add more language aliases and common file-type IDs (e.g. `json`, `yaml`, `bash`, `diff`).

## Testing

- Add snapshot-style golden tests for a small set of inputs per language.
- Add tests for line highlighting + diff interplay (precedence and off-by-one cases).

## Tooling / Release

- Add GitHub Actions workflow (`swift test` on macOS + Linux).
- Decide on license + versioning strategy.
- Add a changelog and release notes automation.

