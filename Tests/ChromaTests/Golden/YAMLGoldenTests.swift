import Testing
@testable import Chroma

@Suite("Golden - YAML")
struct YAMLGoldenTests {
    @Test("Key value pairs")
    func keyValuePairs() throws {
        try assertGolden(
            "name: \"Ada\"",
            language: .yaml,
            expected: [
                ExpectedToken(.property, "name"),
                ExpectedToken(.punctuation, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "\"Ada\""),
            ]
        )
    }

    @Test("Booleans")
    func booleans() throws {
        try assertGolden(
            "enabled: true",
            language: .yaml,
            expected: [
                ExpectedToken(.property, "enabled"),
                ExpectedToken(.punctuation, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "true"),
            ]
        )
    }

    @Test("Numbers")
    func numbers() throws {
        try assertGolden(
            "count: 3",
            language: .yaml,
            expected: [
                ExpectedToken(.property, "count"),
                ExpectedToken(.punctuation, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "3"),
            ]
        )
    }

    @Test("Comments")
    func comments() throws {
        try assertGolden(
            "name: Ada # note",
            language: .yaml,
            expected: [
                ExpectedToken(.property, "name"),
                ExpectedToken(.punctuation, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "Ada"),
                ExpectedToken.plain(" "),
                ExpectedToken(.comment, "# note"),
            ]
        )
    }
}
