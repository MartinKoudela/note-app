import Foundation

struct TaskItem: Identifiable {
    let id = UUID()
    var title: String
    var notes: String = ""
    var project: Project?
    var dueDate: Date?
    var hasDueTime: Bool
    var priority: Int = 0
    var hasReminder: Bool = false
    var isCompleted: Bool = false
    var completedAt: Date?
    var createdAt: Date = .now
    // var recurrence:
    // var subtasks:
    // var url: String = https://
    // var sortOrder: Int = 0
    
}

