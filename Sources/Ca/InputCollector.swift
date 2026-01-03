import Chroma
import Foundation

struct InputFile {
    let path: String?
    let displayName: String
    let content: String
    let language: LanguageID?
    let source: InputSource
}

enum InputSource {
    case file
    case stdin
}

struct InputCollector {
    func collect(paths: [String]) throws -> [InputFile] {
        if paths.isEmpty {
            return [readStdin()] 
        }

        var inputs: [InputFile] = []
        var skippedDirectories: [String] = []

        for path in paths {
            if path == "-" {
                inputs.append(readStdin())
                continue
            }

            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
                throw CaError.fileNotFound(path)
            }

            if isDirectory.boolValue {
                skippedDirectories.append(path)
                continue
            }

            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let content = String(decoding: data, as: UTF8.self)
                let displayName = URL(fileURLWithPath: path).lastPathComponent
                inputs.append(
                    InputFile(
                        path: path,
                        displayName: displayName,
                        content: content,
                        language: LanguageID.fromFilePath(path),
                        source: .file
                    )
                )
            } catch {
                throw CaError.unreadableFile(path)
            }
        }

        if inputs.isEmpty {
            if let path = skippedDirectories.first {
                throw CaError.directoryNotSupported(path)
            }
            throw CaError.missingInput
        }

        if !skippedDirectories.isEmpty {
            let list = skippedDirectories.joined(separator: ", ")
            Diagnostics.printError("Skipped directories (not supported yet): \(list)")
        }

        return inputs
    }

    private func readStdin() -> InputFile {
        let data = FileHandle.standardInput.readDataToEndOfFile()
        let content = String(decoding: data, as: UTF8.self)
        return InputFile(
            path: nil,
            displayName: "<stdin>",
            content: content,
            language: nil,
            source: .stdin
        )
    }
}
