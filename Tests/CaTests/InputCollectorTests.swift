import Chroma
import Foundation
import Testing
@testable import Ca

@Suite("InputCollector")
struct InputCollectorTests {
    @Test("Collects a single file")
    func collectsSingleFile() throws {
        try withTemporaryDirectory { root in
            let fileURL = root.appendingPathComponent("Sample.swift")
            try writeFile(at: fileURL, contents: "print(\"hi\")\n")

            let inputs = try InputCollector().collect(paths: [fileURL.path])
            #expect(inputs.count == 1)

            guard let input = inputs.first else { return }
            #expect(input.path == fileURL.path)
            #expect(input.displayName == "Sample.swift")
            #expect(input.content == "print(\"hi\")\n")
            #expect(input.language == .swift)
            #expect({
                if case .file = input.source {
                    return true
                }
                return false
            }())
        }
    }

    @Test("Skips directories when files are present")
    func skipsDirectoriesWhenFilesPresent() throws {
        try withTemporaryDirectory { root in
            let dirURL = root.appendingPathComponent("Dir")
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)
            let fileURL = root.appendingPathComponent("note.txt")
            try writeFile(at: fileURL, contents: "content")

            let inputs = try InputCollector().collect(paths: [dirURL.path, fileURL.path])
            #expect(inputs.count == 1)
            #expect(inputs.first?.path == fileURL.path)
        }
    }

    @Test("Throws on missing file")
    func throwsOnMissingFile() {
        let missingPath = "/tmp/ca-tests-missing-file"
        let error = #expect(throws: CaError.self) {
            _ = try InputCollector().collect(paths: [missingPath])
        }
        guard let error else { return }
        #expect(error.description == "File not found: \(missingPath)")
    }

    @Test("Throws on unreadable file")
    func throwsOnUnreadableFile() throws {
        try withTemporaryDirectory { root in
            let fileURL = root.appendingPathComponent("secret.txt")
            try writeFile(at: fileURL, contents: "secret")
            try FileManager.default.setAttributes([.posixPermissions: 0], ofItemAtPath: fileURL.path)
            defer {
                try? FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: fileURL.path)
            }

            let error = #expect(throws: CaError.self) {
                _ = try InputCollector().collect(paths: [fileURL.path])
            }
            guard let error else { return }
            #expect(error.description == "Unable to read file: \(fileURL.path)")
        }
    }

    @Test("Throws when only directory is provided")
    func throwsOnDirectoryOnly() throws {
        try withTemporaryDirectory { root in
            let dirURL = root.appendingPathComponent("OnlyDir")
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)

            let error = #expect(throws: CaError.self) {
                _ = try InputCollector().collect(paths: [dirURL.path])
            }
            guard let error else { return }
            #expect(error.description == "Directory input is not supported yet: \(dirURL.path)")
        }
    }
}
