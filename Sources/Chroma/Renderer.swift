import Foundation
import Rainbow

final class Renderer {
    private let theme: Theme
    private let options: HighlightOptions

    init(theme: Theme, options: HighlightOptions) {
        self.theme = theme
        self.options = options
    }

    func render(code: String, tokens: [Token]) -> String {
        let lines = splitLines(code)

        let diffEnabled: Bool = {
            switch options.diff {
            case .none: return false
            case .patch: return true
            case .auto: return DiffDetector.looksLikePatch(code)
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

        let ns = code as NSString
        var segments: [Rainbow.Segment] = []
        segments.reserveCapacity(tokens.count * 2)

        var currentLine = 1
        for token in tokens {
            let raw = ns.substring(with: token.range)
            appendTokenSegments(
                raw,
                kind: token.kind,
                currentLine: &currentLine,
                lineBackgrounds: lineBackgrounds,
                into: &segments
            )
        }

        return AnsiStringGenerator.generate(for: Rainbow.Entry(segments: segments))
    }

    private func appendTokenSegments(
        _ text: String,
        kind: TokenKind,
        currentLine: inout Int,
        lineBackgrounds: [BackgroundColorType?],
        into segments: inout [Rainbow.Segment]
    ) {
        var start = text.startIndex

        while start < text.endIndex {
            if let newline = text[start...].firstIndex(of: "\n") {
                let piece = String(text[start..<newline])
                if !piece.isEmpty {
                    let background = backgroundForLine(currentLine, lineBackgrounds: lineBackgrounds)
                    segments.append(theme.style(for: kind).makeSegment(text: piece, backgroundOverride: background))
                }

                segments.append(Rainbow.Segment(text: "\n"))
                currentLine += 1
                start = text.index(after: newline)
            } else {
                let piece = String(text[start..<text.endIndex])
                if !piece.isEmpty {
                    let background = backgroundForLine(currentLine, lineBackgrounds: lineBackgrounds)
                    segments.append(theme.style(for: kind).makeSegment(text: piece, backgroundOverride: background))
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
}
