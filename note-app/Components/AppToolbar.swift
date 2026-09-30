import SwiftUI

struct AppToolbar: ViewModifier {
    let primary: AddAction
    var isSelecting = false
    var onSelect: (() -> Void)?

    @State private var activeAdd: AddAction?
    @State private var destination: MoreDestination?

    func body(content: Content) -> some View {
        content
            .toolbar {
                if !isSelecting {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button("New Task", systemImage: "checklist") {
                                activeAdd = .task
                            }
                            Button("New Project", systemImage: "folder.badge.plus") {
                                activeAdd = .project
                            }
                        } label: {
                            Label("Add", systemImage: "plus")
                        } primaryAction: {
                            activeAdd = primary
                        }
                    }

                    ToolbarSpacer(.fixed, placement: .topBarTrailing)

                    ToolbarItem(placement: .topBarTrailing) {
                        Menu("More", systemImage: "ellipsis") {
                            if let onSelect {
                                Button("Select", systemImage: "checkmark.circle") {
                                    withAnimation(.snappy) {
                                        onSelect()
                                    }
                                }

                                Divider()
                            }

                            menuButton(.completed)
                            menuButton(.archive)
                            menuButton(.bin)

                            Divider()

                            menuButton(.settings)
                        }
                    }
                }
            }
            .sheet(item: $activeAdd) { action in
                AddSheet(action: action)
            }
            .sheet(item: $destination) { destination in
                destination.view
            }
    }

    private func menuButton(_ item: MoreDestination) -> some View {
        Button(item.title, systemImage: item.systemImage) {
            destination = item
        }
    }
}

extension View {
    func appToolbar(primary: AddAction, isSelecting: Bool = false, onSelect: (() -> Void)? = nil) -> some View {
        modifier(AppToolbar(primary: primary, isSelecting: isSelecting, onSelect: onSelect))
    }
}
