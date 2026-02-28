import Foundation

enum DiffLineKind {
    case added
    case removed
    case fileHeader
    case hunkHeader
    case meta
}

enum DiffDetector {
    static func looksLikePatch(_ code: String) -> Bool {
        var lineStart = code.startIndex
        var index = lineStart

        func lineLooksLikePatch(start: String.Index, end: String.Index) -> Bool {
            guard start < end else { return false }
            let line = code[start..<end]
            if line.hasPrefix("diff --git ") { return true }
            if line.hasPrefix("@@") { return true }
            if line.hasPrefix("--- ") || line.hasPrefix("+++ ") { return true }
            return false
        }

        while index < code.endIndex {
            if code[index] == "\n" {
                if lineLooksLikePatch(start: lineStart, end: index) {
                    return true
                }
                index = code.index(after: index)
                lineStart = index
                continue
            }
            index = code.index(after: index)
        }

        return lineLooksLikePatch(start: lineStart, end: code.endIndex)
    }


    /// Attempts to infer a language from patch headers.
    ///
    /// This is best-effort and is intended to improve diff rendering when the caller does not
    /// provide a language (e.g. viewing a `*.patch` file).
    static func inferLanguageID(fromPatch code: String, maxScanLines: Int = 400) -> LanguageID? {
        var counts: [LanguageID: Int] = [:]
        var firstSeenOrder: [LanguageID] = []

        func recordCandidatePath(_ raw: Substring) {
            var s = trimmingCR(raw)

            // Trim surrounding whitespace
            while let first = s.first, first == " " || first == "\t" { s = s.dropFirst() }
            while let last = s.last, last == " " || last == "\t" { s = s.dropLast() }

            // Strip surrounding quotes if present.
            if (s.hasPrefix("\"") && s.hasSuffix("\"")) || (s.hasPrefix("'") && s.hasSuffix("'")) {
                if s.count >= 2 { s = s.dropFirst().dropLast() }
            }

            guard !s.isEmpty else { return }
            if s == "/dev/null" { return }

            // Normalize common git prefixes.
            if s.hasPrefix("a/") || s.hasPrefix("b/") {
                s = s.dropFirst(2)
            }

            // Reduce to the last path component to leverage LanguageID.fromFileName.
            let fileName = s.split(separator: "/").last ?? s
            guard let lang = LanguageID.fromFileName(String(fileName)) else { return }

            let oldCount = counts[lang] ?? 0
            counts[lang] = oldCount + 1
            if oldCount == 0 {
                firstSeenOrder.append(lang)
            }
        }

        var lineStart = code.startIndex
        var index = lineStart
        var scanned = 0

        func processLine(start: String.Index, end: String.Index) {
            let line = code[start..<end]
            if line.hasPrefix("+++ ") {
                recordCandidatePath(line.dropFirst(4))
                return
            }
            if line.hasPrefix("--- ") {
                recordCandidatePath(line.dropFirst(4))
                return
            }
            if line.hasPrefix("diff --git ") {
                let rest = line.dropFirst("diff --git ".count)
                let parts = rest.split(separator: " ")
                if parts.count >= 2 {
                    // Prefer the 'b/...' side when present.
                    recordCandidatePath(parts[1])
                } else if parts.count == 1 {
                    recordCandidatePath(parts[0])
                }
                return
            }
            if line.hasPrefix("rename to ") {
                recordCandidatePath(line.dropFirst("rename to ".count))
                return
            }
        }

        while index < code.endIndex {
            if code[index] == "\n" {
                processLine(start: lineStart, end: index)
                scanned += 1
                if scanned >= maxScanLines, !counts.isEmpty {
                    break
                }
                index = code.index(after: index)
                lineStart = index
                continue
            }
            index = code.index(after: index)
        }

        if lineStart < code.endIndex {
            processLine(start: lineStart, end: code.endIndex)
        }

        guard !counts.isEmpty else { return nil }

        func orderIndex(_ lang: LanguageID) -> Int {
            firstSeenOrder.firstIndex(of: lang) ?? Int.max
        }

        return counts.max { a, b in
            if a.value != b.value { return a.value < b.value }
            return orderIndex(a.key) > orderIndex(b.key)
        }?.key
    }

    static func looksLikePatch(lines: [Substring]) -> Bool {
        for line in lines {
            let s = trimmingCR(line)
            if s.hasPrefix("diff --git ") { return true }
            if s.hasPrefix("@@") { return true }
            if s.hasPrefix("--- ") || s.hasPrefix("+++ ") { return true }
        }
        return false
    }

    static func kind(forLine line: Substring) -> DiffLineKind? {
        let s = trimmingCR(line)

        if s.hasPrefix("diff --git ") { return .meta }
        if s.hasPrefix("index ") { return .meta }
        if s.hasPrefix("new file mode ") { return .meta }
        if s.hasPrefix("deleted file mode ") { return .meta }
        if s.hasPrefix("rename from ") { return .meta }
        if s.hasPrefix("rename to ") { return .meta }
        if s.hasPrefix("Binary files ") { return .meta }
        if s.hasPrefix("\\ No newline at end of file") { return .meta }

        if s.hasPrefix("@@") { return .hunkHeader }
        if s.hasPrefix("--- ") || s.hasPrefix("+++ ") { return .fileHeader }

        if s.hasPrefix("+") && !s.hasPrefix("+++ ") { return .added }
        if s.hasPrefix("-") && !s.hasPrefix("--- ") { return .removed }

        return nil
    }

    static func hunkStartNumbers(forLine line: Substring) -> (old: Int, new: Int)? {
        let s = trimmingCR(line)
        guard s.hasPrefix("@@") else { return nil }
        guard let dashIndex = s.firstIndex(of: "-"),
              let plusIndex = s.firstIndex(of: "+"),
              dashIndex < plusIndex else { return nil }

        guard let (oldStart, _) = parseNumber(in: s, from: s.index(after: dashIndex)),
              let (newStart, _) = parseNumber(in: s, from: s.index(after: plusIndex)) else {
            return nil
        }

        return (oldStart, newStart)
    }
}

func splitLines(_ string: String) -> [Substring] {
    var result: [Substring] = []
    result.reserveCapacity(64)

    var start = string.startIndex
    while true {
        if let newline = string[start...].firstIndex(of: "\n") {
            result.append(string[start..<newline])
            start = string.index(after: newline)
        } else {
            result.append(string[start..<string.endIndex])
            break
        }
    }
    return result
}

func splitLinesWithBreaks(_ string: String) -> (lines: [Substring], lineBreaks: [Int]) {
    var lines: [Substring] = []
    lines.reserveCapacity(64)
    var lineBreaks: [Int] = []
    lineBreaks.reserveCapacity(max(16, string.count / 64))

    let utf16 = string.utf16
    var startOffset = 0
    var offset = 0
    for value in utf16 {
        if value == 10 {
            let startIndex = String.Index(utf16Offset: startOffset, in: string)
            let endIndex = String.Index(utf16Offset: offset, in: string)
            lines.append(string[startIndex..<endIndex])
            lineBreaks.append(offset)
            startOffset = offset + 1
        }
        offset += 1
    }

    let startIndex = String.Index(utf16Offset: startOffset, in: string)
    lines.append(string[startIndex..<string.endIndex])
    return (lines, lineBreaks)
}

func trimmingCR(_ line: Substring) -> Substring {
    if line.hasSuffix("\r") {
        return line.dropLast()
    }
    return line
}

private func parseNumber(in text: Substring, from index: String.Index) -> (Int, String.Index)? {
    var cursor = index
    var value = 0
    var found = false

    while cursor < text.endIndex {
        guard let digit = text[cursor].wholeNumberValue else { break }
        found = true
        value = (value * 10) + digit
        cursor = text.index(after: cursor)
    }

    guard found else { return nil }
    return (value, cursor)
}
