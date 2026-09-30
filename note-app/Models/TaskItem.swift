import Foundation
import SwiftData

enum Priority: Int, Codable, CaseIterable {
    case none, low, medium, high
    
    var marks: String {
        String(repeating: "!", count: rawValue)
    }

    var title: String {
        switch self {
        case .none: "None"
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        }
    }
}

@Model
final class TaskItem {
    var title: String
    var notes: String = ""
    var project: Project?
    var dueDate: Date?
    var hasDueTime: Bool = false
    var priority: Priority = Priority.none
    var hasReminder: Bool = false
    var reminderHasSound: Bool = true
    var reminderID: String = UUID().uuidString
    var isCompleted: Bool = false
    var completedAt: Date?
    var createdAt: Date = Date.now
    // var recurrence:
    // var subtasks:
    // var url: String = https://
    // var sortOrder: Int = 0
    var isArchived: Bool = false
    var deletedAt: Date?
    var repeatRule: RepeatRule?
    var nextOccurrenceID: String?
    
    init(title: String, project: Project? = nil, dueDate: Date? = nil, hasDueTime: Bool =
         false, priority: Priority = .none, hasReminder: Bool = false) {
        self.title = title
        self.project = project
        self.dueDate = dueDate
        self.hasDueTime = hasDueTime
        self.priority = priority
        self.hasReminder = hasReminder
    }
    
}

