import SwiftUI

struct TodayToolbar: ViewModifier {
    @State private var showSettings = false
    @State private var showAddCard = false
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus") {
                        showAddCard = true
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
            .sheet(isPresented: $showAddCard) {
                AddTaskView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
    }
}

extension View {
    func appToolbar() -> some View {
        modifier(TodayToolbar())
    }
}
