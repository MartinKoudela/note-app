import SwiftUI

struct ProjectRow: View {
    let project: Project

    private var openCount: Int {
        project.tasks.filter { !$0.isCompleted }.count
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: project.icon)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(project.color.color, in: .circle)

            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)

                if let deadline = project.deadline {
                    Text(deadline.formatted(.dateTime.day().month()))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text("\(openCount)")
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}
