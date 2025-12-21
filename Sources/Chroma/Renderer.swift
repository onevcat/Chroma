import Foundation
import Rainbow

final class Renderer {
    private let theme: Theme
    private let options: HighlightOptions
    private let styleCache: Theme.StyleCache

    init(theme: Theme, options: HighlightOptions) {
        self.theme = theme
        self.options = options
        self.styleCache = theme.makeStyleCache()
    }

    func render(code: String, tokens: [Token]) -> String {
        return render(code: code, estimatedSegments: tokens.count) { emit in
            for token in tokens {
                emit(token)
            }
        }
    }

    func render(code: String, tokenStream: (_ emit: (Token) -> Void) -> Void) -> String {
        return render(code: code, estimatedSegments: nil, tokenStream: tokenStream)
    }

    private func render(
        code: String,
        estimatedSegments: Int?,
        tokenStream: (_ emit: (Token) -> Void) -> Void
    ) -> String {
        if !Rainbow.enabled && options.highlightLines.ranges.isEmpty && options.indent == 0 {
            if options.diff.rendering(for: code) == nil {
                return code
            }
        }

        let plan = makePlan(for: code)
        let ns = code as NSString
        let indentPrefix = makeIndentPrefix()
        let plainStyle = styleCache.style(for: .plain)

        var writer = AnsiWriter(
            estimatedTextLength: code.count,
            estimatedSegments: estimatedSegments ?? max(16, code.count / 8),
            isEnabled: Rainbow.enabled
        )

        var atLineStart = true
        if plan.hasLineOverrides {
            var currentLine = 1
            tokenStream { token in
                appendTokenSegments(
                    ns,
                    range: token.range,
                    kind: token.kind,
                    currentLine: &currentLine,
                    lineBackgrounds: plan.lineBackgrounds,
                    lineForegrounds: plan.lineForegrounds,
                    linePlainStyles: plan.linePlainStyles,
                    lineBreaks: plan.lineBreaks,
                    indentPrefix: indentPrefix,
                    plainStyle: plainStyle,
                    atLineStart: &atLineStart,
                    into: &writer
                )
            }
        } else {
            tokenStream { token in
                appendTokenSegmentsWithoutLineBackground(
                    ns,
                    range: token.range,
                    kind: token.kind,
                    indentPrefix: indentPrefix,
                    plainStyle: plainStyle,
                    atLineStart: &atLineStart,
                    into: &writer
                )
            }
        }

        return writer.finish()
    }

    private func appendTokenSegments(
        _ ns: NSString,
        range: NSRange,
        kind: TokenKind,
        currentLine: inout Int,
        lineBackgrounds: [BackgroundColorType?],
        lineForegrounds: [ColorType?],
        linePlainStyles: [Bool],
        lineBreaks: [Int],
        indentPrefix: String,
        plainStyle: TextStyle,
        atLineStart: inout Bool,
        into writer: inout AnsiWriter
    ) {
        guard range.length > 0 else { return }

        let end = range.location + range.length
        var location = range.location
        var lineIndex = currentLine - 1

        while location < end {
            let nextBreak = lineIndex < lineBreaks.count ? lineBreaks[lineIndex] : nil
            if let nextBreak, nextBreak < end {
                let pieceLength = nextBreak - location
                let background = backgroundForLine(currentLine, lineBackgrounds: lineBackgrounds)
                let foreground = foregroundForLine(currentLine, lineForegrounds: lineForegrounds)
                if pieceLength == 0 {
                    appendIndentIfNeeded(
                        indentPrefix: indentPrefix,
                        plainStyle: plainStyle,
                        foregroundOverride: foreground,
                        backgroundOverride: background,
                        atLineStart: &atLineStart,
                        into: &writer
                    )
                }
                if pieceLength > 0 {
                    let piece = ns.substring(with: NSRange(location: location, length: pieceLength))
                    let usePlainTextStyle = plainStyleForLine(currentLine, linePlainStyles: linePlainStyles)
                    let style = resolvedStyle(for: kind, usePlainTextStyle: usePlainTextStyle, plainStyle: plainStyle)
                    appendIndentIfNeeded(
                        indentPrefix: indentPrefix,
                        plainStyle: plainStyle,
                        foregroundOverride: foreground,
                        backgroundOverride: background,
                        atLineStart: &atLineStart,
                        into: &writer
                    )
                    if let foreground {
                        writer.append(
                            text: piece,
                            style: style,
                            foregroundOverride: foreground,
                            backgroundOverride: background
                        )
                    } else {
                        writer.append(
                            text: piece,
                            style: style,
                            backgroundOverride: background
                        )
                    }
                    atLineStart = false
                }

                writer.appendPlain("\n")
                atLineStart = true
                currentLine += 1
                lineIndex += 1
                location = nextBreak + 1
            } else {
                let pieceLength = end - location
                if pieceLength > 0 {
                    let piece = ns.substring(with: NSRange(location: location, length: pieceLength))
                    let background = backgroundForLine(currentLine, lineBackgrounds: lineBackgrounds)
                    let foreground = foregroundForLine(currentLine, lineForegrounds: lineForegrounds)
                    let usePlainTextStyle = plainStyleForLine(currentLine, linePlainStyles: linePlainStyles)
                    let style = resolvedStyle(for: kind, usePlainTextStyle: usePlainTextStyle, plainStyle: plainStyle)
                    appendIndentIfNeeded(
                        indentPrefix: indentPrefix,
                        plainStyle: plainStyle,
                        foregroundOverride: foreground,
                        backgroundOverride: background,
                        atLineStart: &atLineStart,
                        into: &writer
                    )
                    if let foreground {
                        writer.append(
                            text: piece,
                            style: style,
                            foregroundOverride: foreground,
                            backgroundOverride: background
                        )
                    } else {
                        writer.append(
                            text: piece,
                            style: style,
                            backgroundOverride: background
                        )
                    }
                    atLineStart = false
                }
                break
            }
        }
    }

    private func appendTokenSegmentsWithoutLineBackground(
        _ ns: NSString,
        range: NSRange,
        kind: TokenKind,
        indentPrefix: String,
        plainStyle: TextStyle,
        atLineStart: inout Bool,
        into writer: inout AnsiWriter
    ) {
        guard range.length > 0 else { return }
        let style = resolvedStyle(for: kind, usePlainTextStyle: false, plainStyle: plainStyle)
        let piece = ns.substring(with: range)
        if indentPrefix.isEmpty {
            writer.append(text: piece, style: style, backgroundOverride: nil)
            return
        }

        appendTextWithIndent(
            piece,
            style: style,
            foregroundOverride: nil,
            backgroundOverride: nil,
            indentPrefix: indentPrefix,
            plainStyle: plainStyle,
            atLineStart: &atLineStart,
            into: &writer
        )
    }

    private func backgroundForLine(_ line: Int, lineBackgrounds: [BackgroundColorType?]) -> BackgroundColorType? {
        let index = line - 1
        guard index >= 0, index < lineBackgrounds.count else { return nil }
        return lineBackgrounds[index]
    }

    private func foregroundForLine(_ line: Int, lineForegrounds: [ColorType?]) -> ColorType? {
        let index = line - 1
        guard index >= 0, index < lineForegrounds.count else { return nil }
        return lineForegrounds[index]
    }

    private func plainStyleForLine(_ line: Int, linePlainStyles: [Bool]) -> Bool {
        let index = line - 1
        guard index >= 0, index < linePlainStyles.count else { return false }
        return linePlainStyles[index]
    }

    private func resolvedStyle(
        for kind: TokenKind,
        usePlainTextStyle: Bool,
        plainStyle: TextStyle
    ) -> TextStyle {
        usePlainTextStyle ? plainStyle : styleCache.style(for: kind)
    }

    private func makeIndentPrefix() -> String {
        guard options.indent > 0 else { return "" }
        return String(repeating: " ", count: options.indent)
    }

    private func appendIndentIfNeeded(
        indentPrefix: String,
        plainStyle: TextStyle,
        foregroundOverride: ColorType?,
        backgroundOverride: BackgroundColorType?,
        atLineStart: inout Bool,
        into writer: inout AnsiWriter
    ) {
        guard atLineStart, !indentPrefix.isEmpty else { return }
        if let foregroundOverride {
            writer.append(
                text: indentPrefix,
                style: plainStyle,
                foregroundOverride: foregroundOverride,
                backgroundOverride: backgroundOverride
            )
        } else {
            writer.append(
                text: indentPrefix,
                style: plainStyle,
                backgroundOverride: backgroundOverride
            )
        }
        atLineStart = false
    }

    private func appendTextWithIndent(
        _ text: String,
        style: TextStyle,
        foregroundOverride: ColorType?,
        backgroundOverride: BackgroundColorType?,
        indentPrefix: String,
        plainStyle: TextStyle,
        atLineStart: inout Bool,
        into writer: inout AnsiWriter
    ) {
        guard !text.isEmpty else { return }

        var index = text.startIndex
        while true {
            if let newline = text[index...].firstIndex(of: "\n") {
                let segment = text[index..<newline]
                appendIndentIfNeeded(
                    indentPrefix: indentPrefix,
                    plainStyle: plainStyle,
                    foregroundOverride: foregroundOverride,
                    backgroundOverride: backgroundOverride,
                    atLineStart: &atLineStart,
                    into: &writer
                )
                if !segment.isEmpty {
                    if let foregroundOverride {
                        writer.append(
                            text: String(segment),
                            style: style,
                            foregroundOverride: foregroundOverride,
                            backgroundOverride: backgroundOverride
                        )
                    } else {
                        writer.append(
                            text: String(segment),
                            style: style,
                            backgroundOverride: backgroundOverride
                        )
                    }
                    atLineStart = false
                }
                writer.appendPlain("\n")
                atLineStart = true

                index = text.index(after: newline)
                if index == text.endIndex {
                    break
                }
            } else {
                let segment = text[index..<text.endIndex]
                appendIndentIfNeeded(
                    indentPrefix: indentPrefix,
                    plainStyle: plainStyle,
                    foregroundOverride: foregroundOverride,
                    backgroundOverride: backgroundOverride,
                    atLineStart: &atLineStart,
                    into: &writer
                )
                if !segment.isEmpty {
                    if let foregroundOverride {
                        writer.append(
                            text: String(segment),
                            style: style,
                            foregroundOverride: foregroundOverride,
                            backgroundOverride: backgroundOverride
                        )
                    } else {
                        writer.append(
                            text: String(segment),
                            style: style,
                            backgroundOverride: backgroundOverride
                        )
                    }
                    atLineStart = false
                }
                break
            }
        }
    }

    private struct RenderPlan {
        let lineBackgrounds: [BackgroundColorType?]
        let lineForegrounds: [ColorType?]
        let linePlainStyles: [Bool]
        let hasLineOverrides: Bool
        let lineBreaks: [Int]
    }

    private func makePlan(for code: String) -> RenderPlan {
        let diffRendering = options.diff.rendering(for: code)
        if diffRendering == nil && options.highlightLines.ranges.isEmpty {
            return RenderPlan(
                lineBackgrounds: [],
                lineForegrounds: [],
                linePlainStyles: [],
                hasLineOverrides: false,
                lineBreaks: []
            )
        }

        let lines = splitLines(code)

        var lineBackgrounds: [BackgroundColorType?] = []
        var lineForegrounds: [ColorType?] = []
        var linePlainStyles: [Bool] = []
        var hasLineOverrides = false
        if let diffRendering {
            let diffStyle = diffRendering.style
            lineBackgrounds = [BackgroundColorType?](repeating: nil, count: lines.count)
            lineForegrounds = [ColorType?](repeating: nil, count: lines.count)
            linePlainStyles = Array(repeating: false, count: lines.count)
            for (index, line) in lines.enumerated() {
                let kind = DiffDetector.kind(forLine: line)
                let isDiffLine: Bool = {
                    switch kind {
                    case .added?, .removed?:
                        return true
                    default:
                        return false
                    }
                }()

                let codeStyle = isDiffLine ? diffStyle.diffCodeStyle : diffStyle.contextCodeStyle
                if codeStyle == .plain {
                    linePlainStyles[index] = true
                    hasLineOverrides = true
                }

                switch kind {
                case .added:
                    switch diffStyle {
                    case .background(diffCode: _, contextCode: _):
                        lineBackgrounds[index] = theme.diffAddedBackground
                        hasLineOverrides = true
                    case .foreground:
                        lineForegrounds[index] = theme.diffAddedForeground
                        hasLineOverrides = true
                    }
                case .removed:
                    switch diffStyle {
                    case .background(diffCode: _, contextCode: _):
                        lineBackgrounds[index] = theme.diffRemovedBackground
                        hasLineOverrides = true
                    case .foreground:
                        lineForegrounds[index] = theme.diffRemovedForeground
                        hasLineOverrides = true
                    }
                case .fileHeader, .hunkHeader, .meta, .none:
                    break
                }
            }
        }

        if !options.highlightLines.ranges.isEmpty {
            if lineBackgrounds.isEmpty {
                lineBackgrounds = [BackgroundColorType?](repeating: nil, count: lines.count)
            }
            for (index, _) in lines.enumerated() {
                let lineNumber = index + 1
                if options.highlightLines.contains(lineNumber) {
                    lineBackgrounds[index] = theme.lineHighlightBackground
                    hasLineOverrides = true
                }
            }
        }

        let lineBreaks = hasLineOverrides ? lineBreakLocations(code) : []
        return RenderPlan(
            lineBackgrounds: lineBackgrounds,
            lineForegrounds: lineForegrounds,
            linePlainStyles: linePlainStyles,
            hasLineOverrides: hasLineOverrides,
            lineBreaks: lineBreaks
        )
    }

    private func lineBreakLocations(_ code: String) -> [Int] {
        var locations: [Int] = []
        locations.reserveCapacity(max(16, code.count / 64))

        var index = 0
        for value in code.utf16 {
            if value == 10 {
                locations.append(index)
            }
            index += 1
        }
        return locations
    }
}

private struct AnsiWriter {
    private struct PrefixCacheEntry {
        let color: ColorType?
        let backgroundColor: BackgroundColorType?
        let styles: [Style]?
        let prefix: String

        func matches(color: ColorType?, backgroundColor: BackgroundColorType?, styles: [Style]?) -> Bool {
            self.color == color &&
                self.backgroundColor == backgroundColor &&
                self.styles == styles
        }
    }

    private let isEnabled: Bool
    private var result: String
    private var prefixCache: [PrefixCacheEntry]

    init(estimatedTextLength: Int, estimatedSegments: Int, isEnabled: Bool) {
        let estimatedTotalLength = estimatedTextLength + (estimatedSegments * 20)
        self.isEnabled = isEnabled
        self.result = ""
        self.result.reserveCapacity(estimatedTotalLength)
        self.prefixCache = []
        self.prefixCache.reserveCapacity(16)
    }

    mutating func appendPlain(_ text: String) {
        result.append(text)
    }

    mutating func append(text: String, style: TextStyle, backgroundOverride: BackgroundColorType?) {
        if text.isEmpty {
            result.append(text)
            return
        }

        guard isEnabled else {
            result.append(text)
            return
        }

        let color = style.foreground
        let background = backgroundOverride ?? style.background
        let styles = style.styles

        if color == nil && background == nil && styles == nil {
            result.append(text)
            return
        }

        if let cached = prefixCache.first(where: { $0.matches(color: color, backgroundColor: background, styles: styles) }) {
            result.append(cached.prefix)
            result.append(text)
            result.append("\u{001B}[0m")
            return
        }

        var codes: [UInt8] = []
        if let color { codes += color.value }
        if let background { codes += background.value }
        if let styles { codes += styles.flatMap { $0.value } }

        if codes.isEmpty {
            result.append(text)
            return
        }

        var prefix = "\u{001B}["
        for (index, code) in codes.enumerated() {
            if index > 0 { prefix.append(";") }
            prefix.append(String(code))
        }
        prefix.append("m")
        prefixCache.append(
            PrefixCacheEntry(
                color: color,
                backgroundColor: background,
                styles: styles,
                prefix: prefix
            )
        )
        result.append(prefix)
        result.append(text)
        result.append("\u{001B}[0m")
    }

    mutating func append(
        text: String,
        style: TextStyle,
        foregroundOverride: ColorType?,
        backgroundOverride: BackgroundColorType?
    ) {
        guard let foregroundOverride else {
            append(text: text, style: style, backgroundOverride: backgroundOverride)
            return
        }

        if text.isEmpty {
            result.append(text)
            return
        }

        guard isEnabled else {
            result.append(text)
            return
        }

        let color: ColorType? = foregroundOverride
        let background = backgroundOverride ?? style.background
        let styles = style.styles

        if color == nil && background == nil && styles == nil {
            result.append(text)
            return
        }

        if let cached = prefixCache.first(where: { $0.matches(color: color, backgroundColor: background, styles: styles) }) {
            result.append(cached.prefix)
            result.append(text)
            result.append("\u{001B}[0m")
            return
        }

        var codes: [UInt8] = []
        if let color { codes += color.value }
        if let background { codes += background.value }
        if let styles { codes += styles.flatMap { $0.value } }

        if codes.isEmpty {
            result.append(text)
            return
        }

        var prefix = "\u{001B}["
        for (index, code) in codes.enumerated() {
            if index > 0 { prefix.append(";") }
            prefix.append(String(code))
        }
        prefix.append("m")
        prefixCache.append(
            PrefixCacheEntry(
                color: color,
                backgroundColor: background,
                styles: styles,
                prefix: prefix
            )
        )
        result.append(prefix)
        result.append(text)
        result.append("\u{001B}[0m")
    }

    func finish() -> String {
        result
    }
}
