@_spi(Benchmarking)
public struct TokenBuffer {
    fileprivate let tokens: [Token]

    public var count: Int { tokens.count }
}

@_spi(Benchmarking)
public enum BenchmarkSupport {
    public static func tokenize(
        _ code: String,
        language: LanguageID,
        registry: LanguageRegistry = .builtIn()
    ) throws -> TokenBuffer {
        guard let language = registry.language(for: language) else {
            throw Highlighter.Error.languageNotFound(language)
        }

        let tokenizer = RegexTokenizer(rules: language.rules)
        return TokenBuffer(tokens: tokenizer.tokenize(code))
    }

    public static func tokenize(
        _ code: String,
        language: LanguageID,
        registry: LanguageRegistry = .builtIn(),
        metrics: inout TokenizerMetrics
    ) throws -> TokenBuffer {
        guard let language = registry.language(for: language) else {
            throw Highlighter.Error.languageNotFound(language)
        }

        let tokenizer = RegexTokenizer(rules: language.rules)
        return TokenBuffer(tokens: tokenizer.tokenize(code, metrics: &metrics))
    }

    public static func render(
        _ code: String,
        tokens: TokenBuffer,
        theme: Theme,
        options: HighlightOptions = .init()
    ) -> String {
        let renderer = Renderer(theme: theme, options: options)
        return renderer.render(code: code, tokens: tokens.tokens)
    }

    public static func splitLinesForBenchmark(_ code: String) -> [Substring] {
        splitLines(code)
    }

    public static func diffLooksLikePatch(_ code: String) -> Bool {
        DiffDetector.looksLikePatch(code)
    }

    public static func diffLineKindCount(lines: [Substring]) -> Int {
        var count = 0
        for line in lines {
            if DiffDetector.kind(forLine: line) != nil {
                count += 1
            }
        }
        return count
    }
}
