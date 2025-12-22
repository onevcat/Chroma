import Foundation

struct MarkdownTokenizer {
    private struct FenceInfo {
        let marker: Character
        let count: Int
        let language: Substring?
    }

    private enum SegmentKind {
        case markdown
        case code(LanguageID?)
    }

    private let markdownRules: [TokenRule]
    private let registry: LanguageRegistry

    init(rules: [TokenRule], registry: LanguageRegistry) {
        self.markdownRules = rules
        self.registry = registry
    }

    func tokenize(_ code: String) -> [Token] {
        var tokens: [Token] = []
        scan(code) { token in
            tokens.append(token)
        }
        return tokens
    }

    func scan(_ code: String, emit: (Token) -> Void) {
        let lines = splitLines(code)
        let markdownTokenizer = RegexTokenizer(rules: markdownRules)
        var tokenizerCache: [LanguageID: RegexTokenizer] = [:]

        var inFence = false
        var fenceMarker: Character = "`"
        var fenceCount = 3
        var fenceLanguage: LanguageID?

        var segmentStart = code.startIndex
        var lineStart = code.startIndex

        func appendSegment(start: String.Index, end: String.Index, kind: SegmentKind) {
            guard start < end else { return }
            let range = NSRange(start..<end, in: code)
            let segment = String(code[start..<end])
            switch kind {
            case .markdown:
                markdownTokenizer.scan(segment) { token in
                    emit(Token(kind: token.kind, range: NSRange(location: range.location + token.range.location, length: token.range.length)))
                }
            case .code(let language):
                guard let language else {
                    emit(Token(kind: .plain, range: range))
                    return
                }
                guard let definition = registry.language(for: language) else {
                    emit(Token(kind: .plain, range: range))
                    return
                }
                let tokenizer = tokenizerCache[definition.id] ?? RegexTokenizer(rules: definition.rules, fastPath: definition.fastPath)
                tokenizerCache[definition.id] = tokenizer
                tokenizer.scan(segment) { token in
                    emit(Token(kind: token.kind, range: NSRange(location: range.location + token.range.location, length: token.range.length)))
                }
            }
        }

        for line in lines {
            let lineEnd = line.endIndex
            let hasNewline = lineEnd < code.endIndex && code[lineEnd] == "\n"
            let lineEndWithNewline = hasNewline ? code.index(after: lineEnd) : lineEnd

            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if let fence = parseFence(Substring(trimmed)) {
                if !inFence {
                    appendSegment(start: segmentStart, end: lineStart, kind: .markdown)
                    appendSegment(start: lineStart, end: lineEndWithNewline, kind: .markdown)
                    inFence = true
                    fenceMarker = fence.marker
                    fenceCount = fence.count
                    fenceLanguage = resolveLanguage(fence.language)
                    if fenceLanguage == .markdown || fenceLanguage == .md {
                        fenceLanguage = nil
                    }
                    segmentStart = lineEndWithNewline
                } else if fence.marker == fenceMarker && fence.count >= fenceCount {
                    appendSegment(start: segmentStart, end: lineStart, kind: .code(fenceLanguage))
                    appendSegment(start: lineStart, end: lineEndWithNewline, kind: .markdown)
                    inFence = false
                    fenceLanguage = nil
                    segmentStart = lineEndWithNewline
                }
            }

            lineStart = lineEndWithNewline
        }

        if inFence {
            appendSegment(start: segmentStart, end: code.endIndex, kind: .code(fenceLanguage))
        } else {
            appendSegment(start: segmentStart, end: code.endIndex, kind: .markdown)
        }
    }

    private func parseFence(_ line: Substring) -> FenceInfo? {
        guard let first = line.first, first == "`" || first == "~" else { return nil }
        var index = line.startIndex
        var count = 0
        while index < line.endIndex, line[index] == first {
            count += 1
            index = line.index(after: index)
        }
        guard count >= 3 else { return nil }

        var remainder = line[index...]
        if let firstNonSpace = remainder.firstIndex(where: { !$0.isWhitespace }) {
            remainder = remainder[firstNonSpace...]
        } else {
            remainder = ""
        }

        let languageToken: Substring?
        if remainder.isEmpty {
            languageToken = nil
        } else if let space = remainder.firstIndex(where: { $0.isWhitespace }) {
            languageToken = remainder[..<space]
        } else {
            languageToken = remainder
        }

        return FenceInfo(marker: first, count: count, language: languageToken)
    }

    private func resolveLanguage(_ token: Substring?) -> LanguageID? {
        guard let token, !token.isEmpty else { return nil }
        let normalized = token.lowercased()

        let aliases: [String: LanguageID] = [
            "js": .javascript,
            "jsx": .jsx,
            "ts": .typescript,
            "tsx": .tsx,
            "c++": .cpp,
            "cpp": .cpp,
            "cxx": .cpp,
            "h++": .cpp,
            "cc": .cpp,
            "sh": .bash,
            "zsh": .zsh,
            "shell": .bash,
            "bash": .bash,
            "yml": .yaml,
            "md": .markdown,
            "markdown": .markdown,
        ]

        if let mapped = aliases[normalized] {
            return registry.language(for: mapped) != nil ? mapped : nil
        }

        let direct = LanguageID(rawValue: normalized)
        if registry.language(for: direct) != nil {
            return direct
        }

        return nil
    }
}
