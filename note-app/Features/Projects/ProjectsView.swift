import SwiftUI
import SwiftData

struct ProjectsView: View {

    @Query(sort: \Project.sortOrder) private var projects: [Project]
    @Query(sort: \Page.updatedAt, order: .reverse) private var pages: [Page]

    @State private var activeAdd: AddAction?

    private var activeProjects: [Project] {
        projects.filter { $0.deletedAt == nil && !$0.isArchived }
    }

    private var recentPages: [Page] {
        pages
            .filter { $0.isVisible && $0.project?.isArchived != true && !$0.isEmpty }
            .sorted { ($0.lastOpenedAt ?? $0.updatedAt) > ($1.lastOpenedAt ?? $1.updatedAt) }
            .prefix(4)
            .map { $0 }
    }

    var body: some View {
        NavigationStack {
            Group {
                if activeProjects.isEmpty {
                    ContentUnavailableView {
                        Label("No Projects", systemImage: AppTab.projects.systemImage)
                    } description: {
                        Text("Projects will appear here.")
                    } actions: {
                        Button("Add Project") { activeAdd = .project }
                            .buttonStyle(.glassProminent)
                    }
                } else {
                    List {
                        if !recentPages.isEmpty {
                            Section("Recent") {
                                ForEach(recentPages) { page in
                                    NavigationLink(value: page) {
                                        PageRow(page: page, showsProject: true)
                                    }
                                    .listSectionSeparator(.hidden)
                                }
                            }
                            .headerProminence(.increased)
                        }

                        Section("Projects") {
                            ForEach(activeProjects) { project in
                                NavigationLink(value: project) {
                                    ProjectRow(project: project)
                                }
                                .projectSwipeActions(project)
                                .listSectionSeparator(.hidden)
                            }
                        }
                        .headerProminence(.increased)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(AppTab.projects.title)
            .appToolbar(primary: .project)
            .sheet(item: $activeAdd) { AddSheet(action: $0) }
            .navigationDestination(for: Project.self) { project in
                ProjectDetailView(project: project)
            }
            .navigationDestination(for: Page.self) { page in
                PageView(page: page)
            }
            .navigationDestination(for: TaskItem.self) { item in
                TaskDetailView(item: item)
            }
        }
    }
}

#Preview {
    ProjectsView()
        .modelContainer(for: [Project.self, TaskItem.self, Page.self], inMemory: true)
}
