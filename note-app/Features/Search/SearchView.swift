import SwiftUI
import SwiftData

struct SearchView: View {

    @Query(sort: \TaskItem.createdAt, order: .reverse) private var items: [TaskItem]
    @Query(sort: \Project.name) private var projects: [Project]
    @Query(sort: \Page.updatedAt, order: .reverse) private var pages: [Page]

    @State private var query = ""

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var matchingProjects: [Project] {
        guard !trimmedQuery.isEmpty else { return [] }
        return projects.filter { project in
            project.deletedAt == nil &&
            (project.name.localizedStandardContains(trimmedQuery) || project.notes.localizedStandardContains(trimmedQuery))
        }
    }

    private var matchingItems: [TaskItem] {
        guard !trimmedQuery.isEmpty else { return [] }
        return items.filter { item in
            item.deletedAt == nil &&
            item.project?.deletedAt == nil &&
            (item.title.localizedStandardContains(trimmedQuery) || item.notes.localizedStandardContains(trimmedQuery))
        }
    }

    private var matchingPages: [Page] {
        guard !trimmedQuery.isEmpty else { return [] }
        return pages.filter { page in
            page.isVisible &&
            (page.title.localizedStandardContains(trimmedQuery) || page.content.localizedStandardContains(trimmedQuery))
        }
    }

    private var openItems: [TaskItem] {
        matchingItems.filter { !$0.isCompleted }
    }

    private var completedItems: [TaskItem] {
        matchingItems.filter(\.isCompleted)
    }

    var body: some View {
        NavigationStack {
            Group {
                if trimmedQuery.isEmpty {
                    ContentUnavailableView(
                        "Search Backlog",
                        systemImage: AppTab.search.systemImage,
                        description: Text("Find tasks, pages, notes and projects.")
                    )
                } else if matchingProjects.isEmpty && matchingPages.isEmpty && matchingItems.isEmpty {
                    ContentUnavailableView.search(text: trimmedQuery)
                } else {
                    List {
                        if !matchingProjects.isEmpty {
                            Section("Projects") {
                                ForEach(matchingProjects) { project in
                                    NavigationLink(value: project) {
                                        ProjectRow(project: project)
                                    }
                                    .listSectionSeparator(.hidden)
                                }
                            }
                            .headerProminence(.increased)
                        }

                        if !matchingPages.isEmpty {
                            Section("Pages") {
                                ForEach(matchingPages) { page in
                                    NavigationLink(value: page) {
                                        PageRow(page: page, showsProject: true)
                                    }
                                    .listSectionSeparator(.hidden)
                                }
                            }
                            .headerProminence(.increased)
                        }

                        if !openItems.isEmpty {
                            Section("Tasks") {
                                ForEach(openItems) { item in
                                    TaskListRow(item: item)
                                }
                            }
                            .headerProminence(.increased)
                        }

                        if !completedItems.isEmpty {
                            Section("Completed") {
                                ForEach(completedItems) { item in
                                    TaskListRow(item: item)
                                }
                            }
                            .headerProminence(.increased)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(AppTab.search.title)
            .searchable(text: $query, prompt: "Tasks, pages and projects")
            .navigationDestination(for: TaskItem.self) { item in
                TaskDetailView(item: item)
            }
            .navigationDestination(for: Project.self) { project in
                ProjectDetailView(project: project)
            }
            .navigationDestination(for: Page.self) { page in
                PageView(page: page)
            }
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(for: [Project.self, TaskItem.self, Page.self], inMemory: true)
}
