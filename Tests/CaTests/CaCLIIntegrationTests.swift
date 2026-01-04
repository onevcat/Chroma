import Foundation
import Testing
@testable import Ca

@Suite("ca CLI integration")
struct CaCLIIntegrationTests {
    @Test("Non-TTY output omits ANSI sequences")
    func nonTtyOutputOmitsAnsi() throws {
        let executable = try locateCaExecutable()
        try withTemporaryDirectory { root in
            let fileURL = root.appendingPathComponent("Sample.swift")
            try writeFile(at: fileURL, contents: "let value = 1\n")

            let result = try runCaNonTTY(
                executable: executable,
                arguments: ["--no-line-numbers", "--paging", "never", fileURL.path],
                environment: makeCleanEnvironment()
            )

            #expect(result.exitCode == 0)
            #expect(result.output.contains("let value = 1"))
            #expect(!result.output.contains("\u{1B}["))
        }
    }

    #if os(macOS)
    @Test("TTY output includes ANSI sequences")
    func ttyOutputIncludesAnsi() throws {
        let executable = try locateCaExecutable()
        try withTemporaryDirectory { root in
            let fileURL = root.appendingPathComponent("Sample.swift")
            try writeFile(at: fileURL, contents: "let value = 1\n")

            let result = try runCaWithPTY(
                executable: executable,
                arguments: ["--no-line-numbers", "--paging", "never", fileURL.path],
                environment: makeCleanEnvironment()
            )

            #expect(result.exitCode == 0)
            #expect(result.output.contains("\u{1B}["))
        }
    }
    #endif
}
