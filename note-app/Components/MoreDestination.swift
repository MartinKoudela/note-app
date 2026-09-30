import SwiftUI

enum MoreDestination: Identifiable {
    case archive, bin, settings

    var id: Self { self }

    var title: String {
        switch self {
        case .archive: "Archive"
        case .bin: "Bin"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .archive: "archivebox"
        case .bin: "trash"
        case .settings: "gear"
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .archive: ArchiveView()
        case .bin: BinView()
        case .settings: SettingsView()
        }
    }
}
