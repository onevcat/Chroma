import Foundation

extension BuiltInLanguages {
    static let dockerfile: LanguageDefinition = {
        let instructions = [
            "FROM", "RUN", "CMD", "LABEL", "MAINTAINER", "EXPOSE", "ENV", "ADD", "COPY", "ENTRYPOINT",
            "VOLUME", "USER", "WORKDIR", "ARG", "ONBUILD", "STOPSIGNAL", "HEALTHCHECK", "SHELL",
        ]
        let pattern = "(?mi)^\\s*(?:\(wordAlternation(instructions)))\\b"

        var rules: [TokenRule] = []
        rules.append(try! TokenRule(kind: .comment, pattern: "#[^\\n\\r]*"))
        rules.append(try! TokenRule(kind: .string, pattern: "\"(?:\\\\.|[^\"\\\\])*\""))
        rules.append(try! TokenRule(kind: .string, pattern: "'(?:\\\\.|[^'\\\\])*'"))
        rules.append(try! TokenRule(kind: .keyword, pattern: pattern))
        rules.append(try! TokenRule(kind: .property, pattern: "\\$\\{[^}]+\\}"))
        rules.append(try! TokenRule(kind: .property, pattern: "\\$[A-Za-z_][A-Za-z0-9_]*"))
        rules.append(try! TokenRule(kind: .number, pattern: "\\b\\d+(?:\\.\\d+)?\\b"))
        rules.append(try! TokenRule(kind: .operator, pattern: "[+\\-*/%&|^!~=<>?:]+"))
        rules.append(try! TokenRule(kind: .punctuation, pattern: "[\\[\\]{}().,;:]"))

        return LanguageDefinition(id: .dockerfile, displayName: "Dockerfile", rules: rules)
    }()
}
