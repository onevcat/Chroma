import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

struct TerminalSize: Equatable {
    let rows: Int
    let columns: Int
}

enum Terminal {
    static var isInteractive: Bool {
        isatty(STDIN_FILENO) != 0 && isatty(STDOUT_FILENO) != 0
    }

    static func size() -> TerminalSize? {
        var ws = winsize()
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == 0 {
            let rows = Int(ws.ws_row)
            let columns = Int(ws.ws_col)
            if rows > 0 && columns > 0 {
                return TerminalSize(rows: rows, columns: columns)
            }
        }
        return nil
    }
}

final class TerminalMode {
    private var original: termios
    private var active = false

    init?() {
        var current = termios()
        guard tcgetattr(STDIN_FILENO, &current) == 0 else { return nil }
        self.original = current
    }

    func enableRawMode() {
        guard !active else { return }
        var raw = original
        cfmakeraw(&raw)
        withUnsafeMutablePointer(to: &raw.c_cc) { ptr in
            ptr.withMemoryRebound(to: cc_t.self, capacity: Int(NCCS)) { buffer in
                buffer[Int(VMIN)] = 1
                buffer[Int(VTIME)] = 0
            }
        }
        _ = tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw)
        active = true
    }

    func restore() {
        guard active else { return }
        var saved = original
        _ = tcsetattr(STDIN_FILENO, TCSAFLUSH, &saved)
        active = false
    }

    deinit {
        restore()
    }
}

enum TerminalControl {
    static func enterAlternateScreen() {
        send("\u{1B}[?1049h")
    }

    static func exitAlternateScreen() {
        send("\u{1B}[?1049l")
    }

    static func clearScreen() {
        send("\u{1B}[2J")
        send("\u{1B}[H")
    }

    static func hideCursor() {
        send("\u{1B}[?25l")
    }

    static func showCursor() {
        send("\u{1B}[?25h")
    }

    private static func send(_ sequence: String) {
        if let data = sequence.data(using: .utf8) {
            FileHandle.standardOutput.write(data)
        }
    }
}
