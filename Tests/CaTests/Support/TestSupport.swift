import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

private let environmentLock = NSLock()

struct ProcessResult {
    let output: String
    let exitCode: Int32
}

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

func locateCaExecutable() throws -> URL {
    let fileManager = FileManager.default
    let probeBases: [URL] = [
        URL(fileURLWithPath: CommandLine.arguments[0]),
        Bundle.main.bundleURL,
    ]

    for base in probeBases {
        var current = base
        for _ in 0..<10 {
            let candidate = current.appendingPathComponent("ca")
            if fileManager.isExecutableFile(atPath: candidate.path) {
                return candidate
            }
            current = current.deletingLastPathComponent()
        }
    }

    let packageRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
    let directCandidates = [
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(".build/debug/ca"),
        packageRoot.appendingPathComponent(".build/debug/ca"),
        packageRoot.appendingPathComponent(".build/arm64-apple-macosx/debug/ca"),
        packageRoot.appendingPathComponent(".build/x86_64-apple-macosx/debug/ca"),
        packageRoot.appendingPathComponent(".build/x86_64-unknown-linux-gnu/debug/ca"),
    ]

    for candidate in directCandidates where fileManager.isExecutableFile(atPath: candidate.path) {
        return candidate
    }

    let buildRoots = [
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(".build"),
        packageRoot.appendingPathComponent(".build"),
    ].filter { fileManager.fileExists(atPath: $0.path) }

    var matches: [URL] = []
    for buildRoot in buildRoots {
        if let enumerator = fileManager.enumerator(
            at: buildRoot,
            includingPropertiesForKeys: [.isDirectoryKey, .isExecutableKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) {
            for case let url as URL in enumerator {
                guard url.lastPathComponent == "ca" else { continue }
                let values = try url.resourceValues(forKeys: [.isDirectoryKey, .isExecutableKey])
                guard values.isDirectory != true, values.isExecutable == true else { continue }
                if url.path.contains("/checkouts/") || url.path.contains("/plugins/") {
                    continue
                }
                matches.append(url)
            }
        }
    }

    if let preferred = matches.first(where: { $0.path.contains("/debug/") }) {
        return preferred
    }
    if let first = matches.first {
        return first
    }
    throw NSError(domain: "CaTests", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to locate ca executable."])
}

func makeCleanEnvironment(additions: [String: String] = [:]) -> [String: String] {
    var environment = ProcessInfo.processInfo.environment
    environment["NO_COLOR"] = nil
    environment["CHROMA_NO_COLOR"] = nil
    environment["TERM"] = "xterm-256color"
    for (key, value) in additions {
        environment[key] = value
    }
    return environment
}

func runCaNonTTY(
    executable: URL,
    arguments: [String],
    environment: [String: String]
) throws -> ProcessResult {
    let process = Process()
    process.executableURL = executable
    process.arguments = arguments
    process.environment = environment

    let inputPipe = Pipe()
    let outputPipe = Pipe()
    process.standardInput = inputPipe
    process.standardOutput = outputPipe
    process.standardError = outputPipe

    try process.run()
    try inputPipe.fileHandleForWriting.close()
    let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return ProcessResult(
        output: String(decoding: data, as: UTF8.self),
        exitCode: process.terminationStatus
    )
}

#if os(macOS)
func runCaWithPTY(
    executable: URL,
    arguments: [String],
    environment: [String: String]
) throws -> ProcessResult {
    var master: Int32 = 0
    var slave: Int32 = 0
    guard openpty(&master, &slave, nil, nil, nil) == 0 else {
        throw NSError(domain: "CaTests", code: 3, userInfo: [NSLocalizedDescriptionKey: "openpty failed."])
    }

    let masterHandle = FileHandle(fileDescriptor: master, closeOnDealloc: true)
    let slaveHandle = FileHandle(fileDescriptor: slave, closeOnDealloc: true)

    let process = Process()
    process.executableURL = executable
    process.arguments = arguments
    process.environment = environment
    process.standardInput = slaveHandle
    process.standardOutput = slaveHandle
    process.standardError = slaveHandle

    try process.run()
    try? slaveHandle.close()
    let data = masterHandle.readDataToEndOfFile()
    process.waitUntilExit()
    return ProcessResult(
        output: String(decoding: data, as: UTF8.self),
        exitCode: process.terminationStatus
    )
}
#endif

func withEnvironment(_ key: String, value: String?, _ body: () throws -> Void) rethrows {
    environmentLock.lock()
    defer { environmentLock.unlock() }
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
