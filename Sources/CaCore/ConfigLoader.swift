import Foundation

struct CaConfigLoader {
    let filePathOverride: String?

    func load() async -> CaConfig {
        let rawPath = filePathOverride ?? defaultConfigPath()
        let filePath = expandTilde(rawPath)
        guard FileManager.default.fileExists(atPath: filePath) else {
            return .default
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            let file = try JSONDecoder().decode(CaConfigFile.self, from: data)
            return file.toEffectiveConfig()
        } catch {
            Diagnostics.printError("Failed to load config at \(filePath): \(error)")
            return .default
        }
    }
}

// MARK: - On-disk config schema

private struct CaConfigFile: Decodable {
    var theme: Theme?
    var lineNumbers: Bool?
    var diff: DiffMode?
    var paging: PagingMode?
    var headers: Bool?
    var rules: [Rule]?

    struct Theme: Decodable {
        var name: String?
        var appearance: ThemeAppearancePreference?

        /// Back-compat: allow `"theme": "dark"` style.
        init(from decoder: any Decoder) throws {
            if let container = try? decoder.singleValueContainer(), let string = try? container.decode(String.self) {
                self.name = string
                self.appearance = nil
                return
            }
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            self.appearance = try container.decodeIfPresent(ThemeAppearancePreference.self, forKey: .appearance)
        }

        enum CodingKeys: String, CodingKey {
            case name
            case appearance
        }
    }

    struct Rule: Decodable {
        var match: Match
        var set: Set

        struct Match: Decodable {
            var ext: [String]

            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.ext = try container.decodeOneOrMany(String.self, forKey: .ext)
            }

            enum CodingKeys: String, CodingKey {
                case ext
            }
        }

        struct Set: Decodable {
            var lineNumbers: Bool?
            var diff: DiffMode?
            var theme: Theme?

            enum CodingKeys: String, CodingKey {
                case lineNumbers
                case diff
                case theme
            }
        }

        enum CodingKeys: String, CodingKey {
            case match
            case set
        }
    }

    func toEffectiveConfig() -> CaConfig {
        var config = CaConfig.default

        if let theme {
            if let name = theme.name {
                config.theme.name = name
            }
            if let appearance = theme.appearance {
                config.theme.appearance = appearance
            }
        }
        if let lineNumbers {
            config.lineNumbers = lineNumbers
        }
        if let diff {
            config.diff = diff
        }
        if let paging {
            config.paging = paging
        }
        if let headers {
            config.headers = headers
        }

        if let rules {
            config.rules = rules.map { rule in
                CaConfig.Rule(
                    match: .init(ext: Set(rule.match.ext.map { $0.lowercased() })),
                    overrides: .init(
                        lineNumbers: rule.set.lineNumbers,
                        diff: rule.set.diff,
                        themeName: rule.set.theme?.name,
                        themeAppearance: rule.set.theme?.appearance
                    )
                )
            }
        }

        return config
    }
}

private extension KeyedDecodingContainer {
    func decodeOneOrMany<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> [T] {
        if let array = try decodeIfPresent([T].self, forKey: key) {
            return array
        }
        if let single = try decodeIfPresent(T.self, forKey: key) {
            return [single]
        }
        return []
    }
}

// MARK: - Paths

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
