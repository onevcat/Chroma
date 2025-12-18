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
        for line in splitLines(code) {
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

