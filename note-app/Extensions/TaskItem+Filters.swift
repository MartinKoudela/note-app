import Foundation

extension TaskItem {
    static let completedGracePeriod: TimeInterval = 3

    var isActive: Bool {
        deletedAt == nil && !isArchived && project?.deletedAt == nil
    }

    var isOpenOrDoneToday: Bool {
        guard isCompleted else { return true }
        guard let completedAt else { return false }
        return Calendar.current.isDateInToday(completedAt)
    }

    var isOverdue: Bool {
        guard let dueDate, !isCompleted else { return false }
        return dueDate < Calendar.current.startOfDay(for: .now)
    }

    func isVisible(at now: Date, showCompleted: Bool = false) -> Bool {
        guard isCompleted, !showCompleted else { return true }
        guard let completedAt else { return false }
        return now.timeIntervalSince(completedAt) < Self.completedGracePeriod
    }
}

extension Array where Element == TaskItem {
    func sortedByDue() -> [TaskItem] {
        sorted {
            ($0.dueDate ?? .distantFuture, $0.createdAt) < ($1.dueDate ?? .distantFuture, $1.createdAt)
        }
    }
}
