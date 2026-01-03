import Foundation

enum CaError: Error, CustomStringConvertible {
    case missingInput
    case fileNotFound(String)
    case unreadableFile(String)
    case directoryNotSupported(String)

    var description: String {
        switch self {
        case .missingInput:
            return "No input provided. Pass a file path or pipe content into ca."
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .unreadableFile(let path):
            return "Unable to read file: \(path)"
        case .directoryNotSupported(let path):
            return "Directory input is not supported yet: \(path)"
        }
    }
}
