import Configuration
import Foundation
import SystemPackage

struct CaConfigLoader {
    let filePathOverride: String?

    func load() async -> CaConfig {
#if os(macOS)
        if #available(macOS 15, *) {
            return await loadWithConfiguration()
        } else {
            Diagnostics.printError("Config loading requires macOS 15 or newer. Using defaults.")
            return .default
        }
#else
        return await loadWithConfiguration()
#endif
    }

    @available(macOS 15, *)
    private func loadWithConfiguration() async -> CaConfig {
        let rawPath = filePathOverride ?? defaultConfigPath()
        let filePath = expandTilde(rawPath)
        if !FileManager.default.fileExists(atPath: filePath) {
            return .default
        }
        do {
            let provider = try await JSONProvider(filePath: FilePath(filePath))
            let reader = ConfigReader(provider: provider)
            return CaConfig(
                theme: .init(
                    name: reader.string(forKey: "theme.name") ?? reader.string(forKey: "theme"),
                    appearance: ThemeAppearancePreference(
                        rawValue: reader.string(forKey: "theme.appearance", default: "auto")
                    ) ?? .auto
                ),
                lineNumbers: reader.bool(forKey: "lineNumbers", default: CaConfig.default.lineNumbers),
                paging: PagingMode(
                    rawValue: reader.string(forKey: "paging", default: CaConfig.default.paging.rawValue)
                ) ?? CaConfig.default.paging,
                headers: reader.bool(forKey: "headers", default: CaConfig.default.headers)
            )
        } catch {
            Diagnostics.printError("Failed to load config at \(filePath): \(error)")
            return .default
        }
    }
}

private func defaultConfigPath() -> String {
    let home = FileManager.default.homeDirectoryForCurrentUser.path
    return "\(home)/.config/ca/config.json"
}

private func expandTilde(_ path: String) -> String {
    if path.hasPrefix("~") {
        return (path as NSString).expandingTildeInPath
    }
    return path
}
