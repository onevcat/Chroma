import Chroma
import Foundation
import Rainbow

enum DemoError: Swift.Error {
    case invalidArguments(String)
}

struct LanguageDemo {
    let id: LanguageID
    let sample: String
    let highlightLines: LineRangeSet
    let patch: String
}

enum DemoCatalog {
    static let demos: [LanguageDemo] = [
        swift,
        objectiveC,
        c,
        javascript,
        typescript,
        python,
        ruby,
        go,
        rust,
        kotlin,
        csharp,
    ]

    static func demo(for id: LanguageID) -> LanguageDemo? {
        demosByID[id.rawValue] ?? demosByID[id.rawValue.lowercased()]
    }

    private static let demosByID: [String: LanguageDemo] = {
        var map: [String: LanguageDemo] = [:]
        for demo in demos {
            map[demo.id.rawValue] = demo
        }
        map[LanguageID.objc.rawValue] = objectiveC
        map[LanguageID.js.rawValue] = javascript
        map[LanguageID.ts.rawValue] = typescript
        map[LanguageID.py.rawValue] = python
        map[LanguageID.rb.rawValue] = ruby
        map[LanguageID.golang.rawValue] = go
        map[LanguageID.cs.rawValue] = csharp
        return map
    }()

    private static let swift = LanguageDemo(
        id: .swift,
        sample: """
        import Foundation

        struct User: Codable {
            let id: Int
            let name: String
            let tags: [String]
        }

        enum Role: String {
            case admin
            case member
            case guest
        }

        protocol Greeter {
            func greet(_ user: User) -> String
        }

        final class Service: Greeter {
            private let role: Role

            init(role: Role) {
                self.role = role
            }

            func greet(_ user: User) -> String {
                let suffix = role == .admin ? "!" : "."
                return "Hello, \\(user.name)\\(suffix)"
            }
        }

        let users: [User] = [
            .init(id: 1, name: "Ada", tags: ["swift", "cli"]),
            .init(id: 2, name: "Linus", tags: ["kernel"])
        ]

        let service = Service(role: .member)
        for user in users {
            print(service.greet(user))
        }
        """,
        highlightLines: [26...28, 38...38],
        patch: """
        diff --git a/User.swift b/User.swift
        index 1111111..2222222 100644
        --- a/User.swift
        +++ b/User.swift
        @@ -3,4 +3,4 @@
         struct User: Codable {
             let id: Int
        -    let tags: [String]
        +    let tags: [String]?
         }
        @@ -20,4 +20,4 @@
             func greet(_ user: User) -> String {
                 let suffix = role == .admin ? "!" : "."
        -        return "Hello, \\(user.name)\\(suffix)"
        +        return "Hi, \\(user.name)\\(suffix)"
             }
        """
    )

    private static let objectiveC = LanguageDemo(
        id: .objectiveC,
        sample: """
        #import <Foundation/Foundation.h>

        @interface User : NSObject
        @property (nonatomic, copy) NSString *name;
        @property (nonatomic, assign) NSInteger age;
        - (instancetype)initWithName:(NSString *)name age:(NSInteger)age;
        - (BOOL)isAdult;
        - (NSString *)greeting;
        @end

        @implementation User
        - (instancetype)initWithName:(NSString *)name age:(NSInteger)age {
            if (self = [super init]) {
                _name = [name copy];
                _age = age;
            }
            return self;
        }

        - (BOOL)isAdult {
            return _age >= 18;
        }

        - (NSString *)greeting {
            if ([self isAdult]) {
                return [NSString stringWithFormat:@"Hello, %@", _name];
            }
            return @"Hi";
        }
        @end
        """,
        highlightLines: [12...14, 26...26],
        patch: """
        diff --git a/User.m b/User.m
        index 3333333..4444444 100644
        --- a/User.m
        +++ b/User.m
        @@ -18,3 +18,3 @@
         - (BOOL)isAdult {
        -    return _age >= 18;
        +    return _age >= 21;
         }
        @@ -22,4 +22,4 @@
         - (NSString *)greeting {
             if ([self isAdult]) {
        -        return [NSString stringWithFormat:@"Hello, %@", _name];
        +        return [NSString stringWithFormat:@"Welcome, %@", _name];
             }
        """
    )

    private static let c = LanguageDemo(
        id: .c,
        sample: """
        #include <stdio.h>
        #include <string.h>

        typedef struct {
            int id;
            const char *name;
        } User;

        int is_valid(const User *user) {
            return user->id > 0 && user->name != NULL;
        }

        void print_user(const User *user) {
            if (!is_valid(user)) {
                printf("Invalid user\\n");
                return;
            }
            printf("User %d: %s\\n", user->id, user->name);
        }

        int main(void) {
            User users[] = {
                {1, "Ada"},
                {2, "Linus"},
            };
            size_t count = sizeof(users) / sizeof(users[0]);
            for (size_t i = 0; i < count; i++) {
                print_user(&users[i]);
            }
            return 0;
        }
        """,
        highlightLines: [13...15, 27...27],
        patch: """
        diff --git a/user.c b/user.c
        index 5555555..6666666 100644
        --- a/user.c
        +++ b/user.c
        @@ -9,3 +9,3 @@
         int is_valid(const User *user) {
        -    return user->id > 0 && user->name != NULL;
        +    return user->id >= 1 && user->name != NULL;
         }
        @@ -16,3 +16,3 @@
             }
        -    printf("User %d: %s\\n", user->id, user->name);
        +    printf("User #%d: %s\\n", user->id, user->name);
         }
        """
    )

    private static let javascript = LanguageDemo(
        id: .javascript,
        sample: """
        export class User {
            constructor(id, name, tags) {
                this.id = id
                this.name = name
                this.tags = tags
            }

            label() {
                return `${this.name} (#${this.id})`
            }
        }

        export function greet(user) {
            const suffix = user.tags.includes("admin") ? "!" : "."
            return `Hello, ${user.name}${suffix}`
        }

        const users = [
            new User(1, "Ada", ["swift", "cli"]),
            new User(2, "Linus", ["kernel"]),
        ]

        const labels = users.map((user) => user.label())
        for (const label of labels) {
            console.log(label)
        }
        """,
        highlightLines: [13...15, 23...23],
        patch: """
        diff --git a/user.js b/user.js
        index 7777777..8888888 100644
        --- a/user.js
        +++ b/user.js
        @@ -9,4 +9,4 @@
             label() {
        -        return `${this.name} (#${this.id})`
        +        return `${this.name} [${this.id}]`
             }
         }
        @@ -14,4 +14,4 @@
         export function greet(user) {
             const suffix = user.tags.includes("admin") ? "!" : "."
        -    return `Hello, ${user.name}${suffix}`
        +    return `Hi, ${user.name}${suffix}`
         }
        """
    )

    private static let typescript = LanguageDemo(
        id: .typescript,
        sample: """
        export type Role = "admin" | "member" | "guest"

        export interface User {
            id: number
            name: string
            tags: string[]
            role: Role
        }

        export function greet(user: User): string {
            const suffix = user.role === "admin" ? "!" : "."
            return `Hello, ${user.name}${suffix}`
        }

        const users: User[] = [
            { id: 1, name: "Ada", tags: ["swift", "cli"], role: "member" },
            { id: 2, name: "Linus", tags: ["kernel"], role: "guest" },
        ]

        const labels = users.map((user) => greet(user))
        for (const label of labels) {
            console.log(label)
        }
        """,
        highlightLines: [10...12, 20...20],
        patch: """
        diff --git a/user.ts b/user.ts
        index 9999999..aaaaaaa 100644
        --- a/user.ts
        +++ b/user.ts
        @@ -4,4 +4,4 @@
         export interface User {
             id: number
        -    name: string
        +    name: string | null
             tags: string[]
         }
        @@ -9,4 +9,4 @@
         export function greet(user: User): string {
             const suffix = user.role === "admin" ? "!" : "."
        -    return `Hello, ${user.name}${suffix}`
        +    return `Hi, ${user.name ?? "guest"}${suffix}`
         }
        """
    )

    private static let python = LanguageDemo(
        id: .python,
        sample: """
        from dataclasses import dataclass
        from typing import List

        @dataclass
        class User:
            id: int
            name: str
            tags: List[str]

        def greet(user: User) -> str:
            suffix = "!" if "admin" in user.tags else "."
            return f"Hello, {user.name}{suffix}"

        users = [
            User(1, "Ada", ["swift", "cli"]),
            User(2, "Linus", ["kernel"]),
        ]

        for user in users:
            print(greet(user))
        """,
        highlightLines: [10...12, 19...19],
        patch: """
        diff --git a/user.py b/user.py
        index bbbbbbb..ccccccc 100644
        --- a/user.py
        +++ b/user.py
        @@ -6,4 +6,4 @@
         class User:
             id: int
        -    name: str
        +    name: str | None
             tags: List[str]
        @@ -11,4 +11,4 @@
         def greet(user: User) -> str:
             suffix = "!" if "admin" in user.tags else "."
        -    return f"Hello, {user.name}{suffix}"
        +    return f"Hi, {user.name}{suffix}"
        """
    )

    private static let ruby = LanguageDemo(
        id: .ruby,
        sample: """
        class User
          attr_reader :id, :name, :tags

          def initialize(id, name, tags)
            @id = id
            @name = name
            @tags = tags
          end

          def label
            "#{name} (##{id})"
          end
        end

        def greet(user)
          suffix = user.tags.include?("admin") ? "!" : "."
          "Hello, #{user.name}#{suffix}"
        end

        users = [
          User.new(1, "Ada", ["swift", "cli"]),
          User.new(2, "Linus", ["kernel"]),
        ]

        users.each { |user| puts greet(user) }
        """,
        highlightLines: [15...17, 25...25],
        patch: """
        diff --git a/user.rb b/user.rb
        index ddddddd..eeeeeee 100644
        --- a/user.rb
        +++ b/user.rb
        @@ -8,4 +8,4 @@
           def label
        -    "#{name} (##{id})"
        +    "#{name} [##{id}]"
           end
         end
        @@ -13,4 +13,4 @@
         def greet(user)
           suffix = user.tags.include?("admin") ? "!" : "."
        -  "Hello, #{user.name}#{suffix}"
        +  "Hi, #{user.name}#{suffix}"
         end
        """
    )

    private static let go = LanguageDemo(
        id: .go,
        sample: """
        package main

        import "fmt"

        type User struct {
            ID   int
            Name string
            Tags []string
        }

        func (u User) Label() string {
            return fmt.Sprintf("%s (#%d)", u.Name, u.ID)
        }

        func Greet(u User) string {
            suffix := "."
            if u.ID == 1 {
                suffix = "!"
            }
            return fmt.Sprintf("Hello, %s%s", u.Name, suffix)
        }

        func main() {
            users := []User{
                {ID: 1, Name: "Ada", Tags: []string{"swift", "cli"}},
                {ID: 2, Name: "Linus", Tags: []string{"kernel"}},
            }
            for _, user := range users {
                fmt.Println(Greet(user))
                fmt.Println(user.Label())
            }
        }
        """,
        highlightLines: [15...17, 28...28],
        patch: """
        diff --git a/user.go b/user.go
        index fffffff..1111111 100644
        --- a/user.go
        +++ b/user.go
        @@ -9,4 +9,4 @@
         func (u User) Label() string {
        -    return fmt.Sprintf("%s (#%d)", u.Name, u.ID)
        +    return fmt.Sprintf("%s [%d]", u.Name, u.ID)
         }
        @@ -14,4 +14,4 @@
         func Greet(u User) string {
             suffix := "."
             if u.ID == 1 {
        -        suffix = "!"
        +        suffix = "!!"
             }
        """
    )

    private static let rust = LanguageDemo(
        id: .rust,
        sample: """
        #[derive(Debug)]
        struct User {
            id: u32,
            name: String,
            tags: Vec<String>,
        }

        impl User {
            fn label(&self) -> String {
                format!("{} (#{} )", self.name, self.id)
            }
        }

        fn greet(user: &User) -> String {
            let suffix = if user.id == 1 { "!" } else { "." };
            format!("Hello, {}{}", user.name, suffix)
        }

        fn main() {
            let users = vec![
                User { id: 1, name: "Ada".into(), tags: vec!["swift".into()] },
                User { id: 2, name: "Linus".into(), tags: vec!["kernel".into()] },
            ];
            for user in users {
                println!("{}", greet(&user));
            }
        }
        """,
        highlightLines: [14...16, 24...24],
        patch: """
        diff --git a/user.rs b/user.rs
        index 2222222..3333333 100644
        --- a/user.rs
        +++ b/user.rs
        @@ -7,4 +7,4 @@
         impl User {
             fn label(&self) -> String {
        -        format!("{} (#{} )", self.name, self.id)
        +        format!("{} [{}]", self.name, self.id)
             }
         }
        @@ -12,4 +12,4 @@
         fn greet(user: &User) -> String {
             let suffix = if user.id == 1 { "!" } else { "." };
        -    format!("Hello, {}{}", user.name, suffix)
        +    format!("Hi, {}{}", user.name, suffix)
         }
        """
    )

    private static let kotlin = LanguageDemo(
        id: .kotlin,
        sample: """
        data class User(val id: Int, val name: String, val tags: List<String>)

        fun label(user: User): String {
            return "${user.name} (#${user.id})"
        }

        fun greet(user: User): String {
            val suffix = if (user.tags.contains("admin")) "!" else "."
            return "Hello, ${user.name}$suffix"
        }

        fun main() {
            val users = listOf(
                User(1, "Ada", listOf("swift", "cli")),
                User(2, "Linus", listOf("kernel"))
            )
            for (user in users) {
                println(greet(user))
            }
        }
        """,
        highlightLines: [7...9, 17...17],
        patch: """
        diff --git a/User.kt b/User.kt
        index 4444444..5555555 100644
        --- a/User.kt
        +++ b/User.kt
        @@ -3,4 +3,4 @@
         fun label(user: User): String {
        -    return "${user.name} (#${user.id})"
        +    return "${user.name} [${user.id}]"
         }
        @@ -7,4 +7,4 @@
         fun greet(user: User): String {
             val suffix = if (user.tags.contains("admin")) "!" else "."
        -    return "Hello, ${user.name}$suffix"
        +    return "Hi, ${user.name}$suffix"
         }
        """
    )

    private static let csharp = LanguageDemo(
        id: .csharp,
        sample: """
        using System;
        using System.Collections.Generic;

        public record User(int Id, string Name, IReadOnlyList<string> Tags);

        public static class Greeter {
            public static string Greet(User user) {
                var suffix = user.Tags.Contains("admin") ? "!" : ".";
                return $"Hello, {user.Name}{suffix}";
            }
        }

        public static class Program {
            public static void Main() {
                var users = new List<User> {
                    new User(1, "Ada", new[] { "swift", "cli" }),
                    new User(2, "Linus", new[] { "kernel" }),
                };
                foreach (var user in users) {
                    Console.WriteLine(Greeter.Greet(user));
                }
            }
        }
        """,
        highlightLines: [7...9, 19...19],
        patch: """
        diff --git a/Program.cs b/Program.cs
        index 6666666..7777777 100644
        --- a/Program.cs
        +++ b/Program.cs
        @@ -6,4 +6,4 @@
         public static class Greeter {
             public static string Greet(User user) {
                 var suffix = user.Tags.Contains("admin") ? "!" : ".";
        -        return $"Hello, {user.Name}{suffix}";
        +        return $"Hi, {user.Name}{suffix}";
             }
         }
        @@ -12,4 +12,4 @@
             public static void Main() {
                 var users = new List<User> {
        -            new User(1, "Ada", new[] { "swift", "cli" }),
        +            new User(1, "Ada", new[] { "swift", "terminal" }),
                 };
        """
    )
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
    var lang: String?
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
            case "--lang":
                guard i + 1 < args.count else { throw DemoError.invalidArguments("Missing value for --lang.") }
                parsed.lang = args[i + 1].lowercased()
                i += 1
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
          --lang <id>            Render demo for a single language (default: swift)
          --force-color          Force enable ANSI output (ignore TTY detection)
          --no-color             Disable ANSI output
          --minimal              Hide header and metadata
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

            let requestedLanguage = options.lang ?? LanguageID.swift.rawValue
            let languageID = LanguageID(rawValue: requestedLanguage)
            guard let demo = DemoCatalog.demo(for: languageID) else {
                throw DemoError.invalidArguments("Unknown --lang value: \(requestedLanguage).")
            }
            try renderDemo(
                demo,
                registry: registry,
                highlighter: highlighter,
                theme: theme,
                showHeader: options.showComponents
            )
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

    private static func renderDemo(
        _ demo: LanguageDemo,
        registry: LanguageRegistry,
        highlighter: Highlighter,
        theme: Theme,
        showHeader: Bool
    ) throws {
        let displayName = registry.language(for: demo.id)?.displayName ?? demo.id.rawValue
        if showHeader {
            printHeader("Chroma Demo", subtitle: "\(displayName) (\(demo.id.rawValue))")
            print("Theme: \(theme.name)")
            print("Rainbow.enabled: \(Rainbow.enabled)")
            print("")
        }

        printSection("Sample")
        print(try highlighter.highlight(demo.sample, language: demo.id))
        print("")

        printSection("Sample + Line Numbers + Highlights")
        print(try highlighter.highlight(
            demo.sample,
            language: demo.id,
            options: .init(
                highlightLines: demo.highlightLines,
                lineNumbers: .init(start: 1)
            )
        ))
        print("")

        printSection("Patch (verbose, background, plain diff code)")
        print(try highlighter.highlight(
            demo.patch,
            language: demo.id,
            options: .init(
                diff: .patch(style: .background(diffCode: .plain), presentation: .verbose),
                lineNumbers: .init(start: 1)
            )
        ))
        print("")

        printSection("Patch (compact, foreground, plain context)")
        print(try highlighter.highlight(
            demo.patch,
            language: demo.id,
            options: .init(
                diff: .patch(style: .foreground(contextCode: .plain), presentation: .compact),
                lineNumbers: .init(start: 1)
            )
        ))
        print("")
    }

    private static func printSection(_ title: String) {
        let prefix = "== "
        print((prefix + title).applyingColor(.lightYellow).applyingStyle(.bold))
    }
}
