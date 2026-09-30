import SwiftUI

struct DeadlineRow: View {
    let project: Project

    private var dueText: String {
        guard let deadline = project.deadline else { return "" }
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: .now),
            to: calendar.startOfDay(for: deadline)
        ).day ?? 0

        switch days {
        case 0: return "Today"
        case 1: return "Tomorrow"
        default: return "\(deadline.formatted(.dateTime.weekday(.wide))) • \(days) days"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: project.icon)
                .font(.footnote)
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(project.color.color, in: .circle)

            Text(project.name)

            Spacer()

            Text(dueText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .listSectionSeparator(.hidden)
    }
}
