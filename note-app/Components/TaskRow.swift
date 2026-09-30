import SwiftUI

struct TaskRow: View {
    @Bindable var item: TaskItem
    
    private var isOverdue: Bool {
        guard let date = item.dueDate, !item.isCompleted else { return false }
        return date < Calendar.current.startOfDay(for: .now)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Toggle("Done", isOn: $item.isCompleted)
                .toggleStyle(CircleCheckStyle(tint: item.project?.color.color ??
                    .accentColor))
                .labelsHidden()
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 2) {
                        if item.priority != .none {
                            Text(item.priority.marks)
                                .foregroundStyle(.red)
                        }
                        Text(item.title)
                    }
                    .foregroundStyle(item.isCompleted ? .secondary : .primary)
                    
                    subtitle
                        .font(.footnote)
                        .foregroundStyle(isOverdue ? .red : .secondary)
                }
            }
            .onChange(of: item.isCompleted) { _, done in
                item.completedAt = done ? .now : nil
            }
        }
    
    @ViewBuilder
    private var subtitle: some View {
        HStack(spacing: 4) {
            if let project = item.project {
                Text(project.name)
            }

            if let date = item.dueDate {
                if item.project != nil {
                    Text("•")
                }

                if isOverdue {
                    Text(date.formatted(.relative(presentation: .named)))
                } else if item.hasDueTime {
                    Label(date.formatted(date: .omitted, time: .shortened),
                          systemImage: item.hasReminder ? "bell" : "bell.slash")
                    .labelStyle(.titleAndIcon)
                } else {
                    Text(date.formatted(.dateTime.day().month()))
                }
            }
        }
    }
}

