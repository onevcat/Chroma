import Chroma
import Foundation
import Rainbow

enum DemoError: Swift.Error {
    case invalidArguments(String)
}

struct DemoArguments {
    enum ThemeChoice: String {
        case dark
        case light
    }

    var theme: ThemeChoice = .dark
    var forceColor: Bool = false
    var noColor: Bool = false
    var listLanguages: Bool = false
    var showComponents: Bool = true

    static func parse(_ args: [String]) throws -> DemoArguments {
        var parsed = DemoArguments()

        var i = 0
        while i < args.count {
            let arg = args[i]
            switch arg {
            case "--help", "-h":
                throw DemoError.invalidArguments("")
            case "--theme":
                guard i + 1 < args.count else { throw DemoError.invalidArguments("Missing value for --theme.") }
                let value = args[i + 1]
                guard let t = ThemeChoice(rawValue: value) else {
                    throw DemoError.invalidArguments("Invalid --theme value: \(value). Use 'dark' or 'light'.")
                }
                parsed.theme = t
                i += 1
            case "--dark":
                parsed.theme = .dark
            case "--light":
                parsed.theme = .light
            case "--force-color":
                parsed.forceColor = true
            case "--no-color":
                parsed.noColor = true
            case "--list-languages":
                parsed.listLanguages = true
            case "--minimal":
                parsed.showComponents = false
            default:
                throw DemoError.invalidArguments("Unknown argument: \(arg)")
            }
            i += 1
        }

        return parsed
    }

    static var help: String {
        """
        ChromaDemo

        Usage:
          swift run ChromaDemo [options]

        Options:
          --theme <dark|light>   Select theme (default: dark)
          --dark                 Same as --theme dark
          --light                Same as --theme light
          --list-languages       Print built-in languages and exit
          --force-color          Force enable ANSI output (ignore TTY detection)
          --no-color             Disable ANSI output
          --minimal              Print only sample outputs
          -h, --help             Show this message
        """
    }
}

@main
struct ChromaDemo {
    static func main() {
        do {
            let args = Array(CommandLine.arguments.dropFirst())
            let options = try DemoArguments.parse(args)

            if options.noColor {
                Rainbow.enabled = false
            } else if options.forceColor {
                Rainbow.enabled = true
            }

            let theme: Theme = (options.theme == .light) ? .light : .dark
            let registry = LanguageRegistry.builtIn()
            let highlighter = Highlighter(theme: theme, registry: registry)

            if options.listLanguages {
                printLanguages(registry)
                return
            }

            if options.showComponents {
                printHeader("Chroma Demo", subtitle: "Regex-based syntax highlighter for terminal output")
                print("Theme: \(theme.name)")
                print("Rainbow.enabled: \(Rainbow.enabled)")
                print("")
            }

            printSection("Swift")
            print(try highlighter.highlight(Samples.swift, language: .swift))
            print("")

            printSection("Objective-C")
            print(try highlighter.highlight(Samples.objc, language: .objectiveC))
            print("")

            printSection("C")
            print(try highlighter.highlight(Samples.c, language: .c))
            print("")

            printSection("JavaScript")
            print(try highlighter.highlight(Samples.javascript, language: .javascript))
            print("")

            printSection("TypeScript")
            print(try highlighter.highlight(Samples.typescript, language: .typescript))
            print("")

            printSection("Python")
            print(try highlighter.highlight(Samples.python, language: .python))
            print("")

            printSection("Ruby")
            print(try highlighter.highlight(Samples.ruby, language: .ruby))
            print("")

            printSection("Go")
            print(try highlighter.highlight(Samples.go, language: .go))
            print("")

            printSection("Rust")
            print(try highlighter.highlight(Samples.rust, language: .rust))
            print("")

            printSection("Kotlin")
            print(try highlighter.highlight(Samples.kotlin, language: .kotlin))
            print("")

            printSection("C#")
            print(try highlighter.highlight(Samples.csharp, language: .csharp))
            print("")

            if options.showComponents {
                printSection("Line Highlighting (1-based)")
                print(try highlighter.highlight(
                    Samples.swift,
                    language: .swift,
                    options: .init(highlightLines: [3...4])
                ))
                print("")

                printSection("Line Highlighting + Numbers")
                print(try highlighter.highlight(
                    Samples.swiftNumbers,
                    language: .swift,
                    options: .init(highlightLines: [2...2], lineNumbers: .init(start: 1))
                ))
                print("")

                printSection("Line Numbers (start at 1)")
                print(try highlighter.highlight(
                    Samples.swiftNumbers,
                    language: .swift,
                    options: .init(lineNumbers: .init(start: 1))
                ))
                print("")

                printSection("Line Numbers (start at 98)")
                print(try highlighter.highlight(
                    Samples.swiftNumbers,
                    language: .swift,
                    options: .init(lineNumbers: .init(start: 98))
                ))
                print("")

                printSection("Indentation (2 spaces)")
                print(try highlighter.highlight(
                    Samples.swiftIndent,
                    language: .swift,
                    options: .init(indent: 2)
                ))
                print("")

                printSection("Diff Highlighting (unified patch)")
                print(try highlighter.highlight(
                    Samples.patch,
                    language: .swift,
                    options: .init(diff: .patch())
                ))
                print("")

                printSection("Diff Highlighting + Line Numbers")
                print(try highlighter.highlight(
                    Samples.patch,
                    language: .swift,
                    options: .init(diff: .patch(), lineNumbers: .init(start: 1))
                ))
                print("")

                printSection("Diff Line Numbers (from hunk header)")
                print(try highlighter.highlight(
                    Samples.patchWithLineNumbers,
                    language: .swift,
                    options: .init(diff: .patch(), lineNumbers: .init(start: 1))
                ))
                print("")

                printSection("Diff Highlighting (foreground)")
                print(try highlighter.highlight(
                    Samples.patch,
                    language: .swift,
                    options: .init(diff: .patch(style: .foreground()), lineNumbers: .init())
                ))
                print("")

                printSection("Diff Highlighting (background, plain code)")
                print(try highlighter.highlight(
                    Samples.patch,
                    language: .swift,
                    options: .init(diff: .patch(style: .background(diffCode: .plain)))
                ))
                print("")

                printSection("Customization: extend Swift keywords at runtime")
                var swift = registry.language(for: .swift)!
                try swift.appendKeywords(["macro"])
                registry.register(swift, overwrite: true)

                print(try highlighter.highlight(
                    Samples.swiftMacro,
                    language: .swift
                ))
                print("")

                printSection("Customization: register a small custom language")
                let mini = LanguageDefinition(
                    id: "mini",
                    displayName: "MiniLang",
                    rules: [
                        try TokenRule(kind: .comment, pattern: "#[^\\n\\r]*"),
                        try TokenRule.words(["let", "fn", "return"], kind: .keyword),
                        try TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""),
                        try TokenRule(kind: .number, pattern: "\\b\\d+\\b"),
                        try TokenRule(kind: .function, pattern: "\\b[A-Za-z_][A-Za-z0-9_]*\\b(?=\\s*\\()"),
                        try TokenRule(kind: .punctuation, pattern: "[\\[\\]{}().,;:]"),
                        try TokenRule(kind: .operator, pattern: "[+\\-*/%&|^!~=<>?:]+"),
                    ]
                )
                registry.register(mini)

                print(try highlighter.highlight(
                    Samples.mini,
                    language: "mini"
                ))
                print("")
            }
        } catch DemoError.invalidArguments(let message) {
            if !message.isEmpty {
                fputs("Error: \(message)\n\n", stderr)
            }
            print(DemoArguments.help)
            exit(message.isEmpty ? 0 : 2)
        } catch {
            fputs("Error: \(error)\n", stderr)
            exit(1)
        }
    }

    private static func printLanguages(_ registry: LanguageRegistry) {
        for lang in registry.allLanguages() {
            print("\(lang.id.rawValue)\t\(lang.displayName)")
        }
    }

    private static func printHeader(_ title: String, subtitle: String) {
        let line = String(repeating: "=", count: max(24, title.count + 8))
        print(line.applyingColor(.lightCyan).applyingStyle(.bold))
        print(title.applyingColor(.lightCyan).applyingStyle(.bold))
        print(subtitle.applyingColor(.lightBlack))
        print(line.applyingColor(.lightCyan).applyingStyle(.bold))
    }

    private static func printSection(_ title: String) {
        let prefix = "== "
        print((prefix + title).applyingColor(.blue).applyingStyles([.bold, .dim]))
    }
}

enum Samples {
    static let swift = """
    import Foundation

    struct User: Codable {
        let id: Int
        let name: String
    }

    func greet(_ user: User) -> String {
        // A comment
        return "Hello, \\(user.name)!"
    }
    """

    static let swiftMacro = """
    import Foundation

    @attached(member)
    macro MyMacro() = #externalMacro(module: "MyMacros", type: "MyMacro")
    """

    static let swiftNumbers = """
    struct Metrics {
        let count = 42
        let ratio = 3.14
    }
    """

    static let swiftIndent = """
    class A {
        let name: String
    }
    """

    static let objc = """
    #import <Foundation/Foundation.h>

    @interface User : NSObject
    @property (nonatomic, copy) NSString *name;
    @end

    @implementation User
    - (NSString *)description {
        return [NSString stringWithFormat:@"<User %@>", self.name];
    }
    @end
    """

    static let c = """
    #include <stdio.h>

    int main(void) {
        // Print
        printf("Hello, world!\\n");
        return 0;
    }
    """

    static let javascript = """
    export function greet(name) {
      const message = `Hello, ${name}!`
      return message
    }
    """

    static let typescript = """
    type User = {
      id: number
      name: string
    }

    export const greet = (user: User): string => {
      return `Hello, ${user.name}!`
    }
    """

    static let python = """
    from dataclasses import dataclass

    @dataclass
    class User:
        id: int
        name: str

    def greet(user: User) -> str:
        # A comment
        return f"Hello, {user.name}!"
    """

    static let ruby = """
    class User
      attr_reader :name

      def initialize(name)
        @name = name
      end
    end

    def greet(user)
      # A comment
      "Hello, #{user.name}!"
    end
    """

    static let go = """
    package main

    import "fmt"

    type User struct {
        ID   int
        Name string
    }

    func greet(u User) string {
        return fmt.Sprintf("Hello, %s!", u.Name)
    }
    """

    static let rust = """
    #[derive(Debug)]
    struct User {
        id: u32,
        name: String,
    }

    fn greet(user: &User) -> String {
        // A comment
        format!("Hello, {}!", user.name)
    }
    """

    static let kotlin = """
    data class User(val id: Int, val name: String)

    fun greet(user: User): String {
        // A comment
        return "Hello, ${user.name}!"
    }
    """

    static let csharp = """
    using System;

    public record User(int Id, string Name);

    public static class Program {
        public static string Greet(User user) {
            // A comment
            return $"Hello, {user.Name}!";
        }
    }
    """

    static let patch = """
    diff --git a/Foo.swift b/Foo.swift
    index 1111111..2222222 100644
    --- a/Foo.swift
    +++ b/Foo.swift
    @@ -1,3 +1,3 @@
    -let a = 1
    +let a = 2
     let b = 3
    """

    static let patchWithLineNumbers = """
    diff --git a/Bar.swift b/Bar.swift
    index 3333333..4444444 100644
    --- a/Bar.swift
    +++ b/Bar.swift
    @@ -10,4 +20,4 @@
    -let count = 1
    -let name = "alpha"
    +let count = 2
    +let name = "beta"
     let total = count + 3
     let isEnabled = false
    """

    static let mini = """
    # mini demo
    fn greet(name) {
      return "Hello, " + name
    }
    """
}
