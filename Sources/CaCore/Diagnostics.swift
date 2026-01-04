import Foundation

enum Diagnostics {
    static var isPagerDebugEnabled: Bool {
        let value = ProcessInfo.processInfo.environment["CA_PAGER_DEBUG"] ?? ""
        return value == "1" || value.lowercased() == "true"
    }

    static func printError(_ message: String) {
        let output = "\(message)\n"
        if let data = output.data(using: .utf8) {
            FileHandle.standardError.write(data)
        }
    }

    static func printDebug(_ message: String) {
        guard isPagerDebugEnabled else { return }
        printError("[ca][pager] \(message)")
    }
}
