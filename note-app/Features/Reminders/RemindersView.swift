import SwiftUI
import SwiftData

struct RemindersView: View {

    private enum TimelineSection: CaseIterable {
        case overdue, today, tomorrow, nextWeek, later, noDate

        var title: String {
            switch self {
            case .overdue: "Overdue"
            case .today: "Today"
            case .tomorrow: "Tomorrow"
            case .nextWeek: "Next 7 Days"
            case .later: "Later"
            case .noDate: "No Date"
            }
        }

        static func of(_ item: TaskItem) -> TimelineSection {
            guard let dueDate = item.dueDate else { return .noDate }
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: .now)
            let weekLimit = calendar.date(byAdding: .day, value: 8, to: startOfToday) ?? startOfToday

            if dueDate < startOfToday { return .overdue }
            if calendar.isDateInToday(dueDate) { return .today }
            if calendar.isDateInTomorrow(dueDate) { return .tomorrow }
            if dueDate < weekLimit { return .nextWeek }
            return .later
        }
    }

    @Query(sort: \TaskItem.createdAt) private var items: [TaskItem]

    @State private var activeAdd: AddAction?
    @State private var now = Date.now
    @Environment(\.scenePhase) private var scenePhase

    private var relevantItems: [TaskItem] {
        items.filter { $0.isActive && $0.isOpenOrDoneToday }
    }

    private var visibleItems: [TaskItem] {
        relevantItems.filter { $0.isVisible(at: now) }.sortedByDue()
    }

    private var sections: [(section: TimelineSection, items: [TaskItem])] {
        let grouped = Dictionary(grouping: visibleItems, by: TimelineSection.of)
        return TimelineSection.allCases.compactMap { section in
            guard let items = grouped[section], !items.isEmpty else { return nil }
            return (section: section, items: items)
        }
    }

    private var completedCount: Int {
        relevantItems.filter(\.isCompleted).count
    }

    var body: some View {
        NavigationStack {
            Group {
                if visibleItems.isEmpty {
                    ContentUnavailableView {
                        Label("No Tasks", systemImage: AppTab.reminders.systemImage)
                    } description: {
                        Text("All your tasks will appear here, sorted by date.")
                    } actions: {
                        Button("Add Reminder") { activeAdd = .reminder }
                            .buttonStyle(.glassProminent)
                    }
                } else {
                    List {
                        ForEach(sections, id: \.section) { group in
                            Section {
                                ForEach(group.items) { item in
                                    TaskListRow(item: item)
                                }
                            } header: {
                                Text(group.section.title)
                                    .foregroundStyle(group.section == .overdue ? .red : .primary)
                            }
                            .headerProminence(.increased)
                        }
                    }
                    .listStyle(.plain)
                    .animation(.default, value: now)
                }
            }
            .navigationTitle(AppTab.reminders.title)
            .appToolbar(primary: .reminder)
            .sheet(item: $activeAdd) { AddSheet(action: $0) }
            .navigationDestination(for: TaskItem.self) { item in
                TaskDetailView(item: item)
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    now = .now
                }
            }
            .task {
                for await _ in NotificationCenter.default.notifications(named: .NSCalendarDayChanged) {
                    now = .now
                }
            }
            .task(id: completedCount) {
                now = .now
                try? await Task.sleep(for: .seconds(TaskItem.completedGracePeriod))
                now = .now
            }
        }
    }
}

#Preview {
    RemindersView()
        .modelContainer(for: [Project.self, TaskItem.self], inMemory: true)
}
