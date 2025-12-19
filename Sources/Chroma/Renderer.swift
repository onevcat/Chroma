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
        return render(code: code) { emit in
            for token in tokens {
                emit(token)
            }
        }
    }

    func render(code: String, tokenStream: (_ emit: (Token) -> Void) -> Void) -> String {
        let plan = makePlan(for: code)
        let ns = code as NSString

        var segments: [Rainbow.Segment] = []
        segments.reserveCapacity(max(16, code.count / 8))

        var currentLine = 1
        tokenStream { token in
            appendTokenSegments(
                ns,
                range: token.range,
                kind: token.kind,
                currentLine: &currentLine,
                lineBackgrounds: plan.lineBackgrounds,
                into: &segments
            )
        }

        return AnsiStringGenerator.generate(for: Rainbow.Entry(segments: segments))
    }

    private func appendTokenSegments(
        _ ns: NSString,
        range: NSRange,
        kind: TokenKind,
        currentLine: inout Int,
        lineBackgrounds: [BackgroundColorType?],
        into segments: inout [Rainbow.Segment]
    ) {
        guard range.length > 0 else { return }

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
                    segments.append(theme.style(for: kind).makeSegment(text: piece, backgroundOverride: background))
                }

                segments.append(Rainbow.Segment(text: "\n"))
                currentLine += 1
                location = newlineRange.location + 1
            } else {
                let pieceLength = end - location
                if pieceLength > 0 {
                    let piece = ns.substring(with: NSRange(location: location, length: pieceLength))
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
