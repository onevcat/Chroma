import Chroma
import Rainbow

public enum Base46Themes {
    static let themes: [Theme] = base46ThemeData.map(Base46ThemeBuilder.build)
    static let themeByName: [String: Theme] = Dictionary(
        uniqueKeysWithValues: themes.map { ($0.name, $0) }
    )

    public static var all: [Theme] {
        themes
    }

    public static func theme(named name: String) -> Theme? {
        themeByName[name]
    }
}

struct Base16Palette: Equatable {
    let base00: Int
    let base01: Int
    let base02: Int
    let base03: Int
    let base04: Int
    let base05: Int
    let base06: Int
    let base07: Int
    let base08: Int
    let base09: Int
    let base0A: Int
    let base0B: Int
    let base0C: Int
    let base0D: Int
    let base0E: Int
    let base0F: Int
}

struct Base46ThemeDefinition: Equatable {
    let name: String
    let appearance: ThemeAppearance
    let base16: Base16Palette
    let base30: [String: Int]
    let diffAddedBackground: Int
    let diffRemovedBackground: Int
}

private enum Base46ThemeBuilder {
    static func build(from definition: Base46ThemeDefinition) -> Theme {
        let base16 = definition.base16
        let base30 = definition.base30

        func pick(_ keys: [String], fallback: Int) -> Int {
            for key in keys {
                if let value = base30[key] {
                    return value
                }
            }
            return fallback
        }

        let lineHighlightBackground = pick(
            ["line", "one_bg2", "one_bg", "lightbg", "lightbg2", "black2", "lighter_black"],
            fallback: base16.base02
        )
        let lineNumberForeground = pick(
            ["grey", "grey_fg", "grey_fg2", "light_grey", "lightgray", "faded_grey"],
            fallback: base16.base04
        )
        let diffAddedBackground = definition.diffAddedBackground
        let diffRemovedBackground = definition.diffRemovedBackground
        let diffAddedForeground = pick(
            ["green", "vibrant_green", "soft_green", "green1"],
            fallback: base16.base0B
        )
        let diffRemovedForeground = pick(
            ["red", "firered", "tintred", "brownred"],
            fallback: base16.base08
        )

        return Theme(
            name: definition.name,
            appearance: definition.appearance,
            tokenStyles: [
                .plain: .init(foreground: foreground(base16.base05)),
                .keyword: .init(foreground: foreground(base16.base0E)),
                .type: .init(foreground: foreground(base16.base0A)),
                .number: .init(foreground: foreground(base16.base09)),
                .string: .init(foreground: foreground(base16.base0B)),
                .comment: .init(foreground: foreground(base16.base03), styles: [.dim]),
                .function: .init(foreground: foreground(base16.base0D)),
                .property: .init(foreground: foreground(base16.base08)),
                .punctuation: .init(foreground: foreground(base16.base05)),
                .operator: .init(foreground: foreground(base16.base05)),
            ],
            lineHighlightBackground: background(lineHighlightBackground),
            diffAddedBackground: background(diffAddedBackground),
            diffRemovedBackground: background(diffRemovedBackground),
            diffAddedForeground: foreground(diffAddedForeground),
            diffRemovedForeground: foreground(diffRemovedForeground),
            lineNumberForeground: foreground(lineNumberForeground)
        )
    }

    private static func foreground(_ hex: Int) -> ColorType {
        .bit24((
            UInt8((hex >> 16) & 0xff),
            UInt8((hex >> 8) & 0xff),
            UInt8(hex & 0xff)
        ))
    }

    private static func background(_ hex: Int) -> BackgroundColorType {
        .bit24((
            UInt8((hex >> 16) & 0xff),
            UInt8((hex >> 8) & 0xff),
            UInt8(hex & 0xff)
        ))
    }
}
