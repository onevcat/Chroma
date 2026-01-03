import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

struct Pager {
    let lines: [String]
    let viewHeight: Int

    init?(lines: [String]) {
        guard Terminal.isInteractive, let size = Terminal.size() else { return nil }
        self.lines = lines
        self.viewHeight = max(size.rows, 1)
    }

    func run() {
        let maxOffset = max(0, lines.count - viewHeight)
        if maxOffset == 0 {
            write(lines.joined(separator: "\n"))
            return
        }

        let terminalMode = TerminalMode()
        terminalMode?.enableRawMode()
        TerminalControl.enterAlternateScreen()
        TerminalControl.hideCursor()
        defer {
            TerminalControl.showCursor()
            TerminalControl.exitAlternateScreen()
            terminalMode?.restore()
        }

        var offset = 0
        var reader = KeyReader()
        render(offset: offset)

        while let key = reader.readKey() {
            let previous = offset
            switch key {
            case .quit:
                return
            case .up:
                offset = max(0, offset - 1)
            case .down:
                offset = min(maxOffset, offset + 1)
            case .pageUp:
                offset = max(0, offset - viewHeight)
            case .pageDown:
                offset = min(maxOffset, offset + viewHeight)
            case .home:
                offset = 0
            case .end:
                offset = maxOffset
            case .none:
                break
            }
            if offset != previous {
                render(offset: offset)
            }
        }
    }

    private func render(offset: Int) {
        TerminalControl.clearScreen()
        let endIndex = min(offset + viewHeight, lines.count)
        let slice = lines[offset..<endIndex]
        write(slice.joined(separator: "\r\n"))
    }

    private func write(_ text: String) {
        if let data = text.data(using: .utf8) {
            FileHandle.standardOutput.write(data)
        }
    }
}

private enum Key {
    case up
    case down
    case pageUp
    case pageDown
    case home
    case end
    case quit
    case none
}

private struct KeyReader {
    mutating func readKey() -> Key? {
        guard let byte = readByte() else { return nil }
        switch byte {
        case 0x1B:
            return readEscapeSequence()
        case 0x71, 0x51:
            return .quit
        case 0x6A:
            return .down
        case 0x6B:
            return .up
        case 0x20:
            return .pageDown
        case 0x62:
            return .pageUp
        case 0x67:
            return .home
        case 0x47:
            return .end
        default:
            return Key.none
        }
    }

    private func readEscapeSequence() -> Key {
        guard let first = readByte() else { return Key.none }
        guard first == 0x5B else { return Key.none }
        guard let second = readByte() else { return Key.none }
        switch second {
        case 0x41:
            return .up
        case 0x42:
            return .down
        case 0x48:
            return .home
        case 0x46:
            return .end
        case 0x35:
            _ = readByte()
            return .pageUp
        case 0x36:
            _ = readByte()
            return .pageDown
        default:
            return Key.none
        }
    }

    private func readByte() -> UInt8? {
        var byte: UInt8 = 0
        let count = read(STDIN_FILENO, &byte, 1)
        return count == 1 ? byte : nil
    }
}
