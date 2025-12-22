import Testing
@testable import Chroma

@Suite("Golden - HTML")
struct HTMLGoldenTests {
    @Test("Tags and attributes")
    func tagsAndAttributes() throws {
        try assertGolden(
            "<div class=\"box\">",
            language: .html,
            expected: [
                ExpectedToken(.keyword, "<div"),
                ExpectedToken.plain(" "),
                ExpectedToken(.property, "class"),
                ExpectedToken(.punctuation, "="),
                ExpectedToken(.string, "\"box\""),
                ExpectedToken(.punctuation, ">"),
            ]
        )
    }

    @Test("Closing tags")
    func closingTags() throws {
        try assertGolden(
            "</div>",
            language: .html,
            expected: [
                ExpectedToken(.keyword, "</div"),
                ExpectedToken(.punctuation, ">"),
            ]
        )
    }

    @Test("Comments")
    func comments() throws {
        try assertGolden(
            "<!-- note -->",
            language: .html,
            expected: [
                ExpectedToken(.comment, "<!-- note -->"),
            ]
        )
    }

    @Test("Self closing tags")
    func selfClosingTags() throws {
        try assertGolden(
            "<input data-id=\"1\" />",
            language: .html,
            expected: [
                ExpectedToken(.keyword, "<input"),
                ExpectedToken.plain(" "),
                ExpectedToken(.property, "data-id"),
                ExpectedToken(.punctuation, "="),
                ExpectedToken(.string, "\"1\""),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "/>"),
            ]
        )
    }
}
