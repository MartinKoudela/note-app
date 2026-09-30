import SwiftUI
import SwiftData

enum ProjectColor: String, Codable, CaseIterable {
    case red, orange, yellow, green, blue, purple, pink, gray
    
    var color: Color {
        switch self {
        case .red: .red
        case .orange: .orange
        case .yellow: .yellow
        case .green: .green
        case .blue: .blue
        case .purple: .purple
        case .pink: .pink
        case .gray: .gray
        }
    }
}

@Model
final class Project {
    var name: String
    var color: ProjectColor
    var icon: String = "folder"
    var deadline: Date?
    var notes: String = ""
    var createdAt: Date = Date.now
    var isArchived: Bool = false
    var deletedAt: Date?
    var sortOrder: Int = 0
    
    @Relationship(deleteRule: .cascade, inverse: \TaskItem.project)
    var tasks: [TaskItem] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Page.project)
    var pages: [Page] = []
    
    init(name: String, color: ProjectColor = .blue, deadline: Date? = nil) {
        self.name = name
        self.color = color
        self.deadline = deadline
    }
}

extension Project {
    var rootPages: [Page] {
        pages
            .filter { $0.parent == nil && $0.deletedAt == nil && !$0.isArchived }
            .sorted { ($0.sortOrder, $0.createdAt) < ($1.sortOrder, $1.createdAt) }
    }
    
    var openTasks: [TaskItem] {
        tasks
            .filter { $0.deletedAt == nil && !$0.isArchived && !$0.isCompleted }
            .sorted { ($0.dueDate ?? .distantFuture, $0.createdAt) < ($1.dueDate ?? .distantFuture, $1.createdAt) }
    }
    
    var completedTasks: [TaskItem] {
        tasks
            .filter { $0.deletedAt == nil && !$0.isArchived && $0.isCompleted }
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }
    
    var nextPageSortOrder: Int {
        (pages.filter { $0.parent == nil }.map(\.sortOrder).max() ?? -1) + 1
    }
}
