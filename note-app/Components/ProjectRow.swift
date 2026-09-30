import SwiftUI

struct ProjectRow: View {
    let project: Project

    private var openCount: Int {
        project.openTasks.count
    }

    private var pageCount: Int {
        project.pages.filter { $0.deletedAt == nil }.count
    }

    private var details: String {
        var parts: [String] = []
        if let deadline = project.deadline {
            parts.append("Due \(deadline.dayMonth)")
        }
        if pageCount > 0 {
            parts.append(pageCount == 1 ? "1 page" : "\(pageCount) pages")
        }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        HStack(spacing: 12) {
            ProjectIcon(icon: project.icon, color: project.color, size: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)

                if !details.isEmpty {
                    Text(details)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }

            Spacer()

            if openCount > 0 {
                Text("\(openCount)")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}
