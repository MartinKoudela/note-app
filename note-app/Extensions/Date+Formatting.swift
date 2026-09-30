import Foundation

extension Date {
    private static func formatter(template: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter
    }

    private static let dayMonthFormatter = formatter(template: "dMMM")
    private static let dayMonthWideFormatter = formatter(template: "dMMMM")
    private static let weekdayFormatter = formatter(template: "EEEE")
    private static let weekdayDayMonthFormatter = formatter(template: "EEEEdMMMM")

    var dayMonth: String {
        Self.dayMonthFormatter.string(from: self)
    }

    var dayMonthWide: String {
        Self.dayMonthWideFormatter.string(from: self)
    }

    var weekdayName: String {
        Self.weekdayFormatter.string(from: self).capitalized
    }

    var weekdayDayMonth: String {
        Self.weekdayDayMonthFormatter.string(from: self)
    }
}
