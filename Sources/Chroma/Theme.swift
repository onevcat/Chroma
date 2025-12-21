import Rainbow

public struct Theme: Equatable {
    public var name: String
    public var tokenStyles: [TokenKind: TextStyle]

    /// Background used by `HighlightOptions.highlightLines`.
    public var lineHighlightBackground: BackgroundColorType

    /// Background used by `HighlightOptions.diff` for added lines.
    public var diffAddedBackground: BackgroundColorType

    /// Background used by `HighlightOptions.diff` for removed lines.
    public var diffRemovedBackground: BackgroundColorType

    /// Foreground used by `HighlightOptions.diff` for added lines.
    public var diffAddedForeground: ColorType

    /// Foreground used by `HighlightOptions.diff` for removed lines.
    public var diffRemovedForeground: ColorType

    /// Foreground used by `HighlightOptions.lineNumbers`.
    public var lineNumberForeground: ColorType

    public init(
        name: String,
        tokenStyles: [TokenKind: TextStyle],
        lineHighlightBackground: BackgroundColorType,
        diffAddedBackground: BackgroundColorType,
        diffRemovedBackground: BackgroundColorType,
        diffAddedForeground: ColorType,
        diffRemovedForeground: ColorType,
        lineNumberForeground: ColorType
    ) {
        self.name = name
        self.tokenStyles = tokenStyles
        self.lineHighlightBackground = lineHighlightBackground
        self.diffAddedBackground = diffAddedBackground
        self.diffRemovedBackground = diffRemovedBackground
        self.diffAddedForeground = diffAddedForeground
        self.diffRemovedForeground = diffRemovedForeground
        self.lineNumberForeground = lineNumberForeground
    }

    public func style(for kind: TokenKind) -> TextStyle {
        tokenStyles[kind] ?? tokenStyles[.plain] ?? .init()
    }

    func makeStyleCache() -> StyleCache {
        StyleCache(tokenStyles: tokenStyles)
    }
}

extension Theme {
    struct StyleCache {
        private let styles: [TokenKind: TextStyle]
        private let defaultStyle: TextStyle

        init(tokenStyles: [TokenKind: TextStyle]) {
            self.styles = tokenStyles
            self.defaultStyle = tokenStyles[.plain] ?? .init()
        }

        func style(for kind: TokenKind) -> TextStyle {
            styles[kind] ?? defaultStyle
        }
    }
}

public extension Theme {
    static let dark = Theme(
        name: "dark",
        tokenStyles: [
            .plain: .init(),
            .keyword: .init(foreground: .named(.lightMagenta), styles: [.bold]),
            .type: .init(foreground: .named(.lightCyan)),
            .number: .init(foreground: .named(.lightYellow)),
            .string: .init(foreground: .named(.lightGreen)),
            .comment: .init(foreground: .named(.white), styles: [.dim]),
            .function: .init(foreground: .named(.lightBlue)),
            .property: .init(foreground: .named(.cyan)),
            .punctuation: .init(foreground: .named(.lightWhite)),
            .operator: .init(foreground: .named(.lightWhite)),
        ],
        lineHighlightBackground: .named(.lightBlack),
        diffAddedBackground: .named(.green),
        diffRemovedBackground: .named(.red),
        diffAddedForeground: .named(.lightGreen),
        diffRemovedForeground: .named(.lightRed),
        lineNumberForeground: .named(.white)
    )

    static let light = Theme(
        name: "light",
        tokenStyles: [
            .plain: .init(),
            .keyword: .init(foreground: .named(.magenta), styles: [.bold]),
            .type: .init(foreground: .named(.blue)),
            .number: .init(foreground: .named(.yellow)),
            .string: .init(foreground: .named(.green)),
            .comment: .init(foreground: .named(.black), styles: [.dim]),
            .function: .init(foreground: .named(.blue)),
            .property: .init(foreground: .named(.cyan)),
            .punctuation: .init(foreground: .named(.black)),
            .operator: .init(foreground: .named(.black)),
        ],
        lineHighlightBackground: .named(.lightYellow),
        diffAddedBackground: .named(.lightGreen),
        diffRemovedBackground: .named(.lightRed),
        diffAddedForeground: .named(.green),
        diffRemovedForeground: .named(.red),
        lineNumberForeground: .named(.black)
    )
}
