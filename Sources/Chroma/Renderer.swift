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
        let plan = makePlan(for: code)
        let ns = code as NSString

        var writer = AnsiWriter(
            estimatedTextLength: code.count,
            estimatedSegments: estimatedSegments ?? max(16, code.count / 8),
            isEnabled: Rainbow.enabled
        )

        var currentLine = 1
        tokenStream { token in
            appendTokenSegments(
                ns,
                range: token.range,
                kind: token.kind,
                currentLine: &currentLine,
                lineBackgrounds: plan.lineBackgrounds,
                into: &writer
            )
        }

        return writer.finish()
    }

    private func appendTokenSegments(
        _ ns: NSString,
        range: NSRange,
        kind: TokenKind,
        currentLine: inout Int,
        lineBackgrounds: [BackgroundColorType?],
        into writer: inout AnsiWriter
    ) {
        guard range.length > 0 else { return }

        let style = styleCache.style(for: kind)
        let end = range.location + range.length
        var location = range.location

        while location < end {
            let searchRange = NSRange(location: location, length: end - location)
            let newlineRange = ns.range(of: "\n", options: [], range: searchRange)

            if newlineRange.location != NSNotFound {
                let pieceLength = newlineRange.location - location
                if pieceLength > 0 {
                    let piece = ns.substring(with: NSRange(location: location, length: pieceLength))
                    let background = backgroundForLine(currentLine, lineBackgrounds: lineBackgrounds)
                    writer.append(text: piece, style: style, backgroundOverride: background)
                }

                writer.appendPlain("\n")
                currentLine += 1
                location = newlineRange.location + 1
            } else {
                let pieceLength = end - location
                if pieceLength > 0 {
                    let piece = ns.substring(with: NSRange(location: location, length: pieceLength))
                    let background = backgroundForLine(currentLine, lineBackgrounds: lineBackgrounds)
                    writer.append(text: piece, style: style, backgroundOverride: background)
                }
                break
            }
        }
    }

    private func backgroundForLine(_ line: Int, lineBackgrounds: [BackgroundColorType?]) -> BackgroundColorType? {
        let index = line - 1
        guard index >= 0, index < lineBackgrounds.count else { return nil }
        return lineBackgrounds[index]
    }

    private struct RenderPlan {
        let lineBackgrounds: [BackgroundColorType?]
    }

    private func makePlan(for code: String) -> RenderPlan {
        let lines = splitLines(code)

        let diffEnabled: Bool = {
            switch options.diff {
            case .none: return false
            case .patch: return true
            case .auto: return DiffDetector.looksLikePatch(lines: lines)
            }
        }()

        var lineBackgrounds = Array<BackgroundColorType?>(repeating: nil, count: lines.count)
        if diffEnabled {
            for (index, line) in lines.enumerated() {
                guard let kind = DiffDetector.kind(forLine: line) else { continue }
                switch kind {
                case .added:
                    lineBackgrounds[index] = theme.diffAddedBackground
                case .removed:
                    lineBackgrounds[index] = theme.diffRemovedBackground
                case .fileHeader, .hunkHeader, .meta:
                    break
                }
            }
        }

        if !options.highlightLines.ranges.isEmpty {
            for (index, _) in lines.enumerated() {
                let lineNumber = index + 1
                if options.highlightLines.contains(lineNumber) {
                    lineBackgrounds[index] = theme.lineHighlightBackground
                }
            }
        }

        return RenderPlan(lineBackgrounds: lineBackgrounds)
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

    func finish() -> String {
        result
    }
}
