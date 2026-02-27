# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.3.0] - 2026-02-27
### Added
- Support per-extension config overrides via `rules` in `~/.config/ca/config.json`.

### Changed
- Load `ca` config via `Codable`/`JSONDecoder` (supports structured config and removes the `swift-configuration` dependency).

### Fixed
- Fix release check CLI path.

## [0.2.0] - 2026-01-04
### Added
- Highlight JSON keys as properties in the built-in JSON highlighter.

### Changed
- Use an external pager (less) with fallback for ca output paging.
- Extract CaCore for shared ca implementation and tests.

## [0.1.1] - 2026-01-03
### Added
- Homebrew tap support for `ca`, with automated bottle publishing.

## [0.1.0] - 2026-01-03
### Added
- Initial public release.
