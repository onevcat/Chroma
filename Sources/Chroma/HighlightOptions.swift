public struct HighlightOptions: Equatable {
    public enum DiffHighlight: Equatable {
        case none
        case auto
        case patch
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
        diff: DiffHighlight = .auto,
        highlightLines: LineRangeSet = .init(),
        indent: Int = 0
    ) {
        self.theme = theme
        self.diff = diff
        self.highlightLines = highlightLines
        self.indent = max(0, indent)
    }
}
