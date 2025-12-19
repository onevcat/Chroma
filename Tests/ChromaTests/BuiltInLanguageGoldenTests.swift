import Testing
@testable import Chroma

@Suite("Golden - Swift")
struct SwiftGoldenTests {
    @Test("Basic keywords and numbers")
    func basicKeywords() throws {
        try assertGolden(
            "let value = 42",
            language: .swift,
            expected: [
                ExpectedToken(.keyword, "let"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "42"),
            ]
        )
    }

    @Test("Functions, strings, and comments")
    func functionStringComment() throws {
        try assertGolden(
            "print(\"hi\") // note",
            language: .swift,
            expected: [
                ExpectedToken(.function, "print"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.string, "\"hi\""),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.comment, "// note"),
            ]
        )
    }
}

@Suite("Golden - Objective-C")
struct ObjectiveCGoldenTests {
    @Test("Types and strings")
    func typesAndStrings() throws {
        try assertGolden(
            "NSString *name = @\"hi\"",
            language: .objectiveC,
            expected: [
                ExpectedToken(.type, "NSString"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "*"),
                ExpectedToken(.plain, "name"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "@\"hi\""),
            ]
        )
    }

    @Test("Keywords, operators, and numbers")
    func keywordsOperatorsNumbers() throws {
        try assertGolden(
            "if (value == 0) {}",
            language: .objectiveC,
            expected: [
                ExpectedToken(.keyword, "if"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "=="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "0"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{}"),
            ]
        )
    }
}

@Suite("Golden - C")
struct CGoldenTests {
    @Test("Keywords and hex numbers")
    func keywordsNumbers() throws {
        try assertGolden(
            "int value = 0x2A",
            language: .c,
            expected: [
                ExpectedToken(.keyword, "int"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "0x2A"),
            ]
        )
    }

    @Test("Functions, strings, and punctuation")
    func functionsAndStrings() throws {
        try assertGolden(
            "printf(\"hi\");",
            language: .c,
            expected: [
                ExpectedToken(.function, "printf"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.string, "\"hi\""),
                ExpectedToken(.punctuation, ");"),
            ]
        )
    }
}

@Suite("Golden - JavaScript")
struct JavaScriptGoldenTests {
    @Test("Keywords and numbers")
    func keywordsNumbers() throws {
        try assertGolden(
            "const value = 42",
            language: .javascript,
            expected: [
                ExpectedToken(.keyword, "const"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "42"),
            ]
        )
    }

    @Test("Properties and strings")
    func propertiesAndStrings() throws {
        try assertGolden(
            "console.log(\"hi\")",
            language: .javascript,
            expected: [
                ExpectedToken(.plain, "console"),
                ExpectedToken(.property, ".log"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.string, "\"hi\""),
                ExpectedToken(.punctuation, ")"),
            ]
        )
    }
}

@Suite("Golden - TypeScript")
struct TypeScriptGoldenTests {
    @Test("Keywords and object shapes")
    func keywordsAndObjects() throws {
        try assertGolden(
            "type User = { id: number }",
            language: .typescript,
            expected: [
                ExpectedToken(.keyword, "type"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "User"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "id"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.keyword, "number"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "}"),
            ]
        )
    }

    @Test("Generics and arrays")
    func genericsAndArrays() throws {
        try assertGolden(
            "const list: Array<string> = []",
            language: .typescript,
            expected: [
                ExpectedToken(.keyword, "const"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "list"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.type, "Array"),
                ExpectedToken(.operator, "<"),
                ExpectedToken(.keyword, "string"),
                ExpectedToken(.operator, ">"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "[]"),
            ]
        )
    }
}

@Suite("Golden - Python")
struct PythonGoldenTests {
    @Test("Functions and punctuation")
    func functionsAndPunctuation() throws {
        try assertGolden(
            "def greet(name):",
            language: .python,
            expected: [
                ExpectedToken(.keyword, "def"),
                ExpectedToken.plain(" "),
                ExpectedToken(.function, "greet"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "name"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken(.operator, ":"),
            ]
        )
    }

    @Test("Strings and comments")
    func stringsAndComments() throws {
        try assertGolden(
            "return \"hi\" # note",
            language: .python,
            expected: [
                ExpectedToken(.keyword, "return"),
                ExpectedToken.plain(" "),
                ExpectedToken(.string, "\"hi\""),
                ExpectedToken.plain(" "),
                ExpectedToken(.comment, "# note"),
            ]
        )
    }
}

@Suite("Golden - Ruby")
struct RubyGoldenTests {
    @Test("Functions and punctuation")
    func functionsAndPunctuation() throws {
        try assertGolden(
            "def greet(name)",
            language: .ruby,
            expected: [
                ExpectedToken(.keyword, "def"),
                ExpectedToken.plain(" "),
                ExpectedToken(.function, "greet"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "name"),
                ExpectedToken(.punctuation, ")"),
            ]
        )
    }

    @Test("Strings and comments")
    func stringsAndComments() throws {
        try assertGolden(
            "greet(\"hi\") # note",
            language: .ruby,
            expected: [
                ExpectedToken(.function, "greet"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.string, "\"hi\""),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.comment, "# note"),
            ]
        )
    }
}

@Suite("Golden - Go")
struct GoGoldenTests {
    @Test("Functions and types")
    func functionsAndTypes() throws {
        try assertGolden(
            "func greet(name string) {",
            language: .go,
            expected: [
                ExpectedToken(.keyword, "func"),
                ExpectedToken.plain(" "),
                ExpectedToken(.function, "greet"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "name"),
                ExpectedToken.plain(" "),
                ExpectedToken(.type, "string"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.punctuation, "{"),
            ]
        )
    }

    @Test("Operators and numbers")
    func operatorsAndNumbers() throws {
        try assertGolden(
            "value := 10",
            language: .go,
            expected: [
                ExpectedToken(.plain, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, ":="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "10"),
            ]
        )
    }
}

@Suite("Golden - Rust")
struct RustGoldenTests {
    @Test("Functions and types")
    func functionsAndTypes() throws {
        try assertGolden(
            "fn greet(name: &str) -> String",
            language: .rust,
            expected: [
                ExpectedToken(.keyword, "fn"),
                ExpectedToken.plain(" "),
                ExpectedToken(.function, "greet"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "name"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "&"),
                ExpectedToken(.type, "str"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "->"),
                ExpectedToken.plain(" "),
                ExpectedToken(.type, "String"),
            ]
        )
    }

    @Test("Keywords and hex numbers")
    func keywordsNumbers() throws {
        try assertGolden(
            "let value = 0x2A",
            language: .rust,
            expected: [
                ExpectedToken(.keyword, "let"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "value"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "0x2A"),
            ]
        )
    }
}

@Suite("Golden - Kotlin")
struct KotlinGoldenTests {
    @Test("Functions and types")
    func functionsAndTypes() throws {
        try assertGolden(
            "fun greet(name: String): Int",
            language: .kotlin,
            expected: [
                ExpectedToken(.keyword, "fun"),
                ExpectedToken.plain(" "),
                ExpectedToken(.function, "greet"),
                ExpectedToken(.punctuation, "("),
                ExpectedToken(.plain, "name"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.type, "String"),
                ExpectedToken(.punctuation, ")"),
                ExpectedToken(.operator, ":"),
                ExpectedToken.plain(" "),
                ExpectedToken(.type, "Int"),
            ]
        )
    }

    @Test("Keywords and numbers")
    func keywordsNumbers() throws {
        try assertGolden(
            "val count = 42",
            language: .kotlin,
            expected: [
                ExpectedToken(.keyword, "val"),
                ExpectedToken.plain(" "),
                ExpectedToken(.plain, "count"),
                ExpectedToken.plain(" "),
                ExpectedToken(.operator, "="),
                ExpectedToken.plain(" "),
                ExpectedToken(.number, "42"),
            ]
        )
    }
}

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
}
