import Foundation

extension BuiltInLanguages {
    static let sass: LanguageDefinition = {
        let rules = cssRules(additionalRules: [
            try! TokenRule(kind: .property, pattern: "\\$[A-Za-z_-][A-Za-z0-9_-]*"),
            try! TokenRule(kind: .keyword, pattern: "!important\\b"),
        ])
        return LanguageDefinition(id: .sass, displayName: "Sass", rules: rules)
    }()
}
