import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

struct ExternalPager {
    let lines: [String]
    let executablePath: String
    let arguments: [String]

    init?(lines: [String]) {
        guard Terminal.isInteractive else {
            Diagnostics.printDebug("terminal not interactive; skip external pager")
            return nil
        }
        guard let lessPath = PagerLocator.findLess() else {
            Diagnostics.printDebug("less not found on PATH")
            return nil
        }
        self.lines = lines
        self.executablePath = lessPath
        if let options = PagerLocator.lessOptions() {
            self.arguments = options
        } else {
            self.arguments = ["-FIRX"]
        }
    }

    func run() -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = arguments
        let inputPipe = Pipe()
        process.standardInput = inputPipe
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError
        Diagnostics.printDebug("Using less at \(executablePath) with args: \(arguments)")
        do {
            try process.run()
        } catch {
            return false
        }
        let pid = process.processIdentifier
        let previousForeground = tcgetpgrp(STDIN_FILENO)
        if Terminal.isInteractive {
            // less reads commands from stdin; it must be the foreground process group
            // or it can be suspended by job control and never consume input.
            if setpgid(pid, pid) != 0 {
                Diagnostics.printDebug("setpgid failed: \(errno)")
            }
            if tcsetpgrp(STDIN_FILENO, pid) != 0 {
                Diagnostics.printDebug("tcsetpgrp failed: \(errno)")
            } else {
                Diagnostics.printDebug("pager foreground process group set to \(pid)")
            }
        }
        Diagnostics.printDebug("Sending \(lines.count) lines")
        let outputHandle = inputPipe.fileHandleForWriting
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try writeLines(self.lines, to: outputHandle)
                Diagnostics.printDebug("Write completed")
            } catch {
                Diagnostics.printDebug("Write failed: \(error)")
            }
            try? outputHandle.close()
        }
        process.waitUntilExit()
        if Terminal.isInteractive, previousForeground >= 0 {
            if tcsetpgrp(STDIN_FILENO, previousForeground) != 0 {
                Diagnostics.printDebug("restore tcsetpgrp failed: \(errno)")
            }
        }
        Diagnostics.printDebug("less exit status: \(process.terminationStatus)")
        return process.terminationStatus == 0
    }
}

private func writeLines(_ lines: [String], to handle: FileHandle) throws {
    let newline = Data([0x0A])
    for (index, line) in lines.enumerated() {
        if let data = line.data(using: .utf8) {
            try handle.write(contentsOf: data)
        }
        if index < lines.count - 1 {
            try handle.write(contentsOf: newline)
        }
    }
}

private enum PagerLocator {
    static func findLess() -> String? {
        let environment = ProcessInfo.processInfo.environment
        let pathValue = environment["PATH"] ?? ""
        let candidates = pathValue
            .split(separator: ":", omittingEmptySubsequences: true)
            .map { "\($0)/less" }
        let extraCandidates = ["/usr/bin/less", "/bin/less"]

        let fileManager = FileManager.default
        for candidate in candidates + extraCandidates {
            if fileManager.isExecutableFile(atPath: candidate) {
                return candidate
            }
        }
        return nil
    }

    static func lessOptions() -> [String]? {
        let environment = ProcessInfo.processInfo.environment
        guard let raw = environment["LESS"]?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else {
            return nil
        }
        return raw.split(whereSeparator: \.isWhitespace).map(String.init)
    }
}
