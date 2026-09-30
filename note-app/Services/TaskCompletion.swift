import Foundation
import SwiftData

enum TaskCompletion {
    static func didChange(_ item: TaskItem) {
        if item.isCompleted {
            if item.completedAt == nil {
                item.completedAt = .now
            }
            createNextOccurrence(of: item)
        } else {
            item.completedAt = nil
            removeNextOccurrence(of: item)
        }
        NotificationService.update(for: item)
    }

    private static func createNextOccurrence(of item: TaskItem) {
        guard item.nextOccurrenceID == nil,
              let rule = item.repeatRule,
              let dueDate = item.dueDate,
              let nextDate = rule.nextDate(afterCompleting: dueDate),
              let context = item.modelContext
        else { return }

        let next = TaskItem(
            title: item.title,
            project: item.project,
            dueDate: nextDate,
            hasDueTime: item.hasDueTime,
            priority: item.priority,
            hasReminder: item.hasReminder
        )
        next.notes = item.notes
        next.reminderHasSound = item.reminderHasSound
        next.repeatRule = rule

        context.insert(next)
        item.nextOccurrenceID = next.reminderID
        NotificationService.update(for: next)
    }

    private static func removeNextOccurrence(of item: TaskItem) {
        guard let nextID = item.nextOccurrenceID else { return }
        item.nextOccurrenceID = nil

        guard let context = item.modelContext else { return }
        var descriptor = FetchDescriptor<TaskItem>(predicate: #Predicate { $0.reminderID == nextID })
        descriptor.fetchLimit = 1

        guard let next = try? context.fetch(descriptor).first,
              !next.isCompleted,
              next.nextOccurrenceID == nil
        else { return }

        NotificationService.cancel(for: next)
        context.delete(next)
    }
}
