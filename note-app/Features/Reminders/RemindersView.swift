import SwiftUI

struct RemindersView: View {

    private let reminders: [TaskItem] = []

    private var reminderCount: Int {
        reminders.count
    }

    @State private var showAddReminder = false

    var body: some View {
        NavigationStack {
            Group {
                if reminderCount == 0 {
                    ContentUnavailableView {
                        Label("No Reminders", systemImage: AppTab.reminders.systemImage)
                    } description: {
                        Text("Reminders will appear here.")
                    } actions: {
                        Button("Add Reminder") {
                            showAddReminder = true
                        }
                        .buttonStyle(.glassProminent)
                    }
                } else {
                    Text("Reminders")
                }
            }
            .navigationTitle(AppTab.reminders.title)
            .appToolbar()
            .sheet(isPresented: $showAddReminder) {
                AddTaskView()
            }
        }
    }
}

#Preview {
    RemindersView()
}
