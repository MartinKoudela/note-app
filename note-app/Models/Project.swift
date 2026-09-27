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
    var sortOrder: Int = 0
    
    @Relationship(deleteRule: .cascade, inverse: \TaskItem.project)
    var tasks: [TaskItem] = []
    
    init(name: String, color: ProjectColor = .blue, deadline: Date? = nil) {
        self.name = name
        self.color = color
        self.deadline = deadline
    }
}
