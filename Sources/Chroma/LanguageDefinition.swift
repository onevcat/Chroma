public struct LanguageDefinition {
    public var id: LanguageID
    public var displayName: String
    public var rules: [TokenRule]

    public init(id: LanguageID, displayName: String, rules: [TokenRule]) {
        self.id = id
        self.displayName = displayName
        self.rules = rules
    }
}

