import SwiftUI
import SwiftData

struct DeletedPage: View {
    let page: Page

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: page.systemImage)
                .foregroundStyle(page.project?.color.color ?? .accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(page.displayTitle)

                HStack(spacing: 4) {
                    if let project = page.project {
                        Text(project.name)
                        Text("·")
                    }
                    if let deletedAt = page.deletedAt {
                        Text("Deleted \(deletedAt.formatted(.relative(presentation: .named)))")
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                modelContext.delete(page)
            } label: {
                Label("Delete Permanently", systemImage: "trash.slash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                page.deletedAt = nil
            } label: {
                Label("Restore", systemImage: "arrow.uturn.backward")
            }
            .tint(.blue)
        }
    }
}
