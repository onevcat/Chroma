import Testing
@testable import Chroma

@Suite("Golden - Java")
struct JavaGoldenTests {
    @Test("Class declarations")
    func classDeclarations() throws {
        try assertGolden(
            "public class User {}",
            language: .java,
            expected: [
                ExpectedToken(.keyword, "public"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "class"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "User"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{}"),
            ]
        )
    }

    @Test("Types and strings")
    func typesAndStrings() throws {
        try assertGolden(
            "String name = \"Ada\";",
            language: .java,
            expected: [
                ExpectedToken(.type, "String"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "name"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "\"Ada\""),
                ExpectedToken(.punctuation, ";"),
            ]
        )
    }

    @Test("Annotations and methods")
    func annotationsAndMethods() throws {
        try assertGolden(
            "@Override\nvoid run() {}",
            language: .java,
            expected: [
                ExpectedToken(.keyword, "@Override"),
                ExpectedToken.plain("\n"),
                ExpectedToken(.keyword, "void"),
                ExpectedToken.plain(" "),
                ExpectedToken(.function, "run"),
                ExpectedToken(.punctuation, "()"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{}"),
            ]
        )
    }

    @Test("Null checks")
    func nullChecks() throws {
        try assertGolden(
            "if (value == null) return;",
            language: .java,
            expected: [
                ExpectedToken(.keyword, "if"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "=="),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "null"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "return"),
                ExpectedToken(.punctuation, ";"),
            ]
        )
    }
}
