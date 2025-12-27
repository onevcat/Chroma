import Testing
@testable import Chroma

@Suite("ColorMode")
struct ColorModeTests {
    @Test("Auto disables when NO_COLOR is set")
    func autoDisablesOnNoColor() {
        let enabled = ColorMode.auto(output: .stdout).resolve(
            rainbowEnabled: true,
            environment: ["NO_COLOR": "1"],
            isTTY: { _ in true }
        )
        #expect(!enabled)
    }

    @Test("Auto disables when CHROMA_NO_COLOR is set")
    func autoDisablesOnChromaNoColor() {
        let enabled = ColorMode.auto(output: .stderr).resolve(
            rainbowEnabled: true,
            environment: ["CHROMA_NO_COLOR": "true"],
            isTTY: { _ in true }
        )
        #expect(!enabled)
    }

    @Test("Auto disables for dumb terminals")
    func autoDisablesOnDumbTerm() {
        let enabled = ColorMode.auto(output: .stdout).resolve(
            rainbowEnabled: true,
            environment: ["TERM": "dumb"],
            isTTY: { _ in true }
        )
        #expect(!enabled)
    }

    @Test("Auto disables when not a TTY")
    func autoDisablesOnNonTTY() {
        let enabled = ColorMode.auto(output: .stdout).resolve(
            rainbowEnabled: true,
            environment: [:],
            isTTY: { _ in false }
        )
        #expect(!enabled)
    }

    @Test("Auto respects FORCE_COLOR even without TTY")
    func autoHonorsForceColor() {
        let enabled = ColorMode.auto(output: .stdout).resolve(
            rainbowEnabled: true,
            environment: ["FORCE_COLOR": "1"],
            isTTY: { _ in false }
        )
        #expect(enabled)
    }

    @Test("CHROMA_NO_COLOR overrides FORCE_COLOR")
    func chromaNoColorOverridesForceColor() {
        let enabled = ColorMode.auto(output: .stdout).resolve(
            rainbowEnabled: true,
            environment: ["CHROMA_NO_COLOR": "1", "FORCE_COLOR": "1"],
            isTTY: { _ in true }
        )
        #expect(!enabled)
    }

    @Test("Auto respects Rainbow.enabled")
    func autoRespectsRainbowEnabled() {
        let enabled = ColorMode.auto(output: .stdout).resolve(
            rainbowEnabled: false,
            environment: [:],
            isTTY: { _ in true }
        )
        #expect(!enabled)
    }
}
