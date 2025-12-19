import Foundation
import Rainbow
import Testing
@testable import Chroma

enum TestThemes {
    static let stable = Theme(
        name: "test-stable",
        tokenStyles: [
            .plain: .init(),
            .keyword: .init(foreground: .named(.red), styles: [.bold]),
            .type: .init(foreground: .named(.green)),
            .number: .init(foreground: .named(.yellow)),
            .string: .init(foreground: .named(.blue)),
            .comment: .init(foreground: .named(.cyan), styles: [.dim]),
            .function: .init(foreground: .named(.magenta)),
            .property: .init(foreground: .named(.lightBlue)),
            .punctuation: .init(foreground: .named(.lightBlack)),
            .operator: .init(foreground: .named(.lightMagenta)),
        ],
        lineHighlightBackground: .named(.lightYellow),
        diffAddedBackground: .named(.lightGreen),
        diffRemovedBackground: .named(.lightRed)
    )
}

struct ExpectedToken: Equatable {
    let kind: TokenKind
    let text: String
    let background: BackgroundColorType?

    init(_ kind: TokenKind, _ text: String, background: BackgroundColorType? = nil) {
        self.kind = kind
        self.text = text
        self.background = background
    }

    static func plain(_ text: String) -> ExpectedToken {
        ExpectedToken(.plain, text)
    }
}

private enum RainbowToggle {
    static let lock = NSLock()
    static var depth = 0
    static var previousEnabled = true
}

func withRainbowEnabled<T>(_ enabled: Bool = true, _ body: () throws -> T) rethrows -> T {
    RainbowToggle.lock.lock()
    if RainbowToggle.depth == 0 {
        RainbowToggle.previousEnabled = Rainbow.enabled
        Rainbow.enabled = enabled
    } else if enabled {
        Rainbow.enabled = true
    }
    RainbowToggle.depth += 1
    RainbowToggle.lock.unlock()

    defer {
        RainbowToggle.lock.lock()
        RainbowToggle.depth -= 1
        if RainbowToggle.depth == 0 {
            Rainbow.enabled = RainbowToggle.previousEnabled
        }
        RainbowToggle.lock.unlock()
    }

    return try body()
}

func renderExpected(_ tokens: [ExpectedToken], theme: Theme = TestThemes.stable) -> String {
    withRainbowEnabled(true) {
        let segments = tokens.map { token in
            theme.style(for: token.kind).makeSegment(text: token.text, backgroundOverride: token.background)
        }
        return AnsiStringGenerator.generate(for: Rainbow.Entry(segments: segments))
    }
}

func assertGolden(
    _ code: String,
    language: LanguageID,
    expected: [ExpectedToken],
    options: HighlightOptions = .init(),
    theme: Theme = TestThemes.stable
) throws {
    var options = options
    options.theme = theme
    let output = try highlightWithTestTheme(code, language: language, options: options)
    let expectedOutput = renderExpected(expected, theme: theme)
    #expect(output == expectedOutput)
}

func highlightWithTestTheme(
    _ code: String,
    language: LanguageID,
    registry: LanguageRegistry = .builtIn(),
    options: HighlightOptions = .init()
) throws -> String {
    let theme = TestThemes.stable
    let highlighter = Highlighter(theme: theme, registry: registry)
    var options = options
    if options.theme == nil {
        options.theme = theme
    }
    return try withRainbowEnabled(true) {
        try highlighter.highlight(code, language: language, options: options)
    }
}
