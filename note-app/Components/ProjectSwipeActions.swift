import SwiftUI

struct ProjectSwipeActions: ViewModifier {
    let project: Project

    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    project.deletedAt = .now
                } label: {
                    Label(MoreDestination.bin.title, systemImage: MoreDestination.bin.systemImage)
                }

                Button {
                    project.isArchived.toggle()
                } label: {
                    Label(project.isArchived ? "Unarchive" : MoreDestination.archive.title,
                          systemImage: MoreDestination.archive.systemImage)
                }
                .tint(.indigo)
            }
    }
}

extension View {
    func projectSwipeActions(_ project: Project) -> some View {
        modifier(ProjectSwipeActions(project: project))
    }
}
