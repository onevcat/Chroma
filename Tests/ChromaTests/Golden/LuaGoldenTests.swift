import Testing
@testable import Chroma

@Suite("Golden - Lua")
struct LuaGoldenTests {
    @Test("Local bindings")
    func localBindings() throws {
        try assertGolden(
            "local value = 1",
            language: .lua,
            expected: [
                ExpectedToken(.keyword, "local"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "1"),
            ]
        )
    }

    @Test("Functions")
    func functions() throws {
        try assertGolden(
            "function greet(name) return name end",
            language: .lua,
            expected: [
                ExpectedToken(.keyword, "function"),
                ExpectedToken.plain(" "),
                ExpectedToken(.function, "greet"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "name"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "return"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "name"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "end"),
            ]
        )
    }

    @Test("Comments")
    func comments() throws {
        try assertGolden(
            "-- note",
            language: .lua,
            expected: [
                ExpectedToken(.comment, "-- note"),
            ]
        )
    }

    @Test("Long strings")
    func longStrings() throws {
        try assertGolden(
            "text = [[hi]]",
            language: .lua,
            expected: [
                ExpectedToken(.plain, "text"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "[[hi]]"),
            ]
        )
    }
}
