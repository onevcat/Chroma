import Rainbow
import Testing
@testable import Chroma

@Suite("AnsiStringGenerator")
struct AnsiStringGeneratorTests {
    @Test("Generates ANSI codes for styled segments")
    func generatesAnsiCodes() {
        let entry = Rainbow.Entry(segments: [
            Rainbow.Segment(text: "hi", color: .named(.red), backgroundColor: nil, styles: [.bold])
        ])

        let output = withRainbowEnabled(true) {
            AnsiStringGenerator.generate(for: entry)
        }

        #expect(output == "\u{001B}[31;1mhi\u{001B}[0m")
    }

    @Test("Preserves plain segments")
    func preservesPlainSegments() {
        let entry = Rainbow.Entry(segments: [
            Rainbow.Segment(text: "plain "),
            Rainbow.Segment(text: "styled", color: .named(.blue), backgroundColor: nil, styles: nil)
        ])

        let output = withRainbowEnabled(true) {
            AnsiStringGenerator.generate(for: entry)
        }

        #expect(output == "plain \u{001B}[34mstyled\u{001B}[0m")
    }
}
