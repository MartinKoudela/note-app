import SwiftUI
import SwiftData


struct RemindersView: View {
    
    @Query(sort: \TaskItem.createdAt) private var items: [TaskItem]
    
    private var reminderCount: Int {
        reminders.count
    }
    
    private var activeItems: [TaskItem] {
        items.filter { $0.deletedAt == nil && !$0.isArchived }
    }

    private var reminders: [TaskItem] {
        activeItems.filter(\.hasReminder)
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
                    List(reminders) { item in
                        TaskRow(item: item)
                            .taskSwipeActions(item)
                    }
                    .listStyle(.plain)
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
        .modelContainer(for: [Project.self, TaskItem.self], inMemory: true)
    
}
