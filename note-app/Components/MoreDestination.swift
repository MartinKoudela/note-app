import SwiftUI

enum MoreDestination: Identifiable {
    case completed, archive, bin, settings

    var id: Self { self }

    var title: String {
        switch self {
        case .completed: "Completed"
        case .archive: "Archive"
        case .bin: "Bin"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .completed: "checkmark.circle"
        case .archive: "archivebox"
        case .bin: "trash"
        case .settings: "gear"
        }
    }

    @ViewBuilder
    var view: some View {
        switch self {
        case .completed: CompletedView()
        case .archive: ArchiveView()
        case .bin: BinView()
        case .settings: SettingsView()
        }
    }
}
