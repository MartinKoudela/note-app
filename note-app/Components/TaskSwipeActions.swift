import SwiftUI

struct TaskSwipeActions: ViewModifier {
    let item: TaskItem

    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    item.deletedAt = .now
                    NotificationService.cancel(for: item)
                } label: {
                    Label(MoreDestination.bin.title, systemImage: MoreDestination.bin.systemImage)
                }

                Button {
                    item.isArchived = true
                    NotificationService.cancel(for: item)
                } label: {
                    Label(MoreDestination.archive.title, systemImage: MoreDestination.archive.systemImage)
                }
                .tint(.indigo)
            }
            .swipeActions(edge: .leading) {
                Button {
                    item.isCompleted.toggle()
                } label: {
                    Label(item.isCompleted ? "Undo" : "Done",
                          systemImage: item.isCompleted ? "arrow.uturn.backward" : "checkmark")
                }
                .tint(.green)
            }
    }
}

extension View {
    func taskSwipeActions(_ item: TaskItem) -> some View {
        modifier(TaskSwipeActions(item: item))
    }
}
