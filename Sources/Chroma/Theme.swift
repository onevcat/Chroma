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

    public init(
        name: String,
        tokenStyles: [TokenKind: TextStyle],
        lineHighlightBackground: BackgroundColorType,
        diffAddedBackground: BackgroundColorType,
        diffRemovedBackground: BackgroundColorType
    ) {
        self.name = name
        self.tokenStyles = tokenStyles
        self.lineHighlightBackground = lineHighlightBackground
        self.diffAddedBackground = diffAddedBackground
        self.diffRemovedBackground = diffRemovedBackground
    }

    public func style(for kind: TokenKind) -> TextStyle {
        tokenStyles[kind] ?? tokenStyles[.plain] ?? .init()
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
            .comment: .init(foreground: .named(.lightBlack), styles: [.dim]),
            .function: .init(foreground: .named(.lightBlue)),
            .property: .init(foreground: .named(.cyan)),
            .punctuation: .init(foreground: .named(.lightWhite)),
            .operator: .init(foreground: .named(.lightWhite)),
        ],
        lineHighlightBackground: .named(.lightBlack),
        diffAddedBackground: .named(.green),
        diffRemovedBackground: .named(.red)
    )

    static let light = Theme(
        name: "light",
        tokenStyles: [
            .plain: .init(),
            .keyword: .init(foreground: .named(.magenta), styles: [.bold]),
            .type: .init(foreground: .named(.blue)),
            .number: .init(foreground: .named(.yellow)),
            .string: .init(foreground: .named(.green)),
            .comment: .init(foreground: .named(.lightBlack), styles: [.dim]),
            .function: .init(foreground: .named(.blue)),
            .property: .init(foreground: .named(.cyan)),
            .punctuation: .init(foreground: .named(.black)),
            .operator: .init(foreground: .named(.black)),
        ],
        lineHighlightBackground: .named(.lightYellow),
        diffAddedBackground: .named(.lightGreen),
        diffRemovedBackground: .named(.lightRed)
    )
}

