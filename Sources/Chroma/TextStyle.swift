import Rainbow

public struct TextStyle: Equatable {
    public var foreground: ColorType?
    public var background: BackgroundColorType?
    public var styles: [Style]?

    public init(
        foreground: ColorType? = nil,
        background: BackgroundColorType? = nil,
        styles: [Style]? = nil
    ) {
        self.foreground = foreground
        self.background = background
        self.styles = styles
    }

    func makeSegment(
        text: String,
        foregroundOverride: ColorType? = nil,
        backgroundOverride: BackgroundColorType? = nil
    ) -> Rainbow.Segment {
        Rainbow.Segment(
            text: text,
            color: foregroundOverride ?? foreground,
            backgroundColor: backgroundOverride ?? background,
            styles: styles
        )
    }
}
