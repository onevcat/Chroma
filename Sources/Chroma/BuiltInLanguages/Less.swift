import Foundation

extension BuiltInLanguages {
    static let less: LanguageDefinition = {
        let rules = cssRules(additionalRules: [
            try! TokenRule(kind: .keyword, pattern: "!important\\b"),
        ])
        return LanguageDefinition(id: .less, displayName: "Less", rules: rules)
    }()
}
