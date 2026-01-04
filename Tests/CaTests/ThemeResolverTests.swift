import Chroma
import Testing
@testable import Ca

@Suite("ThemeResolver")
struct ThemeResolverTests {
    @Test("Named theme overrides appearance")
    func namedThemeOverridesAppearance() {
        var config = CaConfig.default
        config.theme = .init(name: "dark", appearance: .light)

        let theme = ThemeResolver().resolve(using: config)
        #expect(theme == .dark)
    }

    @Test("Named theme trims whitespace and ignores case")
    func namedThemeTrimsWhitespace() {
        var config = CaConfig.default
        config.theme = .init(name: "  LiGhT  ", appearance: .dark)

        let theme = ThemeResolver().resolve(using: config)
        #expect(theme == .light)
    }

    @Test("Unknown theme falls back to appearance")
    func unknownThemeFallsBack() {
        var config = CaConfig.default
        config.theme = .init(name: "unknown-theme", appearance: .light)

        let theme = ThemeResolver().resolve(using: config)
        #expect(theme == .light)
    }

    @Test("Auto appearance uses COLORFGBG when available")
    func autoAppearanceUsesColorFgBg() {
        var config = CaConfig.default
        config.theme = .init(name: nil, appearance: .auto)

        withEnvironment("COLORFGBG", value: "15;0") {
            let theme = ThemeResolver().resolve(using: config)
            #expect(theme.appearance == .dark)
        }

        withEnvironment("COLORFGBG", value: "15;8") {
            let theme = ThemeResolver().resolve(using: config)
            #expect(theme.appearance == .light)
        }
    }

    @Test("TerminalThemeDetector ignores invalid COLORFGBG")
    func terminalThemeDetectorIgnoresInvalid() {
        withEnvironment("COLORFGBG", value: "invalid") {
            #expect(TerminalThemeDetector.detectAppearance() == nil)
        }
    }
}
