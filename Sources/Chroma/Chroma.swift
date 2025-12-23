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

    /// Highlight code by detecting language from a file name.
    public static func highlight(
        _ code: String,
        fileName: String,
        options: HighlightOptions = .init(fallbackMode: .silent)
    ) throws -> String {
        try highlight(code, language: .fromFileName(fileName), options: options)
    }

    /// Highlight code by detecting language from a file path.
    public static func highlight(
        _ code: String,
        filePath: String,
        options: HighlightOptions = .init(fallbackMode: .silent)
    ) throws -> String {
        try highlight(code, language: .fromFilePath(filePath), options: options)
    }

    /// Highlight code by detecting language from a file URL.
    public static func highlight(
        _ code: String,
        fileURL: URL,
        options: HighlightOptions = .init(fallbackMode: .silent)
    ) throws -> String {
        try highlight(code, language: .fromFileURL(fileURL), options: options)
    }

    public static func tokenize(
        _ code: String,
        language: LanguageID
    ) throws -> [Token] {
        try shared.tokenize(code, language: language)
    }

    public static func tokenize(
        _ code: String,
        language: LanguageID,
        emit: (Token) -> Void
    ) throws {
        try shared.tokenize(code, language: language, emit: emit)
    }

    public static func render(
        _ code: String,
        tokens: [Token],
        options: HighlightOptions = .init()
    ) -> String {
        shared.render(code, tokens: tokens, options: options)
    }

    public static func render(
        _ code: String,
        options: HighlightOptions = .init(),
        tokenStream: (_ emit: (Token) -> Void) -> Void
    ) -> String {
        shared.render(code, options: options, tokenStream: tokenStream)
    }
}
