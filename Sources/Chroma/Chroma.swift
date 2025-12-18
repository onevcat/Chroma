import Foundation

/// Namespace of the `Chroma` module.
public enum Chroma {
    /// A shared highlighter instance with built-in languages and the `.dark` theme.
    public static let shared = Highlighter()

    /// Convenience helper for one-off highlighting using `Chroma.shared`.
    public static func highlight(
        _ code: String,
        language: LanguageID,
        options: HighlightOptions = .init()
    ) throws -> String {
        try shared.highlight(code, language: language, options: options)
    }
}
