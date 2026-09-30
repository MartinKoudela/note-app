import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    @Bindable var project: Project

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showEdit = false
    @State private var showAddTask = false
    @State private var showCompleted = false
    @State private var newPage: Page?
    @State private var isSelecting = false
    @State private var selection = Set<PersistentIdentifier>()
    
    private var selectableItems: [TaskItem] {
        project.openTasks + (showCompleted ? project.completedTasks : [])
    }

    private var summary: String {
        var parts: [String] = []
        if let deadline = project.deadline {
            parts.append("Due \(deadline.dayMonth)")
        }
        let open = project.openTasks.count
        parts.append(open == 1 ? "1 open task" : "\(open) open tasks")
        let pages = project.pages.filter { $0.deletedAt == nil }.count
        parts.append(pages == 1 ? "1 page" : "\(pages) pages")
        return parts.joined(separator: " · ")
    }

    var body: some View {
        List(selection: $selection) {
            header
            pagesSection
            tasksSection
        }
        .listStyle(.plain)
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !isSelecting {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("New Page", systemImage: "doc.badge.plus") { createPage() }
                        Button("New Task", systemImage: "checklist") { showAddTask = true }
                    } label: {
                        Label("Add", systemImage: "plus")
                    } primaryAction: {
                        createPage()
                    }
                }

                ToolbarSpacer(.fixed, placement: .topBarTrailing)

                ToolbarItem(placement: .topBarTrailing) {
                    Menu("More", systemImage: "ellipsis") {
                        Button("Select Tasks", systemImage: "checkmark.circle") {
                            withAnimation(.snappy) {
                                isSelecting = true
                            }
                        }
                        .disabled(selectableItems.isEmpty)

                        Button("Edit Project", systemImage: "pencil") { showEdit = true }

                        Divider()

                        Button(MoreDestination.archive.title, systemImage: MoreDestination.archive.systemImage) {
                            project.isArchived = true
                            NotificationService.update(for: project.tasks)
                            dismiss()
                        }

                        Button("Move to Bin", systemImage: MoreDestination.bin.systemImage, role: .destructive) {
                            project.deletedAt = .now
                            project.tasks.forEach(NotificationService.cancel)
                            dismiss()
                        }
                    }
                }
            }
        }
        .taskSelection(isSelecting: $isSelecting, selection: $selection, items: selectableItems)
        .sheet(isPresented: $showEdit) {
            EditProjectView(project: project)
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskView(project: project)
        }
        .navigationDestination(item: $newPage) { page in
            PageView(page: page)
        }
    }

    private var header: some View {
        Section {
            HStack(spacing: 16) {
                ProjectIcon(icon: project.icon, color: project.color, size: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.title2.bold())
                        .lineLimit(2)
                    Text(summary)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Spacer(minLength: 0)

                Button("Edit") { showEdit = true }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
            .padding(.vertical, 4)
            .selectionDisabled()
            .listRowSeparator(.hidden)

            if !project.notes.isEmpty {
                Text(project.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .selectionDisabled()
                    .listRowSeparator(.hidden)
            }
        }
        .listSectionSeparator(.hidden)
    }

    private var pagesSection: some View {
        Section {
            ForEach(project.rootPages) { page in
                PageTreeRow(page: page)
            }

            Button {
                createPage()
            } label: {
                Label("New Page", systemImage: "plus")
                    .foregroundStyle(.tint)
            }
            .selectionDisabled()
            .listSectionSeparator(.hidden)
        } header: {
            Text("Pages")
        }
        .headerProminence(.increased)
    }

    private var tasksSection: some View {
        Section {
            ForEach(project.openTasks) { item in
                TaskListRow(item: item, showsProject: false)
            }

            Button {
                showAddTask = true
            } label: {
                Label("New Task", systemImage: "plus")
                    .foregroundStyle(.tint)
            }
            .selectionDisabled()
            .listSectionSeparator(.hidden)

            if !project.completedTasks.isEmpty {
                Button {
                    withAnimation {
                        showCompleted.toggle()
                    }
                } label: {
                    Text(showCompleted ? "Hide Completed" : "Show Completed (\(project.completedTasks.count))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .selectionDisabled()
                .listRowSeparator(.hidden)
                .listSectionSeparator(.hidden)

                if showCompleted {
                    ForEach(project.completedTasks) { item in
                        TaskListRow(item: item, showsProject: false)
                    }
                }
            }
        } header: {
            Text("Tasks")
        }
        .headerProminence(.increased)
    }

    private func createPage() {
        let page = Page(project: project)
        page.sortOrder = project.nextPageSortOrder
        modelContext.insert(page)
        newPage = page
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: Project(name: "Client website", color: .yellow))
    }
    .modelContainer(for: [Project.self, TaskItem.self, Page.self], inMemory: true)
}
