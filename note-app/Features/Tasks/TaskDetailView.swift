import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Bindable var item: TaskItem

    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Project.name) private var projects: [Project]
    
    @State private var originalTitle = ""
    
    @AppStorage(ReminderDefaults.timeKey) private var defaultReminderMinutes = ReminderDefaults.defaultMinutes
    
    private var reminderState: String {
        "\(item.title)|\(String(describing: item.dueDate))|\(item.hasDueTime)|\(item.hasReminder)|\(item.reminderHasSound)|\(item.isCompleted)"
    }

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
                item.hasReminder = false
                item.repeatRule = nil
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
                    .lineLimit(3...)
            }

            Section {
                Toggle("Date", isOn: hasDate.animation())
                if item.dueDate != nil {
                    DatePicker("Date", selection: date, displayedComponents: .date)

                    Toggle("Time", isOn: $item.hasDueTime.animation())
                    if item.hasDueTime {
                        DatePicker("Time", selection: date, displayedComponents: .hourAndMinute)
                    }
                    
                    NavigationLink {
                        RepeatPickerView(rule: $item.repeatRule)
                    } label: {
                        LabeledContent("Repeat", value: item.repeatRule?.summary ?? "Never")
                    }
                }

                Toggle("Remind me", isOn: $item.hasReminder.animation())
                if item.hasReminder {
                    Toggle("Sound", isOn: $item.reminderHasSound)
                    NotificationPermissionNotice()
                }
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
                }
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            originalTitle = item.title
        }
        .onDisappear {
            if item.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                item.title = originalTitle.isEmpty ? "Untitled" : originalTitle
            }
        }
        .onChange(of: item.isCompleted) {
            TaskCompletion.didChange(item)
        }
        .onChange(of: item.hasDueTime) { _, on in
            if on {
                if let dueDate = item.dueDate, dueDate == Calendar.current.startOfDay(for: dueDate) {
                    item.dueDate = ReminderDefaults.date(on: dueDate, minutes: defaultReminderMinutes)
                }
                item.hasReminder = true
            } else {
                item.hasReminder = false
                if let dueDate = item.dueDate {
                    item.dueDate = Calendar.current.startOfDay(for: dueDate)
                }
            }
        }
        .onChange(of: item.hasReminder) { _, on in
            if on {
                applyReminderDefaults()
                Task { await NotificationService.requestAuthorization() }
            }
        }
        .onChange(of: reminderState) {
            NotificationService.update(for: item)
        }
    }
}

extension TaskDetailView {
    private func applyReminderDefaults() {
        withAnimation {
            if let dueDate = item.dueDate {
                if !item.hasDueTime {
                    item.dueDate = ReminderDefaults.date(on: dueDate, minutes: defaultReminderMinutes)
                }
            } else {
                item.dueDate = ReminderDefaults.nextDate(minutes: defaultReminderMinutes)
            }
            item.hasDueTime = true
        }
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(item: TaskItem(title: "Publish", dueDate: .now, hasDueTime: true, priority: .low))
    }
    .modelContainer(for: [Project.self, TaskItem.self], inMemory: true)
}
