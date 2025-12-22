import Testing
@testable import Chroma

@Suite("Golden - XML")
struct XMLGoldenTests {
    @Test("XML declaration")
    func xmlDeclaration() throws {
        try assertGolden(
            "<?xml version=\"1.0\"?>",
            language: .xml,
            expected: [
                ExpectedToken(.keyword, "<?xml version=\"1.0\"?>"),
            ]
        )
    }

    @Test("Tags and attributes")
    func tagsAndAttributes() throws {
        try assertGolden(
            "<note id=\"1\">",
            language: .xml,
            expected: [
                ExpectedToken(.keyword, "<note"),
                ExpectedToken.plain(" "),
                ExpectedToken(.property, "id"),
                ExpectedToken(.punctuation, "="),
                ExpectedToken(.string, "\"1\""),
                ExpectedToken(.punctuation, ">"),
            ]
        )
    }

    @Test("Closing tags")
    func closingTags() throws {
        try assertGolden(
            "</note>",
            language: .xml,
            expected: [
                ExpectedToken(.keyword, "</note"),
                ExpectedToken(.punctuation, ">"),
            ]
        )
    }

    @Test("CDATA")
    func cdata() throws {
        try assertGolden(
            "<![CDATA[<tag>]]>",
            language: .xml,
            expected: [
                ExpectedToken(.string, "<![CDATA[<tag>]]>"),
            ]
        )
    }
}
