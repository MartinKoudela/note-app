import SwiftUI
import SwiftData

struct DeletedProject: View {
    let project: Project

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: project.icon)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(project.color.color, in: .circle)

            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)

                if let deletedAt = project.deletedAt {
                    Text("Deleted \(deletedAt.formatted(.relative(presentation: .named)))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                modelContext.delete(project)
            } label: {
                Label("Delete Permanently", systemImage: "trash.slash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                project.deletedAt = nil
            } label: {
                Label("Restore", systemImage: "arrow.uturn.backward")
            }
            .tint(.blue)
        }
    }
}
