import SwiftUI
import SwiftData

struct BinView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Project.name) private var projects: [Project]
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var items: [TaskItem]
    @Query(sort: \Page.updatedAt, order: .reverse) private var pages: [Page]

    @State private var showEmptyConfirmation = false

    private var deletedProjects: [Project] {
        projects.filter { $0.deletedAt != nil }
    }

    private var deletedItems: [TaskItem] {
        items.filter { $0.deletedAt != nil && $0.project?.deletedAt == nil }
    }

    private var deletedPages: [Page] {
        pages.filter { page in
            page.deletedAt != nil &&
            page.parent?.deletedAt == nil &&
            page.project?.deletedAt == nil
        }
    }

    private var isEmpty: Bool {
        deletedProjects.isEmpty && deletedItems.isEmpty && deletedPages.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if isEmpty {
                    ContentUnavailableView(
                        "Bin Is Empty",
                        systemImage: MoreDestination.bin.systemImage,
                        description: Text("Deleted projects, pages and tasks will appear here.")
                    )
                } else {
                    List {
                        if !deletedProjects.isEmpty {
                            Section("Projects") {
                                ForEach(deletedProjects) { project in
                                    DeletedProject(project: project)
                                }
                            }
                        }

                        if !deletedPages.isEmpty {
                            Section("Pages") {
                                ForEach(deletedPages) { page in
                                    DeletedPage(page: page)
                                }
                            }
                        }

                        if !deletedItems.isEmpty {
                            Section("Tasks") {
                                ForEach(deletedItems) { item in
                                    DeletedTask(item: item)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(MoreDestination.bin.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Empty Bin", role: .destructive) {
                        showEmptyConfirmation = true
                    }
                    .disabled(isEmpty)
                }
            }
            .confirmationDialog("Empty Bin?", isPresented: $showEmptyConfirmation, titleVisibility: .visible) {
                Button("Delete All Permanently", role: .destructive) {
                    emptyBin()
                }
            } message: {
                Text("This can't be undone.")
            }
        }
    }

    private func emptyBin() {
        for project in deletedProjects {
            project.tasks.forEach(NotificationService.cancel)
            modelContext.delete(project)
        }
        for item in deletedItems {
            NotificationService.cancel(for: item)
            modelContext.delete(item)
        }
        for page in deletedPages {
            modelContext.delete(page)
        }
    }
}

#Preview {
    BinView()
        .modelContainer(for: [Project.self, TaskItem.self, Page.self], inMemory: true)
}
