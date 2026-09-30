import SwiftUI
import SwiftData

enum TaskActions {
    static func setCompleted(_ items: [TaskItem], _ done: Bool) {
        for item in items where item.isCompleted != done {
            item.isCompleted = done
            TaskCompletion.didChange(item)
        }
    }

    static func setDate(_ items: [TaskItem], daysFromToday days: Int) {
        let calendar = Calendar.current
        let day = calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: .now)) ?? .now

        for item in items {
            if item.hasDueTime, let current = item.dueDate {
                let time = calendar.dateComponents([.hour, .minute], from: current)
                item.dueDate = calendar.date(bySettingHour: time.hour ?? 0, minute: time.minute ?? 0, second: 0, of: day)
            } else {
                item.dueDate = day
            }
            NotificationService.update(for: item)
        }
    }

    static func removeDate(_ items: [TaskItem]) {
        for item in items {
            item.dueDate = nil
            item.hasDueTime = false
            item.hasReminder = false
            item.repeatRule = nil
            NotificationService.update(for: item)
        }
    }

    static func move(_ items: [TaskItem], to project: Project?) {
        for item in items {
            item.project = project
            NotificationService.update(for: item)
        }
    }

    static func setPriority(_ items: [TaskItem], _ priority: Priority) {
        for item in items {
            item.priority = priority
            NotificationService.update(for: item)
        }
    }

    static func archive(_ items: [TaskItem]) {
        for item in items {
            item.isArchived = true
            NotificationService.cancel(for: item)
        }
    }

    static func delete(_ items: [TaskItem]) {
        for item in items {
            item.deletedAt = .now
            NotificationService.cancel(for: item)
        }
    }
}

struct TaskActionMenus: View {
    let items: [TaskItem]

    @Query(sort: \Project.sortOrder) private var projects: [Project]

    private var activeProjects: [Project] {
        projects.filter { $0.deletedAt == nil && !$0.isArchived }
    }

    var body: some View {
        Menu {
            Button("Today", systemImage: "sun.max") { run { TaskActions.setDate(items, daysFromToday: 0) } }
            Button("Tomorrow", systemImage: "sunrise") { run { TaskActions.setDate(items, daysFromToday: 1) } }
            Button("Next Week", systemImage: "calendar") { run { TaskActions.setDate(items, daysFromToday: 7) } }
            Divider()
            Button("Remove Date", systemImage: "calendar.badge.minus", role: .destructive) { run { TaskActions.removeDate(items) } }
        } label: {
            Label("Date", systemImage: "calendar")
        }

        Menu {
            Button("None", systemImage: "tray") { run { TaskActions.move(items, to: nil) } }
            if !activeProjects.isEmpty {
                Divider()
                ForEach(activeProjects) { project in
                    Button(project.name, systemImage: project.icon) { run { TaskActions.move(items, to: project) } }
                }
            }
        } label: {
            Label("Move to Project", systemImage: "folder")
        }

        Menu {
            ForEach(Priority.allCases.reversed(), id: \.self) { priority in
                Button(priority == .none ? priority.title : "\(priority.marks) \(priority.title)") {
                    run { TaskActions.setPriority(items, priority) }
                }
            }
        } label: {
            Label("Priority", systemImage: "exclamationmark.circle")
        }
    }

    private func run(_ action: () -> Void) {
        withAnimation {
            action()
        }
    }
}

private struct StartTaskSelectionKey: EnvironmentKey {
    static let defaultValue: ((TaskItem) -> Void)? = nil
}

extension EnvironmentValues {
    var startTaskSelection: ((TaskItem) -> Void)? {
        get { self[StartTaskSelectionKey.self] }
        set { self[StartTaskSelectionKey.self] = newValue }
    }
}
