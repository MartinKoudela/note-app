import SwiftUI

struct AppToolbar: ViewModifier {
    let primary: AddAction
    
    @State private var showSettings = false
    @State private var activeAdd: AddAction?
    
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
                        Button("Settings", systemImage: "gear") {
                            showSettings = true
                        }
                    }
                }
            }
            .sheet(item: $activeAdd) { action in
                AddSheet(action: action)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
    }
}

extension View {
    func appToolbar(primary: AddAction) -> some View {
        modifier(AppToolbar(primary: primary))
    }
}
