import Foundation

public final class LanguageRegistry {
    private var storage: [LanguageID: LanguageDefinition]
    private let lock = NSLock()

    public init(languages: [LanguageDefinition] = []) {
        self.storage = Dictionary(uniqueKeysWithValues: languages.map { ($0.id, $0) })
    }

    /// Creates a new registry pre-filled with built-in language definitions.
    public static func builtIn() -> LanguageRegistry {
        LanguageRegistry(languages: BuiltInLanguages.all)
    }

    public func register(_ language: LanguageDefinition, overwrite: Bool = true) {
        lock.lock()
        defer { lock.unlock() }

        if !overwrite, storage[language.id] != nil {
            return
        }
        storage[language.id] = language
    }

    public func language(for id: LanguageID) -> LanguageDefinition? {
        lock.lock()
        defer { lock.unlock() }
        return storage[id]
    }

    public func allLanguages() -> [LanguageDefinition] {
        lock.lock()
        defer { lock.unlock() }
        return storage.values.sorted { $0.id.rawValue < $1.id.rawValue }
    }
}

