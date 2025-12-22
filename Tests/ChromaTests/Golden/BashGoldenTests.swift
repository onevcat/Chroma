import Testing
@testable import Chroma

@Suite("Golden - Bash")
struct BashGoldenTests {
    @Test("Loops")
    func loops() throws {
        try assertGolden(
            "for file in $FILES; do",
            language: .bash,
            expected: [
                ExpectedToken(.keyword, "for"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "file"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "in"),
                ExpectedToken.plain(" "),
                ExpectedToken(.property, "$FILES"),
                ExpectedToken(.punctuation, ";"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "do"),
            ]
        )
    }

    @Test("Strings")
    func strings() throws {
        try assertGolden(
            "echo \"$HOME\"",
            language: .bash,
            expected: [
                ExpectedToken(.plain, "echo"),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "\"$HOME\""),
            ]
        )
    }

    @Test("Comments")
    func comments() throws {
        try assertGolden(
            "# note",
            language: .bash,
            expected: [
                ExpectedToken(.comment, "# note"),
            ]
        )
    }

    @Test("Parameter expansion")
    func parameterExpansion() throws {
        try assertGolden(
            "result=${PATH}",
            language: .bash,
            expected: [
                ExpectedToken(.plain, "result"),
                ExpectedToken(.operator, "="),
                ExpectedToken(.property, "${PATH}"),
            ]
        )
    }
}
