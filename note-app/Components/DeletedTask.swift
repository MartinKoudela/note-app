import SwiftUI
import SwiftData

struct DeletedTask: View {
    let item: TaskItem

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.title)

            if let deletedAt = item.deletedAt {
                Text("Deleted \(deletedAt.formatted(.relative(presentation: .named)))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                modelContext.delete(item)
            } label: {
                Label("Delete Permanently", systemImage: "trash.slash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                item.deletedAt = nil
            } label: {
                Label("Restore", systemImage: "arrow.uturn.backward")
            }
            .tint(.blue)
        }
    }
}
