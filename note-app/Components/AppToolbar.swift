import SwiftUI

struct AppToolbar: ViewModifier {
    let primary: AddAction
    
    @State private var activeAdd: AddAction?
    @State private var destination: MoreDestination?
    
    func body(content: Content) -> some View {
        content
            .toolbar {
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
                        
                        Button("Select", systemImage: "checkmark.circle") {
                            print("Select")
                        }
                        
                        Divider()
                        
                        menuButton(.completed)
                        menuButton(.archive)
                        menuButton(.bin)

                        Divider()

                        menuButton(.settings)
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
    func appToolbar(primary: AddAction) -> some View {
        modifier(AppToolbar(primary: primary))
    }
}
