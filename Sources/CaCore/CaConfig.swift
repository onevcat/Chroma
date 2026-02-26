import ArgumentParser
import Chroma
import Foundation

/// Effective config after parsing config.json + defaults.
///
/// Notes:
/// - `paging` and `headers` are output-level settings (not per file).
/// - `rules` are evaluated per input file and can override render-level settings like `lineNumbers` and `theme`.
struct CaConfig: Equatable {
    struct ThemeSelection: Equatable {
        var name: String?
        var appearance: ThemeAppearancePreference
    }

    struct Rule: Equatable {
        struct Match: Equatable {
            /// File extensions (without leading dot), e.g. ["md", "swift"].
            ///
            /// Reserved for future: we may add `languageID` matching here.
            var ext: Set<String>

            func matches(_ input: InputFile) -> Bool {
                guard let path = input.path else { return false }
                let rawExt = URL(fileURLWithPath: path).pathExtension
                guard !rawExt.isEmpty else { return false }
                return ext.contains(rawExt.lowercased())
            }
        }

        struct Overrides: Equatable {
            var lineNumbers: Bool?
            var themeName: String?
            var themeAppearance: ThemeAppearancePreference?
        }

        var match: Match
        var overrides: Overrides

        func apply(to config: inout CaConfig, for input: InputFile) {
            guard match.matches(input) else { return }
            if let lineNumbers = overrides.lineNumbers {
                config.lineNumbers = lineNumbers
            }
            if let name = overrides.themeName {
                config.theme.name = name
            }
            if let appearance = overrides.themeAppearance {
                config.theme.appearance = appearance
            }
        }
    }

    var theme: ThemeSelection
    var lineNumbers: Bool
    var paging: PagingMode
    var headers: Bool
    var rules: [Rule]

    static let `default` = CaConfig(
        theme: .init(name: nil, appearance: .auto),
        lineNumbers: true,
        paging: .auto,
        headers: true,
        rules: []
    )

    /// Returns an effective per-file config by applying `rules` in order.
    ///
    /// Rule precedence: later rules win (last match wins).
    func effectiveConfig(for input: InputFile) -> CaConfig {
        var config = self
        for rule in rules {
            rule.apply(to: &config, for: input)
        }
        return config
    }
}

enum ThemeAppearancePreference: String, Codable {
    case auto
    case dark
    case light
}

enum PagingMode: String, CaseIterable, Codable {
    case auto
    case always
    case never
}

extension PagingMode: ExpressibleByArgument {}
