import SwiftUI
import SwiftData

struct AddTaskView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Project.name) private var projects: [Project]

    @State private var title = ""
    @State private var notes = ""
    @State private var project: Project?
    @State private var hasDate: Bool
    @State private var date: Date
    @State private var hasDueTime = false
    @State private var priority = Priority.none
    @State private var hasReminder: Bool

    init(dueDate: Date? = nil, hasReminder: Bool = false, project: Project? = nil) {
        _hasDate = State(initialValue: dueDate != nil)
        _date = State(initialValue: dueDate ?? .now)
        _hasReminder = State(initialValue: hasReminder)
        _project = State(initialValue: project)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Toggle("Date", isOn: $hasDate.animation())
                    if hasDate {
                        DatePicker("Date", selection: $date, displayedComponents: .date)

                        Toggle("Time", isOn: $hasDueTime.animation())
                        if hasDueTime {
                            DatePicker("Time", selection: $date, displayedComponents: .hourAndMinute)
                        }
                    }

                    Toggle("Remind me", isOn: $hasReminder)
                }

                Section {
                    Picker("Project", selection: $project) {
                        Text("None").tag(nil as Project?)
                        ForEach(projects) { project in
                            Text(project.name).tag(project as Project?)
                        }
                    }

                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.title).tag(priority)
                        }
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: hasDueTime) { _, on in
                if on {
                    hasReminder = true
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        save()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let dueDate: Date? = if hasDate {
            hasDueTime ? date : Calendar.current.startOfDay(for: date)
        } else {
            nil
        }

        let item = TaskItem(
            title: title.trimmingCharacters(in: .whitespaces),
            project: project,
            dueDate: dueDate,
            hasDueTime: hasDate && hasDueTime,
            priority: priority,
            hasReminder: hasReminder
        )
        item.notes = notes
        modelContext.insert(item)
        dismiss()
    }
}

#Preview {
    AddTaskView()
        .modelContainer(for: [Project.self, TaskItem.self], inMemory: true)
}
