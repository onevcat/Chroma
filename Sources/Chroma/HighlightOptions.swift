public struct HighlightOptions: Equatable {
    public enum DiffCodeStyle: Equatable {
        case syntax
        case plain
    }

    public enum DiffStyle: Equatable {
        case background(diffCode: DiffCodeStyle = .syntax, contextCode: DiffCodeStyle = .syntax)
        case foreground(contextCode: DiffCodeStyle = .plain)
    }

    public enum DiffHighlight: Equatable {
        case none
        case auto(style: DiffStyle = .background())
        case patch(style: DiffStyle = .background())
    }

    public var theme: Theme?
    public var diff: DiffHighlight
    public var highlightLines: LineRangeSet
    public var indent: Int {
        didSet {
            if indent < 0 {
                indent = 0
            }
        }
    }

    public init(
        theme: Theme? = nil,
        diff: DiffHighlight = .auto(),
        highlightLines: LineRangeSet = .init(),
        indent: Int = 0
    ) {
        self.theme = theme
        self.diff = diff
        self.highlightLines = highlightLines
        self.indent = max(0, indent)
    }
}

extension HighlightOptions {
    struct DiffRendering: Equatable {
        let style: DiffStyle
    }

    var maySkipTokenization: Bool {
        switch diff {
        case .none:
            return false
        case let .auto(style), let .patch(style):
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
        case let .patch(style):
            return HighlightOptions.DiffRendering(style: style)
        case let .auto(style):
            guard DiffDetector.looksLikePatch(code) else { return nil }
            return HighlightOptions.DiffRendering(style: style)
        }
    }

    func rendering(for lines: [Substring]) -> HighlightOptions.DiffRendering? {
        switch self {
        case .none:
            return nil
        case let .patch(style):
            return HighlightOptions.DiffRendering(style: style)
        case let .auto(style):
            guard DiffDetector.looksLikePatch(lines: lines) else { return nil }
            return HighlightOptions.DiffRendering(style: style)
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
