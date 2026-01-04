import ArgumentParser
import Foundation

package struct CaCommand: AsyncParsableCommand {
    package static let version = "0.2.0"

    package static let configuration = CommandConfiguration(
        commandName: "ca",
        abstract: "A Chroma-powered cat replacement with syntax highlighting.",
        version: version
    )

    @Argument(help: "Files to display. Use '-' to read from stdin.")
    var paths: [String] = []

    @Option(help: "Theme name (ChromaBase46Themes or 'dark'/'light').")
    var theme: String?

    @Option(help: "Paging mode: auto, always, never.")
    var paging: PagingMode?

    @Flag(inversion: .prefixedNo, help: "Show line numbers.")
    var lineNumbers: Bool?

    @Flag(inversion: .prefixedNo, help: "Show file headers when rendering multiple inputs.")
    var headers: Bool?

    @Option(help: "Config file path (default: ~/.config/ca/config.json).")
    var config: String?

    package init() {}

    package mutating func run() async throws {
        let loader = CaConfigLoader(filePathOverride: config)
        var effectiveConfig = await loader.load()

        if let theme {
            effectiveConfig.theme.name = theme
        }
        if let paging {
            effectiveConfig.paging = paging
        }
        if let lineNumbers {
            effectiveConfig.lineNumbers = lineNumbers
        }
        if let headers {
            effectiveConfig.headers = headers
        }

        do {
            let inputs = try InputCollector().collect(paths: paths)
            let theme = ThemeResolver().resolve(using: effectiveConfig)
            let highlighter = HighlighterService(theme: theme, lineNumbers: effectiveConfig.lineNumbers)
            let documents = try inputs.map { try highlighter.render($0) }
            let lines = OutputComposer().compose(documents: documents, showHeaders: effectiveConfig.headers)
            output(lines: lines, paging: effectiveConfig.paging)
        } catch let error as CaError {
            Diagnostics.printError(error.description)
            throw ExitCode.failure
        } catch {
            Diagnostics.printError("Unexpected error: \(error)")
            throw ExitCode.failure
        }
    }

    private func output(lines: [String], paging: PagingMode) {
        switch paging {
        case .never:
            write(lines)
        case .always:
            page(lines: lines)
        case .auto:
            if shouldPage(lines: lines) {
                page(lines: lines)
            } else {
                write(lines)
            }
        }
    }

    private func shouldPage(lines: [String]) -> Bool {
        guard Terminal.isInteractive, let size = Terminal.size() else { return false }
        return lines.count > size.rows
    }

    private func page(lines: [String]) {
        Diagnostics.printDebug("paging mode engaged; lines=\(lines.count), interactive=\(Terminal.isInteractive)")
        if let pager = ExternalPager(lines: lines), pager.run() {
            Diagnostics.printDebug("external pager finished")
            return
        }
        Diagnostics.printDebug("falling back to internal pager")
        if let pager = Pager(lines: lines) {
            pager.run()
        } else {
            Diagnostics.printDebug("internal pager unavailable; writing to stdout")
            write(lines)
        }
    }

    private func write(_ lines: [String]) {
        let output = lines.joined(separator: "\n")
        if let data = output.data(using: .utf8) {
            FileHandle.standardOutput.write(data)
        }
    }
}
