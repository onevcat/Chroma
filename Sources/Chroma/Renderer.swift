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
        if !Rainbow.enabled &&
            options.highlightLines.ranges.isEmpty &&
            options.indent == 0 &&
            !options.lineNumbers.isEnabled {
            if options.diff.rendering(for: code) == nil {
                return code
            }
        }

        let plan = makePlan(for: code)
        let indentPrefix = makeIndentPrefix()
        let plainStyle = styleCache.style(for: .plain)
        let lineNumberStyle = styleCache.style(for: .comment)

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
                    code,
                    range: token.range,
                    kind: token.kind,
                    currentLine: &currentLine,
                    lineBackgrounds: plan.lineBackgrounds,
                    lineForegrounds: plan.lineForegrounds,
                    linePlainStyles: plan.linePlainStyles,
                    lineBreaks: plan.lineBreaks,
                    lineNumbers: plan.lineNumbers,
                    lineNumberWidth: plan.lineNumberWidth,
                    lineNumberStyle: lineNumberStyle,
                    lineNumberForegrounds: plan.lineNumberForegrounds,
                    lineNumberForeground: theme.lineNumberForeground,
                    lineVisibility: plan.lineVisibility,
                    lineSeparators: plan.lineSeparators,
                    indentPrefix: indentPrefix,
                    plainStyle: plainStyle,
                    atLineStart: &atLineStart,
                    into: &writer
                )
            }
        } else {
            tokenStream { token in
                appendTokenSegmentsWithoutLineBackground(
                    code,
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
        _ code: String,
        range: NSRange,
        kind: TokenKind,
        currentLine: inout Int,
        lineBackgrounds: [BackgroundColorType?],
        lineForegrounds: [ColorType?],
        linePlainStyles: [Bool],
        lineBreaks: [Int],
        lineNumbers: [Int?],
        lineNumberWidth: Int,
        lineNumberStyle: TextStyle,
        lineNumberForegrounds: [ColorType?],
        lineNumberForeground: ColorType,
        lineVisibility: [Bool],
        lineSeparators: [Int],
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
                let shouldRender = lineIsVisible(currentLine, lineVisibility: lineVisibility)
                let background = backgroundForLine(currentLine, lineBackgrounds: lineBackgrounds)
                let foreground = foregroundForLine(currentLine, lineForegrounds: lineForegrounds)
                if pieceLength == 0 {
                    if shouldRender {
                        appendLinePrefixIfNeeded(
                            line: currentLine,
                            lineNumbers: lineNumbers,
                            lineNumberWidth: lineNumberWidth,
                            lineNumberStyle: lineNumberStyle,
                            lineNumberForegrounds: lineNumberForegrounds,
                            lineNumberForeground: lineNumberForeground,
                            lineVisibility: lineVisibility,
                            lineSeparators: lineSeparators,
                            indentPrefix: indentPrefix,
                            plainStyle: plainStyle,
                            foregroundOverride: foreground,
                            backgroundOverride: background,
                            atLineStart: &atLineStart,
                            into: &writer
                        )
                    }
                }
                if pieceLength > 0 {
                    if shouldRender {
                        let piece = substring(code, location: location, length: pieceLength)
                        let usePlainTextStyle = plainStyleForLine(currentLine, linePlainStyles: linePlainStyles)
                        let style = resolvedStyle(for: kind, usePlainTextStyle: usePlainTextStyle, plainStyle: plainStyle)
                        appendLinePrefixIfNeeded(
                            line: currentLine,
                            lineNumbers: lineNumbers,
                            lineNumberWidth: lineNumberWidth,
                            lineNumberStyle: lineNumberStyle,
                            lineNumberForegrounds: lineNumberForegrounds,
                            lineNumberForeground: lineNumberForeground,
                            lineVisibility: lineVisibility,
                            lineSeparators: lineSeparators,
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
                }

                if shouldRender {
                    writer.appendPlain("\n")
                }
                atLineStart = true
                currentLine += 1
                lineIndex += 1
                location = nextBreak + 1
            } else {
                let pieceLength = end - location
                if pieceLength > 0 {
                    let shouldRender = lineIsVisible(currentLine, lineVisibility: lineVisibility)
                    if shouldRender {
                        let piece = substring(code, location: location, length: pieceLength)
                        let background = backgroundForLine(currentLine, lineBackgrounds: lineBackgrounds)
                        let foreground = foregroundForLine(currentLine, lineForegrounds: lineForegrounds)
                        let usePlainTextStyle = plainStyleForLine(currentLine, linePlainStyles: linePlainStyles)
                        let style = resolvedStyle(for: kind, usePlainTextStyle: usePlainTextStyle, plainStyle: plainStyle)
                        appendLinePrefixIfNeeded(
                            line: currentLine,
                            lineNumbers: lineNumbers,
                            lineNumberWidth: lineNumberWidth,
                            lineNumberStyle: lineNumberStyle,
                            lineNumberForegrounds: lineNumberForegrounds,
                            lineNumberForeground: lineNumberForeground,
                            lineVisibility: lineVisibility,
                            lineSeparators: lineSeparators,
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
                }
                break
            }
        }
    }

    private func appendTokenSegmentsWithoutLineBackground(
        _ code: String,
        range: NSRange,
        kind: TokenKind,
        indentPrefix: String,
        plainStyle: TextStyle,
        atLineStart: inout Bool,
        into writer: inout AnsiWriter
    ) {
        guard range.length > 0 else { return }
        let style = resolvedStyle(for: kind, usePlainTextStyle: false, plainStyle: plainStyle)
        let piece = substring(code, range: range)
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
        _ text: Substring,
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
                            text: segment,
                            style: style,
                            foregroundOverride: foregroundOverride,
                            backgroundOverride: backgroundOverride
                        )
                    } else {
                        writer.append(
                            text: segment,
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
                            text: segment,
                            style: style,
                            foregroundOverride: foregroundOverride,
                            backgroundOverride: backgroundOverride
                        )
                    } else {
                        writer.append(
                            text: segment,
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

    @inline(__always)
    private func substring(_ code: String, range: NSRange) -> Substring {
        let start = String.Index(utf16Offset: range.location, in: code)
        let end = String.Index(utf16Offset: range.location + range.length, in: code)
        return code[start..<end]
    }

    @inline(__always)
    private func substring(_ code: String, location: Int, length: Int) -> Substring {
        let start = String.Index(utf16Offset: location, in: code)
        let end = String.Index(utf16Offset: location + length, in: code)
        return code[start..<end]
    }

    private struct RenderPlan {
        let lineBackgrounds: [BackgroundColorType?]
        let lineForegrounds: [ColorType?]
        let linePlainStyles: [Bool]
        let hasLineOverrides: Bool
        let lineBreaks: [Int]
        let lineNumbers: [Int?]
        let lineNumberWidth: Int
        let lineNumberForegrounds: [ColorType?]
        let lineVisibility: [Bool]
        let lineSeparators: [Int]
    }

    private func makePlan(for code: String) -> RenderPlan {
        let diffRendering = options.diff.rendering(for: code)
        let needsLineInfo = diffRendering != nil ||
            !options.highlightLines.ranges.isEmpty ||
            options.lineNumbers.isEnabled
        if !needsLineInfo {
            return RenderPlan(
                lineBackgrounds: [],
                lineForegrounds: [],
                linePlainStyles: [],
                hasLineOverrides: false,
                lineBreaks: [],
                lineNumbers: [],
                lineNumberWidth: 0,
                lineNumberForegrounds: [],
                lineVisibility: [],
                lineSeparators: []
            )
        }

        let (lines, lineBreaksFromSplit) = splitLinesWithBreaks(code)
        let lineKinds: [DiffLineKind?] = {
            guard diffRendering != nil || options.lineNumbers.isEnabled else { return [] }
            return lines.map(DiffDetector.kind)
        }()

        var lineBackgrounds: [BackgroundColorType?] = []
        var lineForegrounds: [ColorType?] = []
        var linePlainStyles: [Bool] = []
        var lineVisibility = [Bool](repeating: true, count: lines.count)
        var lineSeparators = [Int](repeating: 0, count: lines.count)
        var hasLineOverrides = false
        if let diffRendering {
            let diffStyle = diffRendering.style
            lineBackgrounds = [BackgroundColorType?](repeating: nil, count: lines.count)
            lineForegrounds = [ColorType?](repeating: nil, count: lines.count)
            linePlainStyles = Array(repeating: false, count: lines.count)
            for (index, line) in lines.enumerated() {
                let kind = lineKinds.isEmpty ? DiffDetector.kind(forLine: line) : lineKinds[index]
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

            if diffRendering.presentation == .compact {
                let compact = makeCompactLinePlan(for: lines, lineKinds: lineKinds)
                lineVisibility = compact.visibility
                lineSeparators = compact.separators
                if compact.hasOverrides {
                    hasLineOverrides = true
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

        let lineNumbers = resolveLineNumbers(for: lines, lineKinds: lineKinds)
        let lineNumberWidth = lineNumberWidth(for: lineNumbers)
        let lineNumberForegrounds = resolveLineNumberForegrounds(
            for: lines,
            lineBackgrounds: lineBackgrounds,
            lineForegrounds: lineForegrounds,
            diffRendering: diffRendering
        )
        if !lineNumbers.isEmpty {
            hasLineOverrides = true
        }

        let lineBreaks = hasLineOverrides ? lineBreaksFromSplit : []
        return RenderPlan(
            lineBackgrounds: lineBackgrounds,
            lineForegrounds: lineForegrounds,
            linePlainStyles: linePlainStyles,
            hasLineOverrides: hasLineOverrides,
            lineBreaks: lineBreaks,
            lineNumbers: lineNumbers,
            lineNumberWidth: lineNumberWidth,
            lineNumberForegrounds: lineNumberForegrounds,
            lineVisibility: lineVisibility,
            lineSeparators: lineSeparators
        )
    }

    private func resolveLineNumbers(for lines: [Substring], lineKinds: [DiffLineKind?]) -> [Int?] {
        guard options.lineNumbers.isEnabled else { return [] }

        if lineKinds.isEmpty {
            if DiffDetector.looksLikePatch(lines: lines) {
                return makePatchLineNumbers(for: lines, lineKinds: lineKinds)
            }
            return makeSequentialLineNumbers(for: lines, lineKinds: lineKinds, start: options.lineNumbers.start)
        }

        if looksLikePatch(lineKinds: lineKinds) {
            return makePatchLineNumbers(for: lines, lineKinds: lineKinds)
        }
        return makeSequentialLineNumbers(for: lines, lineKinds: lineKinds, start: options.lineNumbers.start)
    }

    private func makePatchLineNumbers(for lines: [Substring], lineKinds: [DiffLineKind?]) -> [Int?] {
        var result = [Int?](repeating: nil, count: lines.count)
        var oldLine: Int? = nil
        var newLine: Int? = nil
        var hasHunkHeader = false

        for (index, line) in lines.enumerated() {
            let kind = lineKinds.isEmpty ? DiffDetector.kind(forLine: line) : lineKinds[index]
            if case .hunkHeader? = kind {
                if let hunk = DiffDetector.hunkStartNumbers(forLine: line) {
                    oldLine = hunk.old
                    newLine = hunk.new
                    hasHunkHeader = true
                } else {
                    oldLine = nil
                    newLine = nil
                }
                continue
            }

            switch kind {
            case .meta?, .fileHeader?:
                continue
            case .removed?:
                guard let currentOld = oldLine else { continue }
                result[index] = currentOld
                oldLine = currentOld + 1
            case .added?:
                guard let currentNew = newLine else { continue }
                result[index] = currentNew
                newLine = currentNew + 1
            case .hunkHeader?:
                continue
            case nil:
                guard let currentOld = oldLine, let currentNew = newLine else { continue }
                result[index] = currentNew
                oldLine = currentOld + 1
                newLine = currentNew + 1
            }
        }

        guard hasHunkHeader else {
            return makeSequentialLineNumbers(
                for: lines,
                lineKinds: lineKinds,
                start: options.lineNumbers.start,
                maskingDiffMeta: true
            )
        }

        return result
    }

    private func makeSequentialLineNumbers(
        for lines: [Substring],
        lineKinds: [DiffLineKind?],
        start: Int,
        maskingDiffMeta: Bool = false
    ) -> [Int?] {
        var result = [Int?](repeating: nil, count: lines.count)
        var current = start

        for (index, line) in lines.enumerated() {
            if maskingDiffMeta {
                let kind = lineKinds.isEmpty ? DiffDetector.kind(forLine: line) : lineKinds[index]
                switch kind {
                case .meta?, .fileHeader?, .hunkHeader?:
                    continue
                case nil, .added?, .removed?:
                    break
                }
            }
            result[index] = current
            current += 1
        }

        return result
    }

    private func lineNumberWidth(for lineNumbers: [Int?]) -> Int {
        guard options.lineNumbers.isEnabled else { return 0 }
        let maxNumber = lineNumbers.compactMap { $0 }.max() ?? options.lineNumbers.start
        return max(1, String(maxNumber).count)
    }

    private func resolveLineNumberForegrounds(
        for lines: [Substring],
        lineBackgrounds: [BackgroundColorType?],
        lineForegrounds: [ColorType?],
        diffRendering: HighlightOptions.DiffRendering?
    ) -> [ColorType?] {
        guard options.lineNumbers.isEnabled, let diffRendering else { return [] }

        let style = diffRendering.style
        switch style {
        case .background:
            guard !lineBackgrounds.isEmpty else { return [] }
            var result = [ColorType?](repeating: nil, count: lines.count)
            for (index, background) in lineBackgrounds.enumerated() {
                if background == theme.diffAddedBackground || background == theme.diffRemovedBackground {
                    result[index] = .named(.white)
                }
            }
            return result
        case .foreground:
            guard !lineForegrounds.isEmpty else { return [] }
            return lineForegrounds
        }
    }

    private func appendLinePrefixIfNeeded(
        line: Int,
        lineNumbers: [Int?],
        lineNumberWidth: Int,
        lineNumberStyle: TextStyle,
        lineNumberForegrounds: [ColorType?],
        lineNumberForeground: ColorType,
        lineVisibility: [Bool],
        lineSeparators: [Int],
        indentPrefix: String,
        plainStyle: TextStyle,
        foregroundOverride: ColorType?,
        backgroundOverride: BackgroundColorType?,
        atLineStart: inout Bool,
        into writer: inout AnsiWriter
    ) {
        guard atLineStart else { return }
        guard lineIsVisible(line, lineVisibility: lineVisibility) else { return }

        let separatorCount = separatorCount(for: line, lineSeparators: lineSeparators)
        if separatorCount > 0 {
            appendSeparatorLines(
                count: separatorCount,
                lineNumberWidth: lineNumberWidth,
                indentPrefix: indentPrefix,
                plainStyle: plainStyle,
                separatorStyle: lineNumberStyle,
                into: &writer
            )
            atLineStart = true
        }

        var wrotePrefix = false

        if !indentPrefix.isEmpty {
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
            wrotePrefix = true
        }

        if !lineNumbers.isEmpty {
            let index = max(0, min(lineNumbers.count - 1, line - 1))
            let numberText = makeLineNumberText(lineNumbers[index], width: lineNumberWidth)
            if !numberText.isEmpty {
                let overrideForeground = lineNumberForegrounds.isEmpty ? nil : lineNumberForegrounds[index]
                let resolvedForeground = overrideForeground ?? lineNumberForeground
                if overrideForeground == .named(.white) {
                    let fixedStyle = TextStyle(foreground: .named(.white))
                    writer.append(
                        text: numberText,
                        style: fixedStyle,
                        backgroundOverride: backgroundOverride
                    )
                } else {
                    writer.append(
                        text: numberText,
                        style: lineNumberStyle,
                        foregroundOverride: resolvedForeground,
                        backgroundOverride: backgroundOverride
                    )
                }
            }
            writer.append(
                text: " ",
                style: plainStyle,
                foregroundOverride: foregroundOverride,
                backgroundOverride: backgroundOverride
            )
            wrotePrefix = true
        }

        if wrotePrefix {
            atLineStart = false
        }
    }

    private func makeLineNumberText(_ number: Int?, width: Int) -> String {
        guard width > 0 else { return "" }
        guard let number else {
            return String(repeating: " ", count: width)
        }
        let digits = String(number).count
        if digits >= width {
            return String(number)
        }
        return String(repeating: " ", count: width - digits) + String(number)
    }

    private func makeCompactLinePlan(for lines: [Substring], lineKinds: [DiffLineKind?]) -> (visibility: [Bool], separators: [Int], hasOverrides: Bool) {
        var visibility = [Bool](repeating: true, count: lines.count)
        var separators = [Int](repeating: 0, count: lines.count)

        let usesGitHeader = lines.contains { trimmingCR($0).hasPrefix("diff --git ") }
        var pendingFileSeparator = 0
        var pendingHunkSeparator = false
        var hunkCountInFile = 0
        var fileHasOutput = false

        for (index, line) in lines.enumerated() {
            let trimmed = trimmingCR(line)
            let isFileBoundary: Bool = {
                if usesGitHeader {
                    return trimmed.hasPrefix("diff --git ")
                }
                return trimmed.hasPrefix("--- ")
            }()

            if isFileBoundary {
                if fileHasOutput {
                    pendingFileSeparator = 2
                }
                hunkCountInFile = 0
                fileHasOutput = false
                visibility[index] = false
                continue
            }

            let kind = lineKinds.isEmpty ? DiffDetector.kind(forLine: line) : lineKinds[index]
            switch kind {
            case .meta?, .fileHeader?:
                visibility[index] = false
                continue
            case .hunkHeader?:
                visibility[index] = false
                if hunkCountInFile > 0 {
                    pendingHunkSeparator = true
                }
                hunkCountInFile += 1
                continue
            case nil, .added?, .removed?:
                break
            }

            visibility[index] = true
            if pendingFileSeparator > 0 {
                separators[index] = pendingFileSeparator
                pendingFileSeparator = 0
                pendingHunkSeparator = false
            } else if pendingHunkSeparator {
                separators[index] = 1
                pendingHunkSeparator = false
            }
            fileHasOutput = true
        }

        let hasOverrides = visibility.contains(false) || separators.contains(where: { $0 > 0 })
        return (visibility, separators, hasOverrides)
    }

    private func looksLikePatch(lineKinds: [DiffLineKind?]) -> Bool {
        for kind in lineKinds {
            switch kind {
            case .meta?, .fileHeader?, .hunkHeader?:
                return true
            default:
                break
            }
        }
        return false
    }

    private func lineIsVisible(_ line: Int, lineVisibility: [Bool]) -> Bool {
        guard !lineVisibility.isEmpty else { return true }
        let index = line - 1
        guard index >= 0, index < lineVisibility.count else { return true }
        return lineVisibility[index]
    }

    private func separatorCount(for line: Int, lineSeparators: [Int]) -> Int {
        guard !lineSeparators.isEmpty else { return 0 }
        let index = line - 1
        guard index >= 0, index < lineSeparators.count else { return 0 }
        return lineSeparators[index]
    }

    private func appendSeparatorLines(
        count: Int,
        lineNumberWidth: Int,
        indentPrefix: String,
        plainStyle: TextStyle,
        separatorStyle: TextStyle,
        into writer: inout AnsiWriter
    ) {
        guard count > 0 else { return }
        let numberPadding = lineNumberWidth > 0
            ? String(repeating: " ", count: lineNumberWidth) + " "
            : ""

        for _ in 0..<count {
            if !indentPrefix.isEmpty {
                writer.append(
                    text: indentPrefix,
                    style: plainStyle,
                    backgroundOverride: nil
                )
            }
            if !numberPadding.isEmpty {
                writer.append(
                    text: numberPadding,
                    style: plainStyle,
                    backgroundOverride: nil
                )
            }
            writer.append(
                text: "⋮",
                style: separatorStyle,
                backgroundOverride: nil
            )
            writer.appendPlain("\n")
        }
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

    mutating func append(text: Substring, style: TextStyle, backgroundOverride: BackgroundColorType?) {
        if text.isEmpty {
            return
        }

        guard isEnabled else {
            result.append(contentsOf: text)
            return
        }

        let color = style.foreground
        let background = backgroundOverride ?? style.background
        let styles = style.styles

        if color == nil && background == nil && styles == nil {
            result.append(contentsOf: text)
            return
        }

        if let cached = prefixCache.first(where: { $0.matches(color: color, backgroundColor: background, styles: styles) }) {
            result.append(cached.prefix)
            result.append(contentsOf: text)
            result.append("\u{001B}[0m")
            return
        }

        var codes: [UInt8] = []
        if let color { codes += color.value }
        if let background { codes += background.value }
        if let styles { codes += styles.flatMap { $0.value } }

        if codes.isEmpty {
            result.append(contentsOf: text)
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
        result.append(contentsOf: text)
        result.append("\u{001B}[0m")
    }

    mutating func append(
        text: Substring,
        style: TextStyle,
        foregroundOverride: ColorType?,
        backgroundOverride: BackgroundColorType?
    ) {
        guard let foregroundOverride else {
            append(text: text, style: style, backgroundOverride: backgroundOverride)
            return
        }

        if text.isEmpty {
            return
        }

        guard isEnabled else {
            result.append(contentsOf: text)
            return
        }

        let color: ColorType? = foregroundOverride
        let background = backgroundOverride ?? style.background
        let styles = style.styles

        if color == nil && background == nil && styles == nil {
            result.append(contentsOf: text)
            return
        }

        if let cached = prefixCache.first(where: { $0.matches(color: color, backgroundColor: background, styles: styles) }) {
            result.append(cached.prefix)
            result.append(contentsOf: text)
            result.append("\u{001B}[0m")
            return
        }

        var codes: [UInt8] = []
        if let color { codes += color.value }
        if let background { codes += background.value }
        if let styles { codes += styles.flatMap { $0.value } }

        if codes.isEmpty {
            result.append(contentsOf: text)
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
        result.append(contentsOf: text)
        result.append("\u{001B}[0m")
    }

    func finish() -> String {
        result
    }
}
