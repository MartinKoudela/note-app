import SwiftUI

struct TaskForm<Footer: View>: View {
    @Binding var draft: TaskDraft
    let projects: [Project]
    var focusTitleOnAppear = false
    var onSubmitTitle: (() -> Void)?
    var onPickerExpanded: (Bool) -> Void = { _ in }
    @ViewBuilder var footer: () -> Footer

    @AppStorage(ReminderDefaults.timeKey) private var defaultReminderMinutes = ReminderDefaults.defaultMinutes

    @FocusState private var focusedField: Field?
    @State private var expandedPicker: Picker?

    private enum Field {
        case title, notes
    }

    private enum Picker {
        case date, time
    }

    private var dateText: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(draft.date) { return "Today" }
        if calendar.isDateInTomorrow(draft.date) { return "Tomorrow" }
        if calendar.isDateInYesterday(draft.date) { return "Yesterday" }
        return draft.date.weekdayDayMonth
    }

    private var timeText: String {
        draft.date.formatted(date: .omitted, time: .shortened)
    }

    var body: some View {
        Form {
            Section {
                TextField("Title", text: $draft.title, axis: .vertical)
                    .font(.title3.weight(.semibold))
                    .focused($focusedField, equals: .title)
                    .submitLabel(.done)
                    .onSubmit { onSubmitTitle?() }
                    .onChange(of: draft.title) { _, title in
                        guard title.contains("\n") else { return }
                        draft.title = title.replacingOccurrences(of: "\n", with: "")
                        onSubmitTitle?()
                    }

                TextField("Notes", text: $draft.notes, axis: .vertical)
                    .focused($focusedField, equals: .notes)
                    .foregroundStyle(.secondary)
                    .lineLimit(1...)
            }

            Section {
                Toggle(isOn: $draft.hasDate.animation()) {
                    FormRowLabel(title: "Date", value: draft.hasDate ? dateText : nil, systemImage: "calendar", color: .red)
                        .contentShape(.rect)
                        .onTapGesture { toggle(.date) }
                }

                if draft.hasDate && expandedPicker == .date {
                    DatePicker("Date", selection: $draft.date, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                }

                if draft.hasDate {
                    Toggle(isOn: $draft.hasTime.animation()) {
                        FormRowLabel(title: "Time", value: draft.hasTime ? timeText : nil, systemImage: "clock.fill", color: .blue)
                            .contentShape(.rect)
                            .onTapGesture { toggle(.time) }
                    }

                    if draft.hasTime && expandedPicker == .time {
                        DatePicker("Time", selection: $draft.date, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                    }

                    NavigationLink {
                        RepeatPickerView(rule: $draft.repeatRule)
                    } label: {
                        LabeledContent {
                            Text(draft.repeatRule?.summary ?? "Never")
                        } label: {
                            FormRowLabel(title: "Repeat", systemImage: "repeat", color: .gray)
                        }
                    }
                }
            }

            Section {
                SwiftUI.Picker(selection: $draft.reminderMode.animation()) {
                    Text("Off").tag(TaskDraft.ReminderMode.off)
                    Label("With Sound", systemImage: "bell").tag(TaskDraft.ReminderMode.sound)
                    Label("Silent", systemImage: "bell.slash").tag(TaskDraft.ReminderMode.silent)
                } label: {
                    FormRowLabel(title: "Reminder", systemImage: "bell.fill", color: .orange)
                }
                .pickerStyle(.menu)

                if draft.hasReminder {
                    NotificationPermissionNotice()
                }
            }

            Section {
                SwiftUI.Picker(selection: $draft.project) {
                    Label("None", systemImage: "tray").tag(nil as Project?)
                    ForEach(projects) { project in
                        Label(project.name, systemImage: project.icon).tag(project as Project?)
                    }
                } label: {
                    FormRowLabel(
                        title: "Project",
                        systemImage: draft.project?.icon ?? "tray.fill",
                        color: draft.project?.color.color ?? .gray
                    )
                }
                .pickerStyle(.menu)

                LabeledContent {
                    SwiftUI.Picker("Priority", selection: $draft.priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority == .none ? "None" : priority.marks)
                                .accessibilityLabel(priority.title)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(maxWidth: 190)
                } label: {
                    FormRowLabel(title: "Priority", systemImage: "exclamationmark", color: .pink)
                }
            }

            footer()
        }
        .onAppear {
            if focusTitleOnAppear {
                focusedField = .title
            }
            if draft.hasReminder {
                applyReminderDefaults()
            }
        }
        .onChange(of: draft.hasDate) { _, on in
            if on {
                if !draft.hasTime {
                    draft.date = Calendar.current.startOfDay(for: draft.date)
                }
                expand(.date)
            } else {
                draft.hasTime = false
                draft.hasReminder = false
                draft.repeatRule = nil
                expand(nil)
            }
        }
        .onChange(of: draft.hasTime) { _, on in
            if on {
                if draft.date == Calendar.current.startOfDay(for: draft.date) {
                    draft.date = ReminderDefaults.date(on: draft.date, minutes: defaultReminderMinutes)
                }
                draft.hasReminder = true
                expand(.time)
            } else {
                draft.hasReminder = false
                draft.date = Calendar.current.startOfDay(for: draft.date)
                if expandedPicker == .time {
                    expand(nil)
                }
            }
        }
        .onChange(of: draft.hasReminder) { _, on in
            if on {
                applyReminderDefaults()
                Task { await NotificationService.requestAuthorization() }
            }
        }
    }

    private func toggle(_ picker: Picker) {
        expand(expandedPicker == picker ? nil : picker)
    }

    private func expand(_ picker: Picker?) {
        withAnimation(.snappy) {
            expandedPicker = picker
        }
        if picker != nil {
            focusedField = nil
        }
        onPickerExpanded(picker != nil)
    }

    private func applyReminderDefaults() {
        withAnimation {
            if !draft.hasDate {
                draft.date = ReminderDefaults.nextDate(minutes: defaultReminderMinutes)
                draft.hasDate = true
            } else if !draft.hasTime {
                draft.date = ReminderDefaults.date(on: draft.date, minutes: defaultReminderMinutes)
            }
            draft.hasTime = true
        }
    }
}

extension TaskForm where Footer == EmptyView {
    init(
        draft: Binding<TaskDraft>,
        projects: [Project],
        focusTitleOnAppear: Bool = false,
        onSubmitTitle: (() -> Void)? = nil,
        onPickerExpanded: @escaping (Bool) -> Void = { _ in }
    ) {
        self.init(
            draft: draft,
            projects: projects,
            focusTitleOnAppear: focusTitleOnAppear,
            onSubmitTitle: onSubmitTitle,
            onPickerExpanded: onPickerExpanded,
            footer: { EmptyView() }
        )
    }
}
