import SwiftUI
import SwiftData

struct BinView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Project.name) private var projects: [Project]
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var items: [TaskItem]

    @State private var showEmptyConfirmation = false

    private var deletedProjects: [Project] {
        projects.filter { $0.deletedAt != nil }
    }

    private var deletedItems: [TaskItem] {
        items.filter { $0.deletedAt != nil && $0.project?.deletedAt == nil }
    }

    private var isEmpty: Bool {
        deletedProjects.isEmpty && deletedItems.isEmpty
    }

    var body: some View {
        NavigationStack {
            Group {
                if isEmpty {
                    ContentUnavailableView(
                        "Bin Is Empty",
                        systemImage: MoreDestination.bin.systemImage,
                        description: Text("Deleted projects and tasks will appear here.")
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
            modelContext.delete(project)
        }
        for item in deletedItems {
            modelContext.delete(item)
        }
    }
}

#Preview {
    BinView()
        .modelContainer(for: [Project.self, TaskItem.self], inMemory: true)
}
