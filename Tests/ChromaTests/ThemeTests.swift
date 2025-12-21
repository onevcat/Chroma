import Rainbow
import Testing
@testable import Chroma

@Suite("Theme")
struct ThemeTests {
    @Test("style(for:) falls back to plain style")
    func styleFallback() {
        let theme = Theme(
            name: "fallback",
            tokenStyles: [
                .plain: .init(foreground: .named(.green))
            ],
            lineHighlightBackground: .named(.lightYellow),
            diffAddedBackground: .named(.lightGreen),
            diffRemovedBackground: .named(.lightRed),
            diffAddedForeground: .named(.green),
            diffRemovedForeground: .named(.red),
            lineNumberForeground: .named(.lightBlack)
        )

        let style = theme.style(for: .keyword)
        #expect(style == theme.style(for: .plain))
    }
}
