public struct LanguageDefinition {
    public var id: LanguageID
    public var displayName: String
    public var rules: [TokenRule]
    public var fastPath: LanguageFastPath?

    public init(
        id: LanguageID,
        displayName: String,
        rules: [TokenRule],
        fastPath: LanguageFastPath? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.rules = rules
        self.fastPath = fastPath
    }
}

public struct LanguageFastPath: Equatable {
    public var keywords: Set<String>
    public var types: Set<String>

    public init(keywords: [String] = [], types: [String] = []) {
        self.keywords = Set(keywords)
        self.types = Set(types)
    }

    public var isEmpty: Bool {
        keywords.isEmpty && types.isEmpty
    }
}
