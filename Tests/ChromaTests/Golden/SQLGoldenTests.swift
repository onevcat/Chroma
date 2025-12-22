import Testing
@testable import Chroma

@Suite("Golden - SQL")
struct SQLGoldenTests {
    @Test("Select queries")
    func selectQueries() throws {
        try assertGolden(
            "SELECT * FROM users",
            language: .sql,
            expected: [
                ExpectedToken(.keyword, "SELECT"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "*"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "FROM"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "users"),
            ]
        )
    }

    @Test("Where clauses")
    func whereClauses() throws {
        try assertGolden(
            "WHERE id = 1",
            language: .sql,
            expected: [
                ExpectedToken(.keyword, "WHERE"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "id"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "1"),
            ]
        )
    }

    @Test("Insert statements")
    func insertStatements() throws {
        try assertGolden(
            "INSERT INTO users (id) VALUES (1);",
            language: .sql,
            expected: [
                ExpectedToken(.keyword, "INSERT"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "INTO"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "users"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "id"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "VALUES"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.number, "1"),
                ExpectedToken(.punctuation, ");"),
            ]
        )
    }

    @Test("Line comments")
    func lineComments() throws {
        try assertGolden(
            "-- note",
            language: .sql,
            expected: [
                ExpectedToken(.comment, "-- note"),
            ]
        )
    }
}
