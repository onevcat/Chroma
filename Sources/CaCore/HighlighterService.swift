import Chroma
import Foundation

struct HighlightedDocument {
    let title: String
    let lines: [String]
}

struct HighlighterService {
    private let highlighter: Highlighter
    private let options: HighlightOptions

    init(theme: Theme, lineNumbers: Bool) {
        self.highlighter = Highlighter(theme: theme)
        self.options = HighlightOptions(
            colorMode: .auto(output: .stdout),
            missingLanguageHandling: .fallbackToPlainText,
            lineNumbers: lineNumbers ? LineNumberOptions() : .none
        )
    }

    func render(_ input: InputFile) throws -> HighlightedDocument {
        let output = try highlighter.highlight(
            input.content,
            language: input.language,
            options: options
        )
        return HighlightedDocument(
            title: input.displayName,
            lines: output.splitLinesPreservingEmpty()
        )
    }
}

private extension String {
    func splitLinesPreservingEmpty() -> [String] {
        let parts = split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
        if parts.isEmpty {
            return [""]
        }
        return parts.map(String.init)
    }
}
