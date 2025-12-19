import Testing
@testable import Chroma

@Suite("LanguageRegistry")
struct LanguageRegistryTests {
    @Test("Register respects overwrite flag")
    func registerOverwrite() {
        let registry = LanguageRegistry()
        let first = LanguageDefinition(id: "mini", displayName: "Mini", rules: [])
        let second = LanguageDefinition(id: "mini", displayName: "Mini2", rules: [])

        registry.register(first, overwrite: true)
        registry.register(second, overwrite: false)
        #expect(registry.language(for: "mini")?.displayName == "Mini")

        registry.register(second, overwrite: true)
        #expect(registry.language(for: "mini")?.displayName == "Mini2")
    }

    @Test("allLanguages returns sorted list")
    func allLanguagesSorted() {
        let registry = LanguageRegistry()
        registry.register(LanguageDefinition(id: "b", displayName: "B", rules: []))
        registry.register(LanguageDefinition(id: "a", displayName: "A", rules: []))

        let ids = registry.allLanguages().map { $0.id.rawValue }
        #expect(ids == ["a", "b"])
    }

    @Test("builtIn includes Swift")
    func builtInContainsSwift() {
        let registry = LanguageRegistry.builtIn()
        #expect(registry.language(for: .swift) != nil)
    }
}
