# TODO

## High priority

-[ ] Support to display line number. API allows to input the first line number.
    Number alignment should be considered. Example:
    ```
    1 some code
    2 other code
    ...
   10 later in the input
    ...
  234 ...
 1234 ...
    ```
    align to right, consider the largest number.

-[ ] Improve diff rendering: dedicated styling for `diff --git`, `@@` hunk headers, `---/+++` file headers.
-[ ] Improve diff rendering: leveled highlight for inline diff:
    Example:
    ```diff
 - hello world
 + hello world!
    ```
    displays red background for the first line and green background for the second line, with a brighter green background at the `!`
-[ ] Option for diff style. Let user choose:
    - Font or background: choose to render the diff at background colors, or to change font color.
    - Highlight the code or not when background colors.
-[ ] Provide capture-group based rules (Prism-like) for better variable/type/function classification.
-[ ] Add more language aliases and common file-type IDs (e.g. `json`, `yaml`, `bash`, `diff`).

## Testing

-[ ] Add snapshot-style golden tests for a small set of inputs per language.
-[ ] Add tests for line highlighting + diff interplay (precedence and off-by-one cases).

## Tooling / Release

-[ ] Decide on license + versioning strategy.
-[ ] Add a changelog and release notes automation.

