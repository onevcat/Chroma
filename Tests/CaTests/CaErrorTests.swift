import Testing
@testable import CaCore

@Suite("CaError")
struct CaErrorTests {
    @Test("Descriptions are stable")
    func descriptions() {
        #expect(
            CaError.missingInput.description
                == "No input provided. Pass a file path or pipe content into ca."
        )

        let missingPath = "/tmp/missing"
        #expect(
            CaError.fileNotFound(missingPath).description
                == "File not found: \(missingPath)"
        )

        let unreadablePath = "/tmp/unreadable"
        #expect(
            CaError.unreadableFile(unreadablePath).description
                == "Unable to read file: \(unreadablePath)"
        )

        let directoryPath = "/tmp/dir"
        #expect(
            CaError.directoryNotSupported(directoryPath).description
                == "Directory input is not supported yet: \(directoryPath)"
        )
    }
}
