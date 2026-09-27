import SwiftUI

struct RemindersView: View {
    
    private let reminders: [TaskItem] = []
    
    private var reminderCount: Int {
        reminders.count
    }
    
    @State private var activeAdd: AddAction?
    
    var body: some View {
        NavigationStack {
            Group {
                if reminderCount == 0 {
                    ContentUnavailableView {
                        Label("No Reminders", systemImage: AppTab.reminders.systemImage)
                    } description: {
                        Text("Reminders will appear here.")
                    } actions: {
                        Button("Add Reminder") { activeAdd = .reminder }
                            .buttonStyle(.glassProminent)
                    }
                } else {
                    Text("Reminders")
                }
            }
            .navigationTitle(AppTab.reminders.title)
            .appToolbar(primary: .reminder)
            .sheet(item: $activeAdd) { AddSheet(action: $0) }
        }
    }
}

#Preview {
    RemindersView()
}
