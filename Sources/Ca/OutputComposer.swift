import Foundation

struct OutputComposer {
    func compose(
        documents: [HighlightedDocument],
        showHeaders: Bool
    ) -> [String] {
        guard !documents.isEmpty else { return [] }
        let needsHeader = showHeaders && documents.count > 1
        var lines: [String] = []

        for (index, doc) in documents.enumerated() {
            if needsHeader {
                lines.append("==> \(doc.title) <==")
            }
            lines.append(contentsOf: doc.lines)
            if index < documents.count - 1 {
                lines.append("")
            }
        }
        return lines
    }
}
