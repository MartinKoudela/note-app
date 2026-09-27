import SwiftUI
enum AddAction: Identifiable {
    case task
    case todayTask
    case reminder
    case project
    
    var id: Self { self }
}

struct AddSheet: View {
    let action: AddAction
    
    var body: some View {
        switch action {
        case .task:
            AddTaskView()
        case .todayTask:
            AddTaskView(dueDate: Calendar.current.startOfDay(for: .now))
        case .reminder:
            AddTaskView(hasReminder: true)
        case .project:
            AddProjectView()
        }
    }
}

