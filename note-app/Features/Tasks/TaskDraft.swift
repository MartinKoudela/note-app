import Foundation

struct TaskDraft: Equatable {
    enum ReminderMode: Hashable {
        case off, sound, silent
    }

    var title = ""
    var notes = ""
    var hasDate = false
    var date = Date.now
    var hasTime = false
    var hasReminder = false
    var reminderHasSound = true
    var repeatRule: RepeatRule?
    var project: Project?
    var priority = Priority.none

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var reminderMode: ReminderMode {
        get {
            guard hasReminder else { return .off }
            return reminderHasSound ? .sound : .silent
        }
        set {
            hasReminder = newValue != .off
            if newValue != .off {
                reminderHasSound = newValue == .sound
            }
        }
    }

    var dueDate: Date? {
        guard hasDate else { return nil }
        return hasTime ? date : Calendar.current.startOfDay(for: date)
    }

    init() {}

    init(dueDate: Date?, hasReminder: Bool, project: Project?) {
        self.hasDate = dueDate != nil
        self.date = dueDate ?? .now
        self.hasReminder = hasReminder
        self.project = project
    }

    init(item: TaskItem) {
        title = item.title
        notes = item.notes
        hasDate = item.dueDate != nil
        date = item.dueDate ?? .now
        hasTime = item.hasDueTime
        hasReminder = item.hasReminder
        reminderHasSound = item.reminderHasSound
        repeatRule = item.repeatRule
        project = item.project
        priority = item.priority
    }

    func makeTask() -> TaskItem {
        let item = TaskItem(title: trimmedTitle)
        apply(to: item)
        item.title = trimmedTitle
        return item
    }

    func apply(to item: TaskItem) {
        item.title = title
        item.notes = notes
        item.dueDate = dueDate
        item.hasDueTime = hasDate && hasTime
        item.hasReminder = hasReminder
        item.reminderHasSound = reminderHasSound
        item.repeatRule = hasDate ? repeatRule : nil
        item.project = project
        item.priority = priority
    }
}
