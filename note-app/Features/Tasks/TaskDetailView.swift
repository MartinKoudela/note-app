import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Bindable var item: TaskItem

    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Project.sortOrder) private var projects: [Project]

    @State private var draft: TaskDraft
    @State private var originalTitle: String

    private var availableProjects: [Project] {
        projects.filter { ($0.deletedAt == nil && !$0.isArchived) || $0 == item.project }
    }

    init(item: TaskItem) {
        _item = Bindable(item)
        _draft = State(initialValue: TaskDraft(item: item))
        _originalTitle = State(initialValue: item.title)
    }

    var body: some View {
        TaskForm(draft: $draft, projects: availableProjects) {
            Section {
                Toggle(isOn: $item.isCompleted.animation()) {
                    FormRowLabel(
                        title: "Completed",
                        value: item.completedAt.map { "Completed \($0.formatted(.relative(presentation: .named)))" },
                        systemImage: "checkmark",
                        color: .green
                    )
                }
            }

            Section {
                Button {
                    item.isArchived = true
                    NotificationService.cancel(for: item)
                    dismiss()
                } label: {
                    Label(MoreDestination.archive.title, systemImage: MoreDestination.archive.systemImage)
                }

                Button(role: .destructive) {
                    item.deletedAt = .now
                    NotificationService.cancel(for: item)
                    dismiss()
                } label: {
                    Label("Delete Task", systemImage: MoreDestination.bin.systemImage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: draft) {
            draft.apply(to: item)
            NotificationService.update(for: item)
        }
        .onChange(of: item.isCompleted) {
            TaskCompletion.didChange(item)
        }
        .onDisappear {
            if item.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                item.title = originalTitle.isEmpty ? "Untitled" : originalTitle
            }
        }
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(item: TaskItem(title: "Publish", dueDate: .now, hasDueTime: true, priority: .low))
    }
    .modelContainer(for: [Project.self, TaskItem.self, Page.self], inMemory: true)
}
