import Foundation

enum Diagnostics {
    static func printError(_ message: String) {
        let output = "\(message)\n"
        if let data = output.data(using: .utf8) {
            FileHandle.standardError.write(data)
        }
    }
}
