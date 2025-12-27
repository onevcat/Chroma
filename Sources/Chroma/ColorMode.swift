import Foundation
import Rainbow
#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// Output stream used for auto color detection.
public enum ColorOutput: Equatable {
    case stdout
    case stderr
}

/// Controls when ANSI colors are emitted.
public enum ColorMode: Equatable {
    /// Decide automatically using TTY detection, TERM, and color-related environment variables.
    case auto(output: ColorOutput)
    /// Always emit ANSI colors.
    case always
    /// Never emit ANSI colors.
    case never
    /// Defer to `Rainbow.enabled`.
    case inheritRainbowEnabled
}

extension ColorMode {
    /// Resolve whether ANSI colors should be enabled in the current process environment.
    public func isEnabled() -> Bool {
        resolve(
            rainbowEnabled: Rainbow.enabled,
            environment: ProcessInfo.processInfo.environment,
            isTTY: Self.isTTY
        )
    }

    func resolve(
        rainbowEnabled: Bool,
        environment: [String: String],
        isTTY: (ColorOutput) -> Bool
    ) -> Bool {
        switch self {
        case .always:
            return true
        case .never:
            return false
        case .inheritRainbowEnabled:
            return rainbowEnabled
        case let .auto(output):
            return ColorEnvironment.shouldEnableColor(
                output: output,
                rainbowEnabled: rainbowEnabled,
                environment: environment,
                isTTY: isTTY
            )
        }
    }

    private static func isTTY(_ output: ColorOutput) -> Bool {
        switch output {
        case .stdout:
            return isatty(fileno(stdout)) != 0
        case .stderr:
            return isatty(fileno(stderr)) != 0
        }
    }
}

private enum ColorEnvironment {
    static func shouldEnableColor(
        output: ColorOutput,
        rainbowEnabled: Bool,
        environment: [String: String],
        isTTY: (ColorOutput) -> Bool
    ) -> Bool {
        guard rainbowEnabled else { return false }
        if hasNonEmptyValue("CHROMA_NO_COLOR", environment: environment) {
            return false
        }
        if hasTruthyValue("FORCE_COLOR", environment: environment) {
            return true
        }
        if hasNonEmptyValue("NO_COLOR", environment: environment) {
            return false
        }
        if let term = environment["TERM"], term.lowercased() == "dumb" {
            return false
        }
        return isTTY(output)
    }

    private static func hasNonEmptyValue(_ key: String, environment: [String: String]) -> Bool {
        guard let value = environment[key] else { return false }
        return !value.isEmpty
    }

    private static func hasTruthyValue(_ key: String, environment: [String: String]) -> Bool {
        guard let value = environment[key] else { return false }
        return !value.isEmpty && value != "0"
    }
}
