import Rainbow

enum AnsiStringGenerator {
    static func generate(for entry: Rainbow.Entry) -> String {
        guard Rainbow.enabled else {
            return entry.plainText
        }

        // Mirrors Rainbow's console generator behavior, but does not depend on `stdout` being a TTY.
        let totalTextLength = entry.segments.reduce(0) { $0 + $1.text.count }
        let estimatedTotalLength = totalTextLength + (entry.segments.count * 20)

        var result = ""
        result.reserveCapacity(estimatedTotalLength)

        for segment in entry.segments {
            if segment.isPlain {
                result.append(segment.text)
                continue
            }

            var codes: [UInt8] = []
            if let color = segment.color { codes += color.value }
            if let backgroundColor = segment.backgroundColor { codes += backgroundColor.value }
            if let styles = segment.styles { codes += styles.flatMap { $0.value } }

            if codes.isEmpty || segment.text.isEmpty {
                result.append(segment.text)
                continue
            }

            result.append("\u{001B}[")
            for (index, code) in codes.enumerated() {
                if index > 0 { result.append(";") }
                result.append(String(code))
            }
            result.append("m")
            result.append(segment.text)
            result.append("\u{001B}[0m")
        }

        return result
    }
}
