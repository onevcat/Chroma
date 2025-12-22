import Foundation

extension BuiltInLanguages {
    static let xml: LanguageDefinition = {
        let rules = markupRules(additionalRules: [
            try! TokenRule(kind: .keyword, pattern: "<\\?xml[\\s\\S]*?\\?>"),
            try! TokenRule(kind: .string, pattern: "<!\\[CDATA\\[[\\s\\S]*?\\]\\]>")
        ])
        return LanguageDefinition(id: .xml, displayName: "XML", rules: rules)
    }()
}
