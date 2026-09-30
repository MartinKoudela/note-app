import Foundation

struct RepeatRule: Codable, Hashable {
    enum Frequency: String, Codable, CaseIterable, Identifiable {
        case daily, weekly, monthly, yearly

        var id: Self { self }

        var title: String {
            switch self {
            case .daily: "Daily"
            case .weekly: "Weekly"
            case .monthly: "Monthly"
            case .yearly: "Yearly"
            }
        }

        func unit(_ count: Int) -> String {
            switch self {
            case .daily: count == 1 ? "day" : "days"
            case .weekly: count == 1 ? "week" : "weeks"
            case .monthly: count == 1 ? "month" : "months"
            case .yearly: count == 1 ? "year" : "years"
            }
        }

        fileprivate var component: Calendar.Component {
            switch self {
            case .daily: .day
            case .weekly: .weekOfYear
            case .monthly: .month
            case .yearly: .year
            }
        }
    }

    var frequency: Frequency
    var interval: Int = 1
    var weekdays: [Int] = []
    var endDate: Date?

    static let everyDay = RepeatRule(frequency: .daily)
    static let everyWeekday = RepeatRule(frequency: .weekly, weekdays: [2, 3, 4, 5, 6])
    static let everyWeek = RepeatRule(frequency: .weekly)
    static let everyTwoWeeks = RepeatRule(frequency: .weekly, interval: 2)
    static let everyMonth = RepeatRule(frequency: .monthly)
    static let everyYear = RepeatRule(frequency: .yearly)

    static let presets: [(title: String, rule: RepeatRule)] = [
        ("Every Day", .everyDay),
        ("Every Weekday", .everyWeekday),
        ("Every Week", .everyWeek),
        ("Every 2 Weeks", .everyTwoWeeks),
        ("Every Month", .everyMonth),
        ("Every Year", .everyYear)
    ]

    func matches(_ other: RepeatRule) -> Bool {
        frequency == other.frequency && interval == other.interval && Set(weekdays) == Set(other.weekdays)
    }

    var summary: String {
        var text: String

        if frequency == .weekly && interval == 1 && Set(weekdays) == Set(Self.everyWeekday.weekdays) {
            text = "Every Weekday"
        } else {
            text = interval == 1 ? "Every \(frequency.unit(1).capitalized)" : "Every \(interval) \(frequency.unit(interval).capitalized)"

            if frequency == .weekly && !weekdays.isEmpty {
                let symbols = Calendar.current.shortWeekdaySymbols
                let names = Self.orderedWeekdays
                    .filter(weekdays.contains)
                    .map { symbols[$0 - 1] }
                text += " on " + names.joined(separator: ", ")
            }
        }

        if let endDate {
            text += " until \(endDate.dayMonth)"
        }
        return text
    }

    static var orderedWeekdays: [Int] {
        let first = Calendar.current.firstWeekday
        return (0..<7).map { (first - 1 + $0) % 7 + 1 }
    }

    func nextDate(after date: Date) -> Date? {
        let calendar = Calendar.current
        let next: Date?

        if frequency == .weekly && !weekdays.isEmpty {
            next = nextWeekdayDate(after: date, calendar: calendar)
        } else {
            next = calendar.date(byAdding: frequency.component, value: max(interval, 1), to: date)
        }

        guard let next else { return nil }

        if let endDate, calendar.startOfDay(for: next) > calendar.startOfDay(for: endDate) {
            return nil
        }
        return next
    }

    func nextDate(afterCompleting date: Date) -> Date? {
        let startOfToday = Calendar.current.startOfDay(for: .now)
        var candidate = nextDate(after: date)
        var steps = 0

        while let current = candidate, current < startOfToday, steps < 1_000 {
            candidate = nextDate(after: current)
            steps += 1
        }
        return candidate
    }

    private func nextWeekdayDate(after date: Date, calendar: Calendar) -> Date? {
        let selected = Set(weekdays)

        for offset in 1..<7 {
            guard let candidate = calendar.date(byAdding: .day, value: offset, to: date) else { continue }
            guard calendar.isDate(candidate, equalTo: date, toGranularity: .weekOfYear) else { break }
            if selected.contains(calendar.component(.weekday, from: candidate)) {
                return candidate
            }
        }

        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start,
              let targetWeekStart = calendar.date(byAdding: .weekOfYear, value: max(interval, 1), to: weekStart)
        else { return nil }

        let time = calendar.dateComponents([.hour, .minute, .second], from: date)

        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: targetWeekStart) else { continue }
            if selected.contains(calendar.component(.weekday, from: day)) {
                return calendar.date(
                    bySettingHour: time.hour ?? 0,
                    minute: time.minute ?? 0,
                    second: time.second ?? 0,
                    of: day
                )
            }
        }
        return nil
    }
}
