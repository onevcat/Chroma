public struct HighlightOptions: Equatable {
    public enum DiffHighlight: Equatable {
        case none
        case auto
        case patch
    }

    public var theme: Theme?
    public var diff: DiffHighlight
    public var highlightLines: LineRangeSet

    public init(
        theme: Theme? = nil,
        diff: DiffHighlight = .auto,
        highlightLines: LineRangeSet = .init()
    ) {
        self.theme = theme
        self.diff = diff
        self.highlightLines = highlightLines
    }
}

