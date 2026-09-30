import SwiftUI
import SwiftData

struct ArchiveView: View {

    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Project.name) private var projects: [Project]
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var items: [TaskItem]
    @Query(sort: \Page.updatedAt, order: .reverse) private var pages: [Page]

    private var archivedProjects: [Project] {
        projects.filter { $0.isArchived && $0.deletedAt == nil }
    }

    private var archivedPages: [Page] {
        pages.filter { page in
            page.isArchived &&
            page.deletedAt == nil &&
            page.parent?.isArchived != true &&
            page.project?.deletedAt == nil
        }
    }

    private var archivedItems: [TaskItem] {
        items.filter { $0.isArchived && $0.deletedAt == nil }
    }

    var body: some View {
        NavigationStack {
            Group {
                if archivedProjects.isEmpty && archivedPages.isEmpty && archivedItems.isEmpty {
                    ContentUnavailableView(
                        "No Archived Items",
                        systemImage: MoreDestination.archive.systemImage,
                        description: Text("Archived projects, pages and tasks will appear here.")
                    )
                } else {
                    List {
                        if !archivedProjects.isEmpty {
                            Section("Projects") {
                                ForEach(archivedProjects) { project in
                                    ProjectRow(project: project)
                                        .projectSwipeActions(project)
                                }
                            }
                        }

                        if !archivedPages.isEmpty {

                            Section("Pages") {

                                ForEach(archivedPages) { page in

                                    NavigationLink(value: page) {

                                        PageRow(page: page, showsProject: true)

                                    }

                                    .swipeActions(edge: .trailing) {

                                        Button(role: .destructive) {

                                            page.deletedAt = .now

                                        } label: {

                                            Label(MoreDestination.bin.title, systemImage: MoreDestination.bin.systemImage)

                                        }

                                        Button {

                                            page.isArchived = false

                                        } label: {

                                            Label("Unarchive", systemImage: "tray.and.arrow.up")

                                        }

                                        .tint(.indigo)

                                    }

                                }

                            }

                        }


                        if !archivedItems.isEmpty {
                            Section("Tasks") {
                                ForEach(archivedItems) { item in
                                    TaskRow(item: item)
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                item.deletedAt = .now
                                                NotificationService.cancel(for: item)
                                            } label: {
                                                Label(MoreDestination.bin.title, systemImage: MoreDestination.bin.systemImage)
                                            }

                                            Button {
                                                item.isArchived = false
                                                NotificationService.update(for: item)
                                            } label: {
                                                Label("Unarchive", systemImage: "tray.and.arrow.up")
                                            }
                                            .tint(.indigo)
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(MoreDestination.archive.title)
            .navigationDestination(for: Page.self) { page in
                PageView(page: page)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ArchiveView()
        .modelContainer(for: [Project.self, TaskItem.self, Page.self], inMemory: true)
}
