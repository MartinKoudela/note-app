import SwiftUI

struct TaskListRow: View {
    let item: TaskItem
    var showsProject = true

    @Environment(\.startTaskSelection) private var startTaskSelection

    var body: some View {
        NavigationLink(value: item) {
            TaskRow(item: item, showsProject: showsProject)
        }
        .taskSwipeActions(item)
        .contextMenu {
            Button {
                withAnimation {
                    TaskActions.setCompleted([item], !item.isCompleted)
                }
            } label: {
                Label(item.isCompleted ? "Mark as Not Done" : "Complete",
                      systemImage: item.isCompleted ? "circle" : "checkmark.circle")
            }

            TaskActionMenus(items: [item])

            Divider()

            Button {
                withAnimation {
                    TaskActions.archive([item])
                }
            } label: {
                Label(MoreDestination.archive.title, systemImage: MoreDestination.archive.systemImage)
            }

            Button(role: .destructive) {
                withAnimation {
                    TaskActions.delete([item])
                }
            } label: {
                Label("Delete", systemImage: MoreDestination.bin.systemImage)
            }

            if let startTaskSelection {
                Divider()

                Button {
                    withAnimation(.snappy) {
                        startTaskSelection(item)
                    }
                } label: {
                    Label("Select", systemImage: "checkmark.circle")
                }
            }
        }
        .listSectionSeparator(.hidden)
    }
}
