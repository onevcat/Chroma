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

        if s.hasPrefix("@@") { return .hunkHeader }
        if s.hasPrefix("--- ") || s.hasPrefix("+++ ") { return .fileHeader }

        if s.hasPrefix("+") && !s.hasPrefix("+++ ") { return .added }
        if s.hasPrefix("-") && !s.hasPrefix("--- ") { return .removed }

        return nil
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

func trimmingCR(_ line: Substring) -> Substring {
    if line.hasSuffix("\r") {
        return line.dropLast()
    }
    return line
}
