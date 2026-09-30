import Foundation
import SwiftData
import UserNotifications

enum NotificationService {
    enum Action {
        static let category = "TASK_REMINDER"
        static let complete = "COMPLETE"
        static let snoozeHour = "SNOOZE_HOUR"
        static let snoozeTomorrow = "SNOOZE_TOMORROW"
    }

    private static let delegate = NotificationDelegate()
    private static var container: ModelContainer?

    private static var center: UNUserNotificationCenter {
        .current()
    }

    static func configure(container: ModelContainer) {
        self.container = container
        center.delegate = delegate
        registerCategories()
        rescheduleAll()
    }

    static func requestAuthorization() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    static func update(for item: TaskItem) {
        cancel(for: item)

        guard item.isActive,
              item.hasReminder,
              !item.isCompleted,
              item.hasDueTime,
              let fireDate = item.dueDate,
              fireDate > .now
        else { return }

        schedule(item, identifier: item.reminderID, at: fireDate)
    }

    static func update(for items: [TaskItem]) {
        for item in items {
            update(for: item)
        }
    }

    static func cancel(for item: TaskItem) {
        center.removePendingNotificationRequests(withIdentifiers: [item.reminderID, snoozeIdentifier(for: item)])
        center.removeDeliveredNotifications(withIdentifiers: [item.reminderID, snoozeIdentifier(for: item)])
    }

    static func handle(action: String, reminderID: String) {
        guard let item = task(withReminderID: reminderID) else { return }

        switch action {
        case Action.complete:
            item.isCompleted = true
            item.completedAt = .now
            TaskCompletion.didChange(item)
            cancel(for: item)
        case Action.snoozeHour:
            snooze(item, until: .now.addingTimeInterval(60 * 60))
        case Action.snoozeTomorrow:
            let minutes = UserDefaults.standard.object(forKey: ReminderDefaults.timeKey) as? Int ?? ReminderDefaults.defaultMinutes
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
            snooze(item, until: ReminderDefaults.date(on: tomorrow, minutes: minutes))
        default:
            NotificationRouter.shared.taskToOpen = item
        }
    }

    private static func snooze(_ item: TaskItem, until date: Date) {
        schedule(item, identifier: snoozeIdentifier(for: item), at: date)
    }

    private static func snoozeIdentifier(for item: TaskItem) -> String {
        item.reminderID + ".snooze"
    }

    private static func rescheduleAll() {
        guard let context = container?.mainContext,
              let items = try? context.fetch(FetchDescriptor<TaskItem>())
        else { return }
        update(for: items)
    }

    private static func task(withReminderID reminderID: String) -> TaskItem? {
        guard let context = container?.mainContext else { return nil }
        var descriptor = FetchDescriptor<TaskItem>(predicate: #Predicate { $0.reminderID == reminderID })
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    private static func registerCategories() {
        let complete = UNNotificationAction(
            identifier: Action.complete,
            title: "Complete",
            icon: UNNotificationActionIcon(systemImageName: "checkmark.circle")
        )
        let snoozeHour = UNNotificationAction(
            identifier: Action.snoozeHour,
            title: "Remind in 1 Hour",
            icon: UNNotificationActionIcon(systemImageName: "clock")
        )
        let snoozeTomorrow = UNNotificationAction(
            identifier: Action.snoozeTomorrow,
            title: "Remind Tomorrow",
            icon: UNNotificationActionIcon(systemImageName: "sunrise")
        )
        let category = UNNotificationCategory(
            identifier: Action.category,
            actions: [complete, snoozeHour, snoozeTomorrow],
            intentIdentifiers: []
        )
        center.setNotificationCategories([category])
    }

    private static func schedule(_ item: TaskItem, identifier: String, at fireDate: Date) {
        let reminderID = item.reminderID
        let title = item.priority == .none ? item.title : "\(item.priority.marks) \(item.title)"
        let subtitle = item.project?.name ?? ""
        let body = notificationBody(for: item)
        let thread = item.project.map { "project-\($0.name)" } ?? "tasks"
        let hasSound = item.reminderHasSound
        let relevance = Double(item.priority.rawValue) / Double(Priority.high.rawValue)
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)

        Task {
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subtitle
            content.body = body
            content.sound = hasSound ? .default : nil
            content.categoryIdentifier = Action.category
            content.threadIdentifier = thread
            content.relevanceScore = relevance
            content.userInfo = ["reminderID": reminderID]

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            try? await center.add(request)
        }
    }

    private static func notificationBody(for item: TaskItem) -> String {
        let notes = item.notes
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        if !notes.isEmpty {
            return notes
        }

        guard let dueDate = item.dueDate else { return "" }
        return "Due at \(dueDate.formatted(date: .omitted, time: .shortened))"
    }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let action = response.actionIdentifier
        guard let reminderID = response.notification.request.content.userInfo["reminderID"] as? String else { return }

        await MainActor.run {
            NotificationService.handle(action: action, reminderID: reminderID)
        }
    }
}
