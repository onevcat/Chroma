import Testing
@testable import Chroma

@Suite("Golden - C#")
struct CSharpGoldenTests {
    @Test("Properties and strings")
    func propertiesAndStrings() throws {
        try assertGolden(
            "Console.WriteLine(\"hi\");",
            language: .csharp,
            expected: [
                ExpectedToken(.plain, "Console"),
                ExpectedToken(.property, ".WriteLine"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.string, "\"hi\""),
                ExpectedToken(.punctuation, ");"),
            ]
        )
    }

    @Test("Keywords and numbers")
    func keywordsNumbers() throws {
        try assertGolden(
            "var total = 3.14",
            language: .csharp,
            expected: [
                ExpectedToken(.keyword, "var"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "total"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "3.14"),
            ]
        )
    }

    @Test("Using directives")
    func usingDirectives() throws {
        try assertGolden(
            "using System;",
            language: .csharp,
            expected: [
                ExpectedToken(.keyword, "using"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "System"),
                ExpectedToken(.punctuation, ";"),
            ]
        )
    }

    @Test("Interpolated strings")
    func interpolatedStrings() throws {
        try assertGolden(
            "var text = $\"Hi {name}\"",
            language: .csharp,
            expected: [
                ExpectedToken(.keyword, "var"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "text"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "$\"Hi {name}\""),
            ]
        )
    }
}
