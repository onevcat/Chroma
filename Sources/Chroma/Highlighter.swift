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
        let tokenizer = RegexTokenizer(rules: language.rules)
        let tokens = tokenizer.tokenize(code)

        let renderer = Renderer(theme: theme, options: options)
        return renderer.render(code: code, tokens: tokens)
    }
}

