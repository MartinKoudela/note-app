import SwiftUI

struct PageRow: View {
    let page: Page
    var showsProject = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: page.systemImage)
                .font(.body)
                .foregroundStyle(page.project?.color.color ?? .accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(page.displayTitle)
                    .foregroundStyle(page.title.isEmpty ? .secondary : .primary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    if showsProject, let project = page.project {
                        Text(project.name)
                        Text("·")
                    }

                    Text("Edited \(page.updatedAt.formatted(.relative(presentation: .named)))")

                    if let progress = page.checklistProgress {
                        Text("·")
                        Label("\(progress.done)/\(progress.total)", systemImage: "checklist")
                            .labelStyle(.titleAndIcon)
                    }

                    if !page.activeChildren.isEmpty {
                        Text("·")
                        Text(page.activeChildren.count == 1 ? "1 page" : "\(page.activeChildren.count) pages")
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .monospacedDigit()
            }
        }
    }
}
