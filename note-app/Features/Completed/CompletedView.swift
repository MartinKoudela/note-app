import SwiftUI
import SwiftData

struct CompletedView: View {

    @Environment(\.dismiss) private var dismiss

    @Query(
        filter: #Predicate<TaskItem> { $0.isCompleted },
        sort: \TaskItem.completedAt,
        order: .reverse
    ) private var items: [TaskItem]

    private var completedItems: [TaskItem] {
        items.filter { $0.deletedAt == nil && $0.project?.deletedAt == nil }
    }

    private var days: [(day: Date, items: [TaskItem])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: completedItems) { item in
            calendar.startOfDay(for: item.completedAt ?? item.createdAt)
        }
        return grouped
            .map { (day: $0.key, items: $0.value) }
            .sorted { $0.day > $1.day }
    }

    var body: some View {
        NavigationStack {
            Group {
                if completedItems.isEmpty {
                    ContentUnavailableView(
                        "No Completed Tasks",
                        systemImage: MoreDestination.completed.systemImage,
                        description: Text("Tasks you complete will appear here.")
                    )
                } else {
                    List {
                        ForEach(days, id: \.day) { group in
                            Section {
                                ForEach(group.items) { item in
                                    TaskListRow(item: item)
                                }
                            } header: {
                                Text(title(for: group.day))
                            }
                            .headerProminence(.increased)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(MoreDestination.completed.title)
            .navigationDestination(for: TaskItem.self) { item in
                TaskDetailView(item: item)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
            }
        }
    }

    private func title(for day: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(day) { return "Today" }
        if calendar.isDateInYesterday(day) { return "Yesterday" }
        return day.weekdayDayMonth
    }
}

#Preview {
    CompletedView()
        .modelContainer(for: [Project.self, TaskItem.self], inMemory: true)
}
