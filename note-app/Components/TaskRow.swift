import SwiftUI

struct TaskRow: View {
    @Bindable var item: TaskItem
    var showsProject = true
    
    private var notesPreview: String {
        item.notes
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Toggle("Done", isOn: $item.isCompleted)
                .toggleStyle(CircleCheckStyle(tint: item.project?.color.color ?? .accentColor))
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
                
                if !notesPreview.isEmpty {
                    Text(notesPreview)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }

                subtitle
                    .font(.footnote)
                    .foregroundStyle(item.isOverdue ? .red : .secondary)
            }
        }
        .onChange(of: item.isCompleted) { _, done in
            item.completedAt = done ? .now : nil
            NotificationService.update(for: item)
        }
    }

    @ViewBuilder
    private var subtitle: some View {
        let project = showsProject ? item.project : nil

        HStack(spacing: 4) {
            if let project {
                Text(project.name)
            }

            if let date = item.dueDate {
                if project != nil {
                    Text("•")
                }

                if item.isOverdue {
                    Text(date.formatted(.relative(presentation: .named)))
                } else if item.hasDueTime {
                    Text(date.formatted(date: .omitted, time: .shortened))
                } else {
                    Text(date.formatted(.dateTime.day().month()))
                }
            }
            
            if item.hasReminder {
                Image(systemName: item.reminderHasSound ? "bell" : "bell.slash")
                    .accessibilityLabel(item.reminderHasSound ? "Reminder" : "Silent reminder")
            }
        }
    }
}
