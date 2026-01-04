import Chroma
import ChromaBase46Themes
import Foundation

struct ThemeResolver {
    func resolve(using config: CaConfig) -> Theme {
        let appearance = resolveAppearance(using: config)
        if let name = config.theme.name {
            if let theme = resolveNamedTheme(name) {
                return theme
            }
            Diagnostics.printError("Unknown theme: \(name). Falling back to \(appearance == .light ? "light" : "dark") theme.")
        }
        switch appearance {
        case .light:
            return .light
        case .dark, .unspecified:
            return .dark
        }
    }

    private func resolveAppearance(using config: CaConfig) -> ThemeAppearance {
        switch config.theme.appearance {
        case .dark:
            return .dark
        case .light:
            return .light
        case .auto:
            return TerminalThemeDetector.detectAppearance() ?? .unspecified
        }
    }

    private func resolveNamedTheme(_ name: String) -> Theme? {
        let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalized.isEmpty {
            return nil
        }
        switch normalized.lowercased() {
        case "dark":
            return .dark
        case "light":
            return .light
        default:
            break
        }
        if let theme = Base46Themes.theme(named: normalized) {
            return theme
        }
        let lowercased = normalized.lowercased()
        return Base46Themes.all.first { $0.name.lowercased() == lowercased }
    }
}

enum TerminalThemeDetector {
    static func detectAppearance() -> ThemeAppearance? {
        if let colorfgbg = ProcessInfo.processInfo.environment["COLORFGBG"] {
            if let appearance = appearanceFromColorFgBg(colorfgbg) {
                return appearance
            }
        }
        return nil
    }

    private static func appearanceFromColorFgBg(_ value: String) -> ThemeAppearance? {
        let parts = value.split(separator: ";").map(String.init)
        guard let last = parts.last, let bg = Int(last) else { return nil }
        return bg <= 6 ? .dark : .light
    }
}
