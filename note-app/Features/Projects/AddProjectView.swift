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

    private let icons = [
        "folder", "briefcase", "book", "graduationcap",
        "house", "cart", "heart", "star",
        "flag", "paintbrush", "hammer", "laptopcomputer"
    ]

    private let columns = [GridItem(.adaptive(minimum: 44))]

    init(deadline: Date? = nil) {
        _hasDeadline = State(initialValue: deadline != nil)
        _deadline = State(initialValue: deadline ?? .now)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Image(systemName: icon)
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .frame(width: 80, height: 80)
                        .background(color.color, in: .circle)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                        .accessibilityHidden(true)
                }

                Section {
                    TextField("Name", text: $name)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Color") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(ProjectColor.allCases, id: \.self) { option in
                            Button {
                                color = option
                            } label: {
                                Circle()
                                    .fill(option.color)
                                    .frame(width: 32, height: 32)
                                    .padding(4)
                                    .overlay {
                                        if option == color {
                                            Circle().stroke(.secondary, lineWidth: 2)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(option.rawValue.capitalized)
                            .accessibilityAddTraits(option == color ? .isSelected : [])
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Icon") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(icons, id: \.self) { option in
                            Button {
                                icon = option
                            } label: {
                                Image(systemName: option)
                                    .font(.title3)
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(option == icon ? .white : .primary)
                                    .background(option == icon ? color.color : Color.secondary.opacity(0.15), in: .circle)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(option)
                            .accessibilityAddTraits(option == icon ? .isSelected : [])
                        }
                    }
                    .padding(.vertical, 4)
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
        .modelContainer(for: [Project.self, TaskItem.self], inMemory: true)
}
