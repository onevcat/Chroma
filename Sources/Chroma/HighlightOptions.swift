public struct LineNumberOptions: Equatable {
    public var isEnabled: Bool
    public var start: Int {
        didSet {
            if start < 1 {
                start = 1
            }
        }
    }

    public init(start: Int = 1) {
        self.isEnabled = true
        self.start = max(1, start)
    }

    private init(isEnabled: Bool, start: Int) {
        self.isEnabled = isEnabled
        self.start = max(1, start)
    }

    public static let none = LineNumberOptions(isEnabled: false, start: 1)
}

public struct HighlightOptions: Equatable {
    public enum MissingLanguageHandling: Equatable {
        case error
        case fallbackToPlainText
    }

    public enum DiffCodeStyle: Equatable {
        case syntax
        case plain
    }

    public enum DiffStyle: Equatable {
        case background(diffCode: DiffCodeStyle = .syntax, contextCode: DiffCodeStyle = .syntax)
        case foreground(contextCode: DiffCodeStyle = .plain)
    }

    public enum DiffPresentation: Equatable {
        case compact
        case verbose
    }

    public enum DiffHighlight: Equatable {
        case none
        case auto(style: DiffStyle = .background(), presentation: DiffPresentation = .compact)
        case patch(style: DiffStyle = .background(), presentation: DiffPresentation = .compact)
    }

    public var theme: Theme?
    /// Controls whether ANSI colors are emitted.
    public var colorMode: ColorMode
    public var missingLanguageHandling: MissingLanguageHandling
    public var diff: DiffHighlight
    public var highlightLines: LineRangeSet
    public var lineNumbers: LineNumberOptions
    public var indent: Int {
        didSet {
            if indent < 0 {
                indent = 0
            }
        }
    }

    public init(
        theme: Theme? = nil,
        colorMode: ColorMode = .auto(output: .stdout),
        missingLanguageHandling: MissingLanguageHandling = .error,
        diff: DiffHighlight = .auto(),
        highlightLines: LineRangeSet = .init(),
        lineNumbers: LineNumberOptions = .none,
        indent: Int = 0
    ) {
        self.theme = theme
        self.colorMode = colorMode
        self.missingLanguageHandling = missingLanguageHandling
        self.diff = diff
        self.highlightLines = highlightLines
        self.lineNumbers = lineNumbers
        self.indent = max(0, indent)
    }
}

extension HighlightOptions {
    struct DiffRendering: Equatable {
        let style: DiffStyle
        let presentation: DiffPresentation
    }

    var maySkipTokenization: Bool {
        switch diff {
        case .none:
            return false
        case let .auto(style, _), let .patch(style, _):
            return style.diffCodeStyle == .plain && style.contextCodeStyle == .plain
        }
    }

    func diffRendering(for code: String) -> DiffRendering? {
        diff.rendering(for: code)
    }

    func shouldSkipTokenization(for code: String) -> Bool {
        guard let rendering = diffRendering(for: code) else { return false }
        let style = rendering.style
        return style.diffCodeStyle == .plain && style.contextCodeStyle == .plain
    }
}

extension HighlightOptions.DiffHighlight {
    func rendering(for code: String) -> HighlightOptions.DiffRendering? {
        switch self {
        case .none:
            return nil
        case let .patch(style, presentation):
            return HighlightOptions.DiffRendering(style: style, presentation: presentation)
        case let .auto(style, presentation):
            guard DiffDetector.looksLikePatch(code) else { return nil }
            return HighlightOptions.DiffRendering(style: style, presentation: presentation)
        }
    }

    func rendering(for lines: [Substring]) -> HighlightOptions.DiffRendering? {
        switch self {
        case .none:
            return nil
        case let .patch(style, presentation):
            return HighlightOptions.DiffRendering(style: style, presentation: presentation)
        case let .auto(style, presentation):
            guard DiffDetector.looksLikePatch(lines: lines) else { return nil }
            return HighlightOptions.DiffRendering(style: style, presentation: presentation)
        }
    }
}

extension HighlightOptions.DiffStyle {
    var diffCodeStyle: HighlightOptions.DiffCodeStyle {
        switch self {
        case let .background(diffCode, _):
            return diffCode
        case .foreground:
            return .plain
        }
    }

    var contextCodeStyle: HighlightOptions.DiffCodeStyle {
        switch self {
        case let .background(_, contextCode):
            return contextCode
        case let .foreground(contextCode):
            return contextCode
        }
    }
}
