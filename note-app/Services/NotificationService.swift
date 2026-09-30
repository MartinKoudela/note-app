import Foundation
import UserNotifications

enum NotificationService {
    private static let delegate = NotificationDelegate()

    static func configure() {
        UNUserNotificationCenter.current().delegate = delegate
    }

    static func requestAuthorization() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
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

        let identifier = item.reminderID
        let title = item.title
        let body = item.project?.name ?? ""
        let hasSound = item.reminderHasSound
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)

        Task {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = hasSound ? .default : nil

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            try? await UNUserNotificationCenter.current().add(request)
        }
    }

    static func update(for items: [TaskItem]) {
        for item in items {
            update(for: item)
        }
    }

    static func cancel(for item: TaskItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.reminderID])
    }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
