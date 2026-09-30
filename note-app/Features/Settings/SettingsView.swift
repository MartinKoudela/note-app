import SwiftUI

struct SettingsView: View {

    @Environment(\.dismiss) private var dismiss

    @AppStorage(ReminderDefaults.timeKey) private var defaultReminderMinutes = ReminderDefaults.defaultMinutes

    private var defaultReminderTime: Binding<Date> {
        Binding {
            ReminderDefaults.date(on: .now, minutes: defaultReminderMinutes)
        } set: { newValue in
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            defaultReminderMinutes = (components.hour ?? 9) * 60 + (components.minute ?? 0)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Default Reminder Time", selection: defaultReminderTime, displayedComponents: .hourAndMinute)
                    NotificationPermissionNotice()
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Used when you turn on a reminder for a task without a time.")
                }
            }
            .navigationTitle(MoreDestination.settings.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
