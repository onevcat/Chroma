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
    private var lookup: [String: TokenKind]

    public init(keywords: [String] = [], types: [String] = []) {
        var lookup: [String: TokenKind] = [:]
        lookup.reserveCapacity(keywords.count + types.count)
        for word in types {
            lookup[word] = .type
        }
        for word in keywords {
            lookup[word] = .keyword
        }
        self.lookup = lookup
    }

    public var isEmpty: Bool {
        lookup.isEmpty
    }

    func kind(for word: String) -> TokenKind? {
        lookup[word]
    }

    mutating func appendWords(_ words: [String], kind: TokenKind) {
        switch kind {
        case .keyword:
            for word in words {
                lookup[word] = .keyword
            }
        case .type:
            for word in words where lookup[word] == nil {
                lookup[word] = .type
            }
        default:
            break
        }
    }
}
