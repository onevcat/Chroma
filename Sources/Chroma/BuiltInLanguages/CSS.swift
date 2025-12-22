import Foundation

extension BuiltInLanguages {
    static let css: LanguageDefinition = {
        let rules = cssRules(additionalRules: [
            try! TokenRule(kind: .keyword, pattern: "!important\\b"),
        ])
        return LanguageDefinition(id: .css, displayName: "CSS", rules: rules)
    }()
}
