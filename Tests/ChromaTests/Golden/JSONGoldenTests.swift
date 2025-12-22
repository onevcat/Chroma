import Testing
@testable import Chroma

@Suite("Golden - JSON")
struct JSONGoldenTests {
    @Test("Objects")
    func objects() throws {
        try assertGolden(
            "{\"name\": \"Ada\"}",
            language: .json,
            expected: [
                ExpectedToken(.punctuation, "{"),
                ExpectedToken(.string, "\"name\""),
                ExpectedToken(.punctuation, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "\"Ada\""),
                ExpectedToken(.punctuation, "}"),
            ]
        )
    }

    @Test("Numbers")
    func numbers() throws {
        try assertGolden(
            "{\"count\": 3}",
            language: .json,
            expected: [
                ExpectedToken(.punctuation, "{"),
                ExpectedToken(.string, "\"count\""),
                ExpectedToken(.punctuation, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "3"),
                ExpectedToken(.punctuation, "}"),
            ]
        )
    }

    @Test("Arrays and keywords")
    func arraysAndKeywords() throws {
        try assertGolden(
            "[true, false, null]",
            language: .json,
            expected: [
                ExpectedToken(.punctuation, "["),
                ExpectedToken(.keyword, "true"),
                ExpectedToken(.punctuation, ","),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "false"),
                ExpectedToken(.punctuation, ","),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "null"),
                ExpectedToken(.punctuation, "]"),
            ]
        )
    }

    @Test("Nested arrays")
    func nestedArrays() throws {
        try assertGolden(
            "[1, 2, 3]",
            language: .json,
            expected: [
                ExpectedToken(.punctuation, "["),
                ExpectedToken(.number, "1"),
                ExpectedToken(.punctuation, ","),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "2"),
                ExpectedToken(.punctuation, ","),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "3"),
                ExpectedToken(.punctuation, "]"),
            ]
        )
    }
}
