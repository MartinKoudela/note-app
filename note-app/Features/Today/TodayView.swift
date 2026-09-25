import SwiftUI

struct TodayView: View {
    private let taskCount = 3
    private let completedCount = 2
    
    private var subtitle: String {
        let date = Date.now.formatted(.dateTime.day().month(.wide))
        
        if taskCount == 0 {
            return "\(date) • No tasks"
        }
        
        let word = taskCount == 1 ? "task" : "tasks"
        return "\(date) • \(taskCount) \(word)"
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if taskCount == 0 {
                    ContentUnavailableView {
                        Label("No Tasks Today", systemImage: AppTab.today.systemImage)
                    } description: {
                        Text("Tasks due today will appear here.")
                    } actions: {
                        Button("Add Task") {
                            print("add")
                        }
                        .buttonStyle(.glassProminent)
                    }
                } else if completedCount == taskCount {
                    ContentUnavailableView(
                        "All Done",
                        systemImage: "checkmark.circle",
                        description: Text("You've completed all tasks for today.")
                    )
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        ProgressView(value: Double(completedCount), total: Double(taskCount)) {
                            Text("\(completedCount) of \(taskCount) done")
                        }
                        Text("Tasks list")
                    }
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .navigationTitle(Date.now.formatted(.dateTime.weekday(.wide)).capitalized)
            .navigationSubtitle(subtitle)
            .appToolbar()
        }
    }
}

#Preview {
    TodayView()
}
