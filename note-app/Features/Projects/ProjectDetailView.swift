import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    @Bindable var item: TaskItem

    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Project.name) private var projects: [Project]

    private var availableProjects: [Project] {
        projects.filter { ($0.deletedAt == nil && !$0.isArchived) || $0 == item.project }
    }

    private var hasDate: Binding<Bool> {
        Binding {
            item.dueDate != nil
        } set: { on in
            item.dueDate = on ? Calendar.current.startOfDay(for: .now) : nil
            if !on {
                item.hasDueTime = false
            }
        }
    }

    private var date: Binding<Date> {
        Binding {
            item.dueDate ?? .now
        } set: { newValue in
            item.dueDate = newValue
        }
    }

    var body: some View {
        Form {
            Section {
                TextField("Title", text: $item.title)
                TextField("Notes", text: $item.notes, axis: .vertical)
                    .lineLimit(3...10)
            }

            Section {
                Toggle("Date", isOn: hasDate.animation())
                if item.dueDate != nil {
                    DatePicker("Date", selection: date, displayedComponents: .date)

                    Toggle("Time", isOn: $item.hasDueTime.animation())
                    if item.hasDueTime {
                        DatePicker("Time", selection: date, displayedComponents: .hourAndMinute)
                    }
                }

                Toggle("Remind me", isOn: $item.hasReminder)
            }

            Section {
                Picker("Project", selection: $item.project) {
                    Text("None").tag(nil as Project?)
                    ForEach(availableProjects) { project in
                        Text(project.name).tag(project as Project?)
                    }
                }

                Picker("Priority", selection: $item.priority) {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Text(priority.title).tag(priority)
                    }
                }
            }

            Section {
                Toggle("Completed", isOn: $item.isCompleted)
            }

            Section {
                Button {
                    item.isArchived = true
                    dismiss()
                } label: {
                    Label(MoreDestination.archive.title, systemImage: MoreDestination.archive.systemImage)
                }

                Button(role: .destructive) {
                    item.deletedAt = .now
                    dismiss()
                } label: {
                    Label("Delete Task", systemImage: MoreDestination.bin.systemImage)
                }
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: item.isCompleted) { _, done in
            item.completedAt = done ? .now : nil
        }
        .onChange(of: item.hasDueTime) { _, on in
            if on {
                item.hasReminder = true
            } else if let dueDate = item.dueDate {
                item.dueDate = Calendar.current.startOfDay(for: dueDate)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(item: TaskItem(title: "Publish", dueDate: .now, hasDueTime: true, priority: .low))
    }
    .modelContainer(for: [Project.self, TaskItem.self], inMemory: true)
}
