import Testing
@testable import Chroma

@Suite("Golden - Dart")
struct DartGoldenTests {
    @Test("Class declarations")
    func classDeclarations() throws {
        try assertGolden(
            "class User {}",
            language: .dart,
            expected: [
                ExpectedToken(.keyword, "class"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "User"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{}"),
            ]
        )
    }

    @Test("Final fields")
    func finalFields() throws {
        try assertGolden(
            "final String name = \"Ada\";",
            language: .dart,
            expected: [
                ExpectedToken(.keyword, "final"),
                ExpectedToken.plain(" "),
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

    @Test("Async functions")
    func asyncFunctions() throws {
        try assertGolden(
            "Future<int> load() async {}",
            language: .dart,
            expected: [
                ExpectedToken(.type, "Future"),
                ExpectedToken(.operator, "<"),
                ExpectedToken(.type, "int"),
                ExpectedToken(.operator, ">"),
                ExpectedToken.plain(" "),
                ExpectedToken(.function, "load"),
                ExpectedToken(.punctuation, "()"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "async"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{}"),
            ]
        )
    }

    @Test("Null checks")
    func nullChecks() throws {
        try assertGolden(
            "if (value == null) return;",
            language: .dart,
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
