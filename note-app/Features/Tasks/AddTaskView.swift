import SwiftUI
import SwiftData

struct AddTaskView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Project.sortOrder) private var projects: [Project]

    @State private var draft: TaskDraft
    @State private var detent: PresentationDetent = .medium

    private var activeProjects: [Project] {
        projects.filter { $0.deletedAt == nil && !$0.isArchived }
    }

    init(dueDate: Date? = nil, hasReminder: Bool = false, project: Project? = nil) {
        _draft = State(initialValue: TaskDraft(dueDate: dueDate, hasReminder: hasReminder, project: project))
    }

    var body: some View {
        NavigationStack {
            TaskForm(
                draft: $draft,
                projects: activeProjects,
                focusTitleOnAppear: true,
                onSubmitTitle: save,
                onPickerExpanded: { expanded in
                    if expanded {
                        withAnimation {
                            detent = .large
                        }
                    }
                }
            )
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        save()
                    }
                    .disabled(draft.trimmedTitle.isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large], selection: $detent)
        .presentationDragIndicator(.visible)
    }

    private func save() {
        guard !draft.trimmedTitle.isEmpty else { return }
        let item = draft.makeTask()
        modelContext.insert(item)
        NotificationService.update(for: item)
        dismiss()
    }
}

#Preview {
    AddTaskView()
        .modelContainer(for: [Project.self, TaskItem.self, Page.self], inMemory: true)
}
