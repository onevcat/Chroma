import Foundation
import Rainbow

public final class Highlighter {
    public enum Error: Swift.Error, Equatable {
        case languageNotFound(LanguageID)
    }

    public var theme: Theme
    public let registry: LanguageRegistry

    public init(theme: Theme = .dark, registry: LanguageRegistry = .builtIn()) {
        self.theme = theme
        self.registry = registry
    }

    public func highlight(
        _ code: String,
        language: LanguageID,
        options: HighlightOptions = .init()
    ) throws -> String {
        guard let language = registry.language(for: language) else {
            if options.fallbackMode == .silent || language == .none || language == .plain {
                return renderPlain(code, options: options)
            }
            throw Error.languageNotFound(language)
        }

        let theme = options.theme ?? self.theme
        let renderer = Renderer(theme: theme, options: options)
        if options.maySkipTokenization && options.shouldSkipTokenization(for: code) {
            let ns = code as NSString
            let tokens = [Token(kind: .plain, range: NSRange(location: 0, length: ns.length))]
            return renderer.render(code: code, tokens: tokens)
        }
        if isMarkdown(language.id) {
            let tokenizer = MarkdownTokenizer(rules: language.rules, registry: registry)
            return renderer.render(code: code, tokens: tokenizer.tokenize(code))
        }
        let tokenizer = RegexTokenizer(rules: language.rules, fastPath: language.fastPath)
        return renderer.render(code: code) { emit in
            tokenizer.scan(code, emit: emit)
        }
    }

    public func tokenize(
        _ code: String,
        language: LanguageID
    ) throws -> [Token] {
        guard let language = registry.language(for: language) else {
            if language == .none || language == .plain {
                let ns = code as NSString
                return [Token(kind: .plain, range: NSRange(location: 0, length: ns.length))]
            }
            throw Error.languageNotFound(language)
        }

        if isMarkdown(language.id) {
            let tokenizer = MarkdownTokenizer(rules: language.rules, registry: registry)
            return tokenizer.tokenize(code)
        }
        let tokenizer = RegexTokenizer(rules: language.rules, fastPath: language.fastPath)
        return tokenizer.tokenize(code)
    }

    public func tokenize(
        _ code: String,
        language: LanguageID,
        emit: (Token) -> Void
    ) throws {
        guard let language = registry.language(for: language) else {
            if language == .none || language == .plain {
                let ns = code as NSString
                emit(Token(kind: .plain, range: NSRange(location: 0, length: ns.length)))
                return
            }
            throw Error.languageNotFound(language)
        }

        if isMarkdown(language.id) {
            let tokenizer = MarkdownTokenizer(rules: language.rules, registry: registry)
            tokenizer.scan(code, emit: emit)
            return
        }
        let tokenizer = RegexTokenizer(rules: language.rules, fastPath: language.fastPath)
        tokenizer.scan(code, emit: emit)
    }

    private func isMarkdown(_ id: LanguageID) -> Bool {
        id.rawValue == LanguageID.markdown.rawValue || id.rawValue == LanguageID.md.rawValue
    }

    private func renderPlain(_ code: String, options: HighlightOptions) -> String {
        let theme = options.theme ?? self.theme
        let renderer = Renderer(theme: theme, options: options)
        let ns = code as NSString
        let tokens = [Token(kind: .plain, range: NSRange(location: 0, length: ns.length))]
        return renderer.render(code: code, tokens: tokens)
    }

    public func render(
        _ code: String,
        tokens: [Token],
        options: HighlightOptions = .init()
    ) -> String {
        let theme = options.theme ?? self.theme
        let renderer = Renderer(theme: theme, options: options)
        return renderer.render(code: code, tokens: tokens)
    }

    public func render(
        _ code: String,
        options: HighlightOptions = .init(),
        tokenStream: (_ emit: (Token) -> Void) -> Void
    ) -> String {
        let theme = options.theme ?? self.theme
        let renderer = Renderer(theme: theme, options: options)
        return renderer.render(code: code, tokenStream: tokenStream)
    }
}
