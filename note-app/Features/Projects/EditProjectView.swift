import SwiftUI
import SwiftData

struct EditProjectView: View {
    @Bindable var project: Project

    @Environment(\.dismiss) private var dismiss

    @State private var originalName = ""

    private var hasDeadline: Binding<Bool> {
        Binding {
            project.deadline != nil
        } set: { on in
            project.deadline = on ? Calendar.current.startOfDay(for: .now) : nil
        }
    }

    private var deadline: Binding<Date> {
        Binding {
            project.deadline ?? .now
        } set: { newValue in
            project.deadline = Calendar.current.startOfDay(for: newValue)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ProjectIcon(icon: project.icon, color: project.color, size: 80)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                }

                Section {
                    TextField("Name", text: $project.name)
                    TextField("Notes", text: $project.notes, axis: .vertical)
                        .lineLimit(3...)
                }

                Section("Color") {
                    ProjectColorPicker(selection: $project.color)
                }

                Section("Icon") {
                    ProjectIconPicker(selection: $project.icon, color: project.color)
                }

                Section {
                    Toggle("Deadline", isOn: hasDeadline.animation())
                    if project.deadline != nil {
                        DatePicker("Deadline", selection: deadline, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Edit Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) { dismiss() }
                }
            }
            .onAppear {
                originalName = project.name
            }
            .onDisappear {
                if project.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    project.name = originalName
                }
            }
        }
    }
}

#Preview {
    EditProjectView(project: Project(name: "Client website", color: .yellow))
        .modelContainer(for: [Project.self, TaskItem.self, Page.self], inMemory: true)
}
