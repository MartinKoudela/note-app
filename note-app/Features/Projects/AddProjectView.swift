import SwiftUI
import SwiftData

struct AddProjectView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var projects: [Project]

    @State private var name = ""
    @State private var notes = ""
    @State private var color = ProjectColor.blue
    @State private var icon = "folder"
    @State private var hasDeadline: Bool
    @State private var deadline: Date

    init(deadline: Date? = nil) {
        _hasDeadline = State(initialValue: deadline != nil)
        _deadline = State(initialValue: deadline ?? .now)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ProjectIcon(icon: icon, color: color, size: 80)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                }

                Section {
                    TextField("Name", text: $name)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Color") {
                    ProjectColorPicker(selection: $color)
                }

                Section("Icon") {
                    ProjectIconPicker(selection: $icon, color: color)
                }

                Section {
                    Toggle("Deadline", isOn: $hasDeadline.animation())
                    if hasDeadline {
                        DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let project = Project(
            name: name.trimmingCharacters(in: .whitespaces),
            color: color,
            deadline: hasDeadline ? Calendar.current.startOfDay(for: deadline) : nil
        )
        project.icon = icon
        project.notes = notes
        project.sortOrder = (projects.map(\.sortOrder).max() ?? -1) + 1
        modelContext.insert(project)
        dismiss()
    }
}

#Preview {
    AddProjectView()
        .modelContainer(for: [Project.self, TaskItem.self, Page.self], inMemory: true)
}
