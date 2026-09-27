import SwiftUI

struct TodayView: View {
    
    private let items: [TaskItem] = []
    
    private var todayItems: [TaskItem] {
        items.filter { Calendar.current.isDateInToday($0.dueDate ?? .distantPast) }
    }
    
    private var taskCount: Int {
        todayItems.count
    }
    
    private var completedCount: Int {
        todayItems.filter(\.isCompleted).count
    }
    
    @State private var activeAdd: AddAction?
    
    var body: some View {
        NavigationStack {
            Group {
                if taskCount == 0 {
                    ContentUnavailableView {
                        Label("No Tasks Today", systemImage: AppTab.today.systemImage)
                    } description: {
                        Text("Tasks due today will appear here.")
                    } actions: {
                        Button("Add Task") { activeAdd = .todayTask }
                            .buttonStyle(.glassProminent)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            ProgressView(value: Double(completedCount), total: Double(taskCount))
                            
                            Text("\(completedCount) of \(taskCount) done")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        .accessibilityElement(children: .combine) // voiceover
                        
                        if completedCount == taskCount {
                            Label("All done", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.secondary)
                        } else {
                            List(todayItems) { item in
                                TaskRow(item: item)
                            }
                            .listStyle(.plain)
                        }
                    }
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .navigationTitle(Date.now.formatted(.dateTime.weekday(.wide)).capitalized)
            .navigationSubtitle(Date.now.formatted(.dateTime.day().month(.wide)))
            .appToolbar(primary: .todayTask)
            .sheet(item: $activeAdd) { AddSheet(action: $0) }
        }
    }
}

#Preview {
    TodayView()
}
