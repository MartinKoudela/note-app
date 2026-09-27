import SwiftUI

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


struct Project: Identifiable {
    let id = UUID()
    var name: String
    var color: ProjectColor
    var icon: String = "folder"
    var deadline: Date?
    var notes: String = ""
    var tasks: [TaskItem] = []
    var createdAt: Date = .now
    var isArchived: Bool = false
    var sortOrder: Int = 0
}
