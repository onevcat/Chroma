import Testing
@testable import Chroma

@Suite("Golden - C++")
struct CppGoldenTests {
    @Test("Class declarations")
    func classDeclarations() throws {
        try assertGolden(
            "class User {}",
            language: .cpp,
            expected: [
                ExpectedToken(.keyword, "class"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "User"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{}"),
            ]
        )
    }

    @Test("Preprocessor directives")
    func preprocessorDirectives() throws {
        try assertGolden(
            "#include <vector>",
            language: .cpp,
            expected: [
                ExpectedToken(.keyword, "#include <vector>"),
            ]
        )
    }

    @Test("Types and strings")
    func typesAndStrings() throws {
        try assertGolden(
            "std::string name = \"Ada\";",
            language: .cpp,
            expected: [
                ExpectedToken(.type, "std"),
                ExpectedToken(.operator, "::"),
                ExpectedToken(.type, "string"),
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

    @Test("Auto and numbers")
    func autoAndNumbers() throws {
        try assertGolden(
            "auto count = 1;",
            language: .cpp,
            expected: [
                ExpectedToken(.keyword, "auto"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "count"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "1"),
                ExpectedToken(.punctuation, ";"),
            ]
        )
    }
}
