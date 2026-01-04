import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

func withTemporaryDirectory<T>(_ body: (URL) throws -> T) throws -> T {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent("ca-tests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    defer {
        try? FileManager.default.removeItem(at: root)
    }
    return try body(root)
}

func writeFile(at url: URL, contents: String) throws {
    let data = Data(contents.utf8)
    try data.write(to: url)
}

func withEnvironment(_ key: String, value: String?, _ body: () throws -> Void) rethrows {
    let original = getenv(key).map { String(cString: $0) }
    if let value {
        setenv(key, value, 1)
    } else {
        unsetenv(key)
    }
    defer {
        if let original {
            setenv(key, original, 1)
        } else {
            unsetenv(key)
        }
    }
    try body()
}
