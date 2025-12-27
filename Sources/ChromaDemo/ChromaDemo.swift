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
        cpp,
        javascript,
        jsx,
        typescript,
        tsx,
        python,
        ruby,
        go,
        rust,
        kotlin,
        java,
        csharp,
        php,
        dart,
        lua,
        bash,
        sql,
        css,
        scss,
        sass,
        less,
        html,
        xml,
        json,
        yaml,
        toml,
        markdown,
        dockerfile,
        makefile,
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
        map[LanguageID.jsx.rawValue] = jsx
        map[LanguageID.ts.rawValue] = typescript
        map[LanguageID.tsx.rawValue] = tsx
        map[LanguageID.py.rawValue] = python
        map[LanguageID.rb.rawValue] = ruby
        map[LanguageID.golang.rawValue] = go
        map[LanguageID.cplusplus.rawValue] = cpp
        map[LanguageID.cxx.rawValue] = cpp
        map[LanguageID.cs.rawValue] = csharp
        map[LanguageID.sh.rawValue] = bash
        map[LanguageID.zsh.rawValue] = bash
        map[LanguageID.yml.rawValue] = yaml
        map[LanguageID.md.rawValue] = markdown
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

    private static let cpp = LanguageDemo(
        id: .cpp,
        sample: """
        #include <iostream>
        #include <string>
        #include <vector>

        struct User {
            int id;
            std::string name;
            std::vector<std::string> tags;
        };

        std::string label(const User &user) {
            return user.name + " (#" + std::to_string(user.id) + ")";
        }

        void greet(const User &user) {
            auto suffix = user.id == 1 ? "!" : ".";
            std::cout << "Hello, " << user.name << suffix << std::endl;
        }

        int main() {
            std::vector<User> users{
                {1, "Ada", {"swift", "cli"}},
                {2, "Linus", {"kernel"}},
            };
            for (const auto &user : users) {
                greet(user);
                std::cout << label(user) << std::endl;
            }
            return 0;
        }
        """,
        highlightLines: [15...17, 25...25],
        patch: """
        diff --git a/user.cpp b/user.cpp
        index 1212121..3434343 100644
        --- a/user.cpp
        +++ b/user.cpp
        @@ -11,4 +11,4 @@
         std::string label(const User &user) {
        -    return user.name + " (#" + std::to_string(user.id) + ")";
        +    return user.name + " [" + std::to_string(user.id) + "]";
         }
        @@ -15,4 +15,4 @@
         void greet(const User &user) {
        -    auto suffix = user.id == 1 ? "!" : ".";
        +    auto suffix = user.id == 1 ? "!!" : ".";
             std::cout << "Hello, " << user.name << suffix << std::endl;
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

    private static let jsx = LanguageDemo(
        id: .jsx,
        sample: """
        import React from "react"

        const users = [
            { id: 1, name: "Ada", tags: ["swift", "cli"] },
            { id: 2, name: "Linus", tags: ["kernel"] },
        ]

        export function UserList({ title }) {
            return (
                <section className="panel">
                    <h2>{title}</h2>
                    <ul>
                        {users.map((user) => (
                            <li key={user.id}>
                                <strong>{user.name}</strong>
                                <span className="meta">#{user.id}</span>
                            </li>
                        ))}
                    </ul>
                </section>
            )
        }
        """,
        highlightLines: [8...10, 15...15],
        patch: """
        diff --git a/UserList.jsx b/UserList.jsx
        index 5555555..6666666 100644
        --- a/UserList.jsx
        +++ b/UserList.jsx
        @@ -8,4 +8,4 @@
         export function UserList({ title }) {
             return (
        -        <section className="panel">
        +        <section className="card">
                 <h2>{title}</h2>
        @@ -14,4 +14,4 @@
                         <li key={user.id}>
                             <strong>{user.name}</strong>
        -                    <span className="meta">#{user.id}</span>
        +                    <span className="meta">ID {user.id}</span>
                         </li>
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

    private static let tsx = LanguageDemo(
        id: .tsx,
        sample: """
        import React from "react"

        type User = {
            id: number
            name: string
            tags: string[]
        }

        const users: User[] = [
            { id: 1, name: "Ada", tags: ["swift", "cli"] },
            { id: 2, name: "Linus", tags: ["kernel"] },
        ]

        type Props = {
            title: string
        }

        export function UserList({ title }: Props) {
            return (
                <section className="panel">
                    <h2>{title}</h2>
                    <ul>
                        {users.map((user) => (
                            <li key={user.id}>
                                <strong>{user.name}</strong>
                                <span className="meta">#{user.id}</span>
                            </li>
                        ))}
                    </ul>
                </section>
            )
        }
        """,
        highlightLines: [3...6, 23...23],
        patch: """
        diff --git a/UserList.tsx b/UserList.tsx
        index 7777777..8888888 100644
        --- a/UserList.tsx
        +++ b/UserList.tsx
        @@ -18,4 +18,4 @@
         export function UserList({ title }: Props) {
             return (
        -        <section className="panel">
        +        <section className="card">
                 <h2>{title}</h2>
        @@ -24,4 +24,4 @@
                         <li key={user.id}>
                             <strong>{user.name}</strong>
        -                    <span className="meta">#{user.id}</span>
        +                    <span className="meta">ID {user.id}</span>
                         </li>
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

    private static let java = LanguageDemo(
        id: .java,
        sample: """
        import java.util.List;

        record User(int id, String name, List<String> tags) {}

        final class Greeter {
            static String greet(User user) {
                var suffix = user.id() == 1 ? "!" : ".";
                return "Hello, " + user.name() + suffix;
            }
        }

        public class Main {
            public static void main(String[] args) {
                var users = List.of(
                    new User(1, "Ada", List.of("swift", "cli")),
                    new User(2, "Linus", List.of("kernel"))
                );
                for (var user : users) {
                    System.out.println(Greeter.greet(user));
                }
            }
        }
        """,
        highlightLines: [6...8, 18...18],
        patch: """
        diff --git a/Main.java b/Main.java
        index 1010101..2020202 100644
        --- a/Main.java
        +++ b/Main.java
        @@ -6,4 +6,4 @@
             static String greet(User user) {
                 var suffix = user.id() == 1 ? "!" : ".";
        -        return "Hello, " + user.name() + suffix;
        +        return "Hi, " + user.name() + suffix;
             }
        @@ -13,4 +13,4 @@
                 var users = List.of(
        -            new User(1, "Ada", List.of("swift", "cli")),
        +            new User(1, "Ada", List.of("swift", "terminal")),
                     new User(2, "Linus", List.of("kernel"))
                 );
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

    private static let php = LanguageDemo(
        id: .php,
        sample: """
        <?php

        final class User {
            public function __construct(
                public int $id,
                public string $name,
                public array $tags,
            ) {}
        }

        function greet(User $user): string {
            $suffix = in_array("admin", $user->tags, true) ? "!" : ".";
            return "Hello, {$user->name}{$suffix}";
        }

        $users = [
            new User(1, "Ada", ["swift", "cli"]),
            new User(2, "Linus", ["kernel"]),
        ];

        foreach ($users as $user) {
            echo greet($user) . PHP_EOL;
        }
        """,
        highlightLines: [11...13, 21...21],
        patch: """
        diff --git a/User.php b/User.php
        index 111aaaa..222bbbb 100644
        --- a/User.php
        +++ b/User.php
        @@ -11,4 +11,4 @@
         function greet(User $user): string {
             $suffix = in_array("admin", $user->tags, true) ? "!" : ".";
        -    return "Hello, {$user->name}{$suffix}";
        +    return "Hi, {$user->name}{$suffix}";
         }
        @@ -16,4 +16,4 @@
         $users = [
        -    new User(1, "Ada", ["swift", "cli"]),
        +    new User(1, "Ada", ["swift", "terminal"]),
             new User(2, "Linus", ["kernel"]),
         ];
        """
    )

    private static let dart = LanguageDemo(
        id: .dart,
        sample: """
        class User {
            final int id;
            final String name;
            final List<String> tags;

            const User(this.id, this.name, this.tags);
        }

        String greet(User user) {
            final suffix = user.id == 1 ? "!" : ".";
            return "Hello, ${user.name}$suffix";
        }

        void main() {
            final users = [
                User(1, "Ada", ["swift", "cli"]),
                User(2, "Linus", ["kernel"]),
            ];
            for (final user in users) {
                print(greet(user));
            }
        }
        """,
        highlightLines: [9...11, 19...19],
        patch: """
        diff --git a/main.dart b/main.dart
        index 333cccc..444dddd 100644
        --- a/main.dart
        +++ b/main.dart
        @@ -9,4 +9,4 @@
         String greet(User user) {
             final suffix = user.id == 1 ? "!" : ".";
        -    return "Hello, ${user.name}$suffix";
        +    return "Hi, ${user.name}$suffix";
         }
        @@ -15,4 +15,4 @@
             final users = [
        -        User(1, "Ada", ["swift", "cli"]),
        +        User(1, "Ada", ["swift", "terminal"]),
                 User(2, "Linus", ["kernel"]),
             ];
        """
    )

    private static let lua = LanguageDemo(
        id: .lua,
        sample: """
        local users = {
            { id = 1, name = "Ada", tags = { "swift", "cli" } },
            { id = 2, name = "Linus", tags = { "kernel" } },
        }

        local function greet(user)
            local suffix = user.id == 1 and "!" or "."
            return "Hello, " .. user.name .. suffix
        end

        local function label(user)
            return string.format("%s (#%d)", user.name, user.id)
        end

        for _, user in ipairs(users) do
            print(greet(user))
            print(label(user))
        end
        """,
        highlightLines: [6...8, 15...15],
        patch: """
        diff --git a/user.lua b/user.lua
        index 555eeee..666ffff 100644
        --- a/user.lua
        +++ b/user.lua
        @@ -6,4 +6,4 @@
         local function greet(user)
             local suffix = user.id == 1 and "!" or "."
        -    return "Hello, " .. user.name .. suffix
        +    return "Hi, " .. user.name .. suffix
         end
        @@ -11,3 +11,3 @@
         local function label(user)
        -    return string.format("%s (#%d)", user.name, user.id)
        +    return string.format("%s [%d]", user.name, user.id)
         end
        """
    )

    private static let bash = LanguageDemo(
        id: .bash,
        sample: """
        #!/usr/bin/env bash
        set -euo pipefail

        users=("Ada" "Linus")

        greet() {
            local name="$1"
            local suffix="."
            if [[ "$name" == "Ada" ]]; then
                suffix="!"
            fi
            echo "Hello, $name$suffix"
        }

        for user in "${users[@]}"; do
            greet "$user"
        done
        """,
        highlightLines: [7...10, 15...15],
        patch: """
        diff --git a/greet.sh b/greet.sh
        index 777aaaa..888bbbb 100755
        --- a/greet.sh
        +++ b/greet.sh
        @@ -3,4 +3,4 @@
         
        -users=("Ada" "Linus")
        +users=("Ada" "Grace")
         
         greet() {
        @@ -8,5 +8,5 @@
             local suffix="."
             if [[ "$name" == "Ada" ]]; then
                 suffix="!"
             fi
        -    echo "Hello, $name$suffix"
        +    echo "Hi, $name$suffix"
         }
        """
    )

    private static let sql = LanguageDemo(
        id: .sql,
        sample: """
        CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            role TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        INSERT INTO users (id, name, role) VALUES
            (1, 'Ada', 'admin'),
            (2, 'Linus', 'member');

        SELECT u.id, u.name, u.role
        FROM users u
        WHERE u.role <> 'guest'
        ORDER BY u.id DESC;
        """,
        highlightLines: [1...3, 12...12],
        patch: """
        diff --git a/users.sql b/users.sql
        index 999cccc..000dddd 100644
        --- a/users.sql
        +++ b/users.sql
        @@ -1,4 +1,4 @@
         CREATE TABLE users (
             id INTEGER PRIMARY KEY,
        -    name TEXT NOT NULL,
        +    name TEXT NOT NULL UNIQUE,
             role TEXT NOT NULL,
        @@ -12,4 +12,4 @@
         SELECT u.id, u.name, u.role
         FROM users u
        -WHERE u.role <> 'guest'
        +WHERE u.role IN ('admin', 'member')
         ORDER BY u.id DESC;
        """
    )

    private static let css = LanguageDemo(
        id: .css,
        sample: """
        :root {
            --accent: #5f9bff;
            --radius: 10px;
        }

        .card {
            background: #1e1f25;
            border-radius: var(--radius);
            color: #f1f1f1;
            padding: 16px;
        }

        .card a:hover {
            color: var(--accent);
            text-decoration: underline;
        }

        @media (max-width: 600px) {
            .card {
                padding: 12px;
            }
        }
        """,
        highlightLines: [6...10, 18...18],
        patch: """
        diff --git a/card.css b/card.css
        index 1230000..1231111 100644
        --- a/card.css
        +++ b/card.css
        @@ -1,4 +1,4 @@
         :root {
        -    --accent: #5f9bff;
        +    --accent: #6fd3ff;
             --radius: 10px;
         }
        @@ -18,4 +18,4 @@
         @media (max-width: 600px) {
             .card {
        -        padding: 12px;
        +        padding: 8px;
             }
         }
        """
    )

    private static let scss = LanguageDemo(
        id: .scss,
        sample: """
        $accent: #5f9bff;
        $radius: 10px;

        @mixin card($bg) {
            background: $bg;
            border-radius: $radius;
            padding: 16px;
        }

        .card {
            @include card(#1e1f25);
            color: #f1f1f1;

            a {
                color: $accent;

                &:hover {
                    text-decoration: underline;
                }
            }
        }
        """,
        highlightLines: [4...7, 14...15],
        patch: """
        diff --git a/card.scss b/card.scss
        index 2340000..2341111 100644
        --- a/card.scss
        +++ b/card.scss
        @@ -1,4 +1,4 @@
        -$accent: #5f9bff;
        +$accent: #6fd3ff;
         $radius: 10px;

         @mixin card($bg) {
        @@ -4,4 +4,4 @@
         @mixin card($bg) {
             background: $bg;
             border-radius: $radius;
        -    padding: 16px;
        +    padding: 12px;
         }
        """
    )

    private static let sass = LanguageDemo(
        id: .sass,
        sample: """
        $accent: #5f9bff
        $radius: 10px

        =card($bg)
            background: $bg
            border-radius: $radius
            padding: 16px

        .card
            +card(#1e1f25)
            color: #f1f1f1

            a
                color: $accent

                &:hover
                    text-decoration: underline
        """,
        highlightLines: [4...7, 13...14],
        patch: """
        diff --git a/card.sass b/card.sass
        index 3450000..3451111 100644
        --- a/card.sass
        +++ b/card.sass
        @@ -1,4 +1,4 @@
        -$accent: #5f9bff
        +$accent: #6fd3ff
         $radius: 10px

         =card($bg)
        @@ -4,4 +4,4 @@
         =card($bg)
             background: $bg
             border-radius: $radius
        -    padding: 16px
        +    padding: 12px
        """
    )

    private static let less = LanguageDemo(
        id: .less,
        sample: """
        @accent: #5f9bff;
        @radius: 10px;

        .card(@bg) {
            background: @bg;
            border-radius: @radius;
            padding: 16px;
        }

        .panel {
            .card(#1e1f25);
            color: #f1f1f1;

            a:hover {
                color: @accent;
            }
        }
        """,
        highlightLines: [4...7, 14...15],
        patch: """
        diff --git a/panel.less b/panel.less
        index 4560000..4561111 100644
        --- a/panel.less
        +++ b/panel.less
        @@ -1,4 +1,4 @@
        -@accent: #5f9bff;
        +@accent: #6fd3ff;
         @radius: 10px;

         .card(@bg) {
        @@ -4,4 +4,4 @@
         .card(@bg) {
             background: @bg;
             border-radius: @radius;
        -    padding: 16px;
        +    padding: 12px;
         }
        """
    )

    private static let html = LanguageDemo(
        id: .html,
        sample: """
        <!doctype html>
        <html lang="en">
            <head>
                <meta charset="utf-8">
                <title>Chroma Demo</title>
                <link rel="stylesheet" href="app.css">
            </head>
            <body>
                <header class="site-header">
                    <h1>Chroma Demo</h1>
                </header>
                <main>
                    <section id="users">
                        <ul>
                            <li data-id="1">Ada</li>
                            <li data-id="2">Linus</li>
                        </ul>
                    </section>
                </main>
            </body>
        </html>
        """,
        highlightLines: [9...11, 15...15],
        patch: """
        diff --git a/index.html b/index.html
        index 5670000..5671111 100644
        --- a/index.html
        +++ b/index.html
        @@ -4,4 +4,4 @@
             <head>
                 <meta charset="utf-8">
        -        <title>Chroma Demo</title>
        +        <title>User List</title>
                 <link rel="stylesheet" href="app.css">
        @@ -14,4 +14,4 @@
                         <ul>
        -                    <li data-id="1">Ada</li>
        +                    <li data-id="1">Ada Lovelace</li>
                             <li data-id="2">Linus</li>
                         </ul>
        """
    )

    private static let xml = LanguageDemo(
        id: .xml,
        sample: """
        <?xml version="1.0" encoding="UTF-8"?>
        <users>
            <user id="1">
                <name>Ada</name>
                <role>admin</role>
            </user>
            <user id="2">
                <name>Linus</name>
                <role>member</role>
            </user>
        </users>
        """,
        highlightLines: [3...5, 7...7],
        patch: """
        diff --git a/users.xml b/users.xml
        index 6780000..6781111 100644
        --- a/users.xml
        +++ b/users.xml
        @@ -3,4 +3,4 @@
             <user id="1">
        -        <name>Ada</name>
        +        <name>Ada Lovelace</name>
                 <role>admin</role>
             </user>
        @@ -7,4 +7,4 @@
             <user id="2">
                 <name>Linus</name>
        -        <role>member</role>
        +        <role>guest</role>
             </user>
        """
    )

    private static let json = LanguageDemo(
        id: .json,
        sample: """
        {
            "name": "Chroma Demo",
            "version": 1,
            "users": [
                { "id": 1, "name": "Ada", "tags": ["swift", "cli"] },
                { "id": 2, "name": "Linus", "tags": ["kernel"] }
            ],
            "enabled": true
        }
        """,
        highlightLines: [4...6, 8...8],
        patch: """
        diff --git a/config.json b/config.json
        index 7890000..7891111 100644
        --- a/config.json
        +++ b/config.json
        @@ -2,4 +2,4 @@
             "name": "Chroma Demo",
        -    "version": 1,
        +    "version": 2,
             "users": [
        @@ -5,3 +5,3 @@
        -        { "id": 1, "name": "Ada", "tags": ["swift", "cli"] },
        +        { "id": 1, "name": "Ada", "tags": ["swift", "terminal"] },
                 { "id": 2, "name": "Linus", "tags": ["kernel"] }
        """
    )

    private static let yaml = LanguageDemo(
        id: .yaml,
        sample: """
        name: Chroma Demo
        version: 1
        users:
          - id: 1
            name: Ada
            tags:
              - swift
              - cli
          - id: 2
            name: Linus
            tags:
              - kernel
        enabled: true
        """,
        highlightLines: [4...8, 13...13],
        patch: """
        diff --git a/config.yaml b/config.yaml
        index 8900000..8901111 100644
        --- a/config.yaml
        +++ b/config.yaml
        @@ -1,4 +1,4 @@
         name: Chroma Demo
        -version: 1
        +version: 2
         users:
        @@ -5,4 +5,4 @@
             name: Ada
             tags:
        -      - cli
        +      - terminal
           - id: 2
        """
    )

    private static let toml = LanguageDemo(
        id: .toml,
        sample: """
        name = "Chroma Demo"
        version = 1

        [[users]]
        id = 1
        name = "Ada"
        tags = ["swift", "cli"]

        [[users]]
        id = 2
        name = "Linus"
        tags = ["kernel"]

        enabled = true
        """,
        highlightLines: [4...7, 14...14],
        patch: """
        diff --git a/config.toml b/config.toml
        index 9010000..9011111 100644
        --- a/config.toml
        +++ b/config.toml
        @@ -1,4 +1,4 @@
         name = "Chroma Demo"
        -version = 1
        +version = 2

         [[users]]
        @@ -5,4 +5,4 @@
         id = 1
         name = "Ada"
        -tags = ["swift", "cli"]
        +tags = ["swift", "terminal"]

        """
    )

    private static let markdown = LanguageDemo(
        id: .markdown,
        sample: """
        # Chroma Demo

        This is a **markdown** sample with `inline code`.

        ## Features
        - Fenced code blocks
        - Lists and *emphasis*
        - Links: [Chroma](https://example.com)

        ```swift
        struct User {
            let id: Int
            let name: String
        }
        ```

        > Tip: Markdown supports blockquotes.
        """,
        highlightLines: [5...8, 11...13],
        patch: """
        diff --git a/README.md b/README.md
        index 0120000..0121111 100644
        --- a/README.md
        +++ b/README.md
        @@ -1,4 +1,4 @@
        -# Chroma Demo
        +# Chroma Guide

         This is a **markdown** sample with `inline code`.

        @@ -11,4 +11,4 @@
         struct User {
        -    let id: Int
        +    let id: UUID
             let name: String
         }
        """
    )

    private static let dockerfile = LanguageDemo(
        id: .dockerfile,
        sample: """
        FROM swift:5.9-jammy

        WORKDIR /app
        COPY . .

        RUN swift build -c release
        RUN useradd -m appuser
        USER appuser

        CMD [".build/release/ChromaDemo", "--lang", "swift"]
        """,
        highlightLines: [6...8, 10...10],
        patch: """
        diff --git a/Dockerfile b/Dockerfile
        index 1350000..1351111 100644
        --- a/Dockerfile
        +++ b/Dockerfile
        @@ -1,4 +1,4 @@
        -FROM swift:5.9-jammy
        +FROM swift:5.9

         WORKDIR /app
         COPY . .
        @@ -8,3 +8,3 @@
         USER appuser

        -CMD [".build/release/ChromaDemo", "--lang", "swift"]
        +CMD [".build/release/ChromaDemo", "--lang", "swift", "--dark"]
        """
    )

    private static let makefile = LanguageDemo(
        id: .makefile,
        sample: """
        APP := ChromaDemo
        SWIFT := swift

        .PHONY: build test run

        build:
        \t$(SWIFT) build

        test:
        \t$(SWIFT) test

        run:
        \t$(SWIFT) run $(APP) --lang swift
        """,
        highlightLines: [6...7, 12...13],
        patch: """
        diff --git a/Makefile b/Makefile
        index 2460000..2461111 100644
        --- a/Makefile
        +++ b/Makefile
        @@ -1,4 +1,4 @@
        -APP := ChromaDemo
        +APP := chroma-demo
         SWIFT := swift

         .PHONY: build test run
        @@ -12,2 +12,2 @@
         run:
        -\t$(SWIFT) run $(APP) --lang swift
        +\t$(SWIFT) run $(APP) --lang swift --dark
        """
    )
}

struct DemoArguments {
    enum ThemeChoice: String {
        case dark
        case light
    }

    var theme: ThemeChoice = .dark
    var colorMode: ColorMode = .auto(output: .stdout)
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
                parsed.colorMode = .always
            case "--no-color":
                parsed.colorMode = .never
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

            let colorMode = options.colorMode
            Rainbow.enabled = colorMode.isEnabled()

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
                colorMode: colorMode,
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
        colorMode: ColorMode,
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
        print(try highlighter.highlight(
            demo.sample,
            language: demo.id,
            options: .init(colorMode: colorMode)
        ))
        print("")

        printSection("Sample + Line Numbers + Highlights")
        print(try highlighter.highlight(
            demo.sample,
            language: demo.id,
            options: .init(
                colorMode: colorMode,
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
                colorMode: colorMode,
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
                colorMode: colorMode,
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
