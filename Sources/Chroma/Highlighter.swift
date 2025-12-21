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
            throw Error.languageNotFound(language)
        }

        let theme = options.theme ?? self.theme
        let renderer = Renderer(theme: theme, options: options)
        if options.maySkipTokenization && options.shouldSkipTokenization(for: code) {
            let ns = code as NSString
            let tokens = [Token(kind: .plain, range: NSRange(location: 0, length: ns.length))]
            return renderer.render(code: code, tokens: tokens)
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
            throw Error.languageNotFound(language)
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
            throw Error.languageNotFound(language)
        }

        let tokenizer = RegexTokenizer(rules: language.rules, fastPath: language.fastPath)
        tokenizer.scan(code, emit: emit)
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
