import Foundation
import Testing

@Suite("ca config rules")
struct ConfigRulesIntegrationTests {
    @Test("Per-extension lineNumbers override")
    func perExtensionLineNumbersOverride() throws {
        let executable = try locateCaExecutable()
        try withTemporaryDirectory { root in
            let configURL = root.appendingPathComponent("config.json")
            try writeFile(
                at: configURL,
                contents: """
                {
                  "lineNumbers": true,
                  "paging": "never",
                  "rules": [
                    {
                      "match": { "ext": ["md"] },
                      "set": { "lineNumbers": false }
                    }
                  ]
                }
                """
            )

            let mdURL = root.appendingPathComponent("README.md")
            try writeFile(at: mdURL, contents: "# Title\n")

            let swiftURL = root.appendingPathComponent("Sample.swift")
            try writeFile(at: swiftURL, contents: "let value = 1\n")

            // Markdown should NOT have line numbers.
            do {
                let result = try runCaNonTTY(
                    executable: executable,
                    arguments: ["--config", configURL.path, mdURL.path],
                    environment: makeCleanEnvironment()
                )
                #expect(result.exitCode == 0)

                let firstLine = result.output.split(separator: "\n", omittingEmptySubsequences: false).first
                #expect(firstLine?.hasPrefix("# Title") == true)
                #expect(firstLine?.first?.isNumber != true)
            }

            // Swift should have line numbers (default true).
            do {
                let result = try runCaNonTTY(
                    executable: executable,
                    arguments: ["--config", configURL.path, swiftURL.path],
                    environment: makeCleanEnvironment()
                )
                #expect(result.exitCode == 0)

                let firstLine = String(result.output.split(separator: "\n", omittingEmptySubsequences: false).first ?? "")
                let trimmed = firstLine.trimmingCharacters(in: .whitespaces)
                #expect(trimmed.hasPrefix("1 let value = 1"))
            }
        }
    }
}
