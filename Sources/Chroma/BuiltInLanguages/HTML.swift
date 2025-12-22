import Foundation

extension BuiltInLanguages {
    static let html: LanguageDefinition = {
        let rules = markupRules(additionalRules: [
            try! TokenRule(kind: .keyword, pattern: "(?i)<!doctype[\\s\\S]*?>"),
        ])
        return LanguageDefinition(id: .html, displayName: "HTML", rules: rules)
    }()
}
