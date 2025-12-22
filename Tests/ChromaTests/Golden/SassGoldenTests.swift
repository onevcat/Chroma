import Testing
@testable import Chroma

@Suite("Golden - Sass")
struct SassGoldenTests {
    @Test("Variables")
    func variables() throws {
        try assertGolden(
            "$primary: #fff",
            language: .sass,
            expected: [
                ExpectedToken(.property, "$primary"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "#fff"),
            ]
        )
    }

    @Test("At rules")
    func atRules() throws {
        try assertGolden(
            "@import \"base\"",
            language: .sass,
            expected: [
                ExpectedToken(.keyword, "@import"),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "\"base\""),
            ]
        )
    }

    @Test("Selectors")
    func selectors() throws {
        try assertGolden(
            ".card",
            language: .sass,
            expected: [
                ExpectedToken(.type, ".card"),
            ]
        )
    }

    @Test("Strings")
    func strings() throws {
        try assertGolden(
            "content: 'hi'",
            language: .sass,
            expected: [
                ExpectedToken(.property, "content"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "'hi'"),
            ]
        )
    }
}
