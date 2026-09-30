import Foundation

enum ReminderDefaults {
    static let timeKey = "defaultReminderMinutes"
    static let defaultMinutes = 9 * 60

    static func date(on day: Date, minutes: Int) -> Date {
        Calendar.current.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: day) ?? day
    }

    static func nextDate(minutes: Int) -> Date {
        let today = date(on: .now, minutes: minutes)
        guard today < .now else { return today }
        return Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
    }
}
