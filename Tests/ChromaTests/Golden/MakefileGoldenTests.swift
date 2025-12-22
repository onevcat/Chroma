import Testing
@testable import Chroma

@Suite("Golden - Makefile")
struct MakefileGoldenTests {
    @Test("Targets")
    func targets() throws {
        try assertGolden(
            "build: main.o",
            language: .makefile,
            expected: [
                ExpectedToken(.keyword, "build"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "main"),
                ExpectedToken(.punctuation, "."),
                ExpectedToken(.plain, "o"),
            ]
        )
    }

    @Test("Variable expansion")
    func variableExpansion() throws {
        try assertGolden(
            "\t$(CC) -o app main.o",
            language: .makefile,
            expected: [
                ExpectedToken.plain("\t"),
                ExpectedToken(.property, "$(CC)"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "-"),
                ExpectedToken(.plain, "o"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "app"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "main"),
                ExpectedToken(.punctuation, "."),
                ExpectedToken(.plain, "o"),
            ]
        )
    }

    @Test("Comments")
    func comments() throws {
        try assertGolden(
            "# note",
            language: .makefile,
            expected: [
                ExpectedToken(.comment, "# note"),
            ]
        )
    }

    @Test("Variables")
    func variables() throws {
        try assertGolden(
            "sources = ${SRC}",
            language: .makefile,
            expected: [
                ExpectedToken(.plain, "sources"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.property, "${SRC}"),
            ]
        )
    }
}
