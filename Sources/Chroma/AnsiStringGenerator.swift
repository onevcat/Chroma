import Rainbow

enum AnsiStringGenerator {
    static func generate(for entry: Rainbow.Entry) -> String {
        generate(for: entry, isEnabled: Rainbow.enabled)
    }

    static func generate(for entry: Rainbow.Entry, isEnabled: Bool) -> String {
        guard isEnabled else {
            return entry.plainText
        }

        struct PrefixCacheEntry {
            let color: ColorType?
            let backgroundColor: BackgroundColorType?
            let styles: [Style]?
            let prefix: String

            func matches(_ segment: Rainbow.Segment) -> Bool {
                color == segment.color &&
                    backgroundColor == segment.backgroundColor &&
                    styles == segment.styles
            }
        }

        // Mirrors Rainbow's console generator behavior, but does not depend on `stdout` being a TTY.
        let totalTextLength = entry.segments.reduce(0) { $0 + $1.text.count }
        let estimatedTotalLength = totalTextLength + (entry.segments.count * 20)

        var result = ""
        result.reserveCapacity(estimatedTotalLength)
        var prefixCache: [PrefixCacheEntry] = []
        prefixCache.reserveCapacity(16)

        for segment in entry.segments {
            if segment.isPlain {
                result.append(segment.text)
                continue
            }

            if segment.text.isEmpty {
                result.append(segment.text)
                continue
            }

            if let cached = prefixCache.first(where: { $0.matches(segment) }) {
                result.append(cached.prefix)
                result.append(segment.text)
                result.append("\u{001B}[0m")
                continue
            }

            var codes: [UInt8] = []
            if let color = segment.color { codes += color.value }
            if let backgroundColor = segment.backgroundColor { codes += backgroundColor.value }
            if let styles = segment.styles { codes += styles.flatMap { $0.value } }

            if codes.isEmpty {
                result.append(segment.text)
                continue
            }

            var prefix = "\u{001B}["
            for (index, code) in codes.enumerated() {
                if index > 0 { prefix.append(";") }
                prefix.append(String(code))
            }
            prefix.append("m")
            prefixCache.append(
                PrefixCacheEntry(
                    color: segment.color,
                    backgroundColor: segment.backgroundColor,
                    styles: segment.styles,
                    prefix: prefix
                )
            )
            result.append(prefix)
            result.append(segment.text)
            result.append("\u{001B}[0m")
        }

        return result
    }
}
