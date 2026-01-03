import ArgumentParser
import Chroma
import Foundation

struct CaConfig: Equatable {
    struct ThemeSelection: Equatable {
        var name: String?
        var appearance: ThemeAppearancePreference
    }

    var theme: ThemeSelection
    var lineNumbers: Bool
    var paging: PagingMode
    var headers: Bool

    static let `default` = CaConfig(
        theme: .init(name: nil, appearance: .auto),
        lineNumbers: true,
        paging: .auto,
        headers: true
    )
}

enum ThemeAppearancePreference: String {
    case auto
    case dark
    case light
}

enum PagingMode: String, CaseIterable {
    case auto
    case always
    case never
}

extension PagingMode: ExpressibleByArgument {}
