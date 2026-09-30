import SwiftUI
import SwiftData

struct TodayView: View {

    @Query(sort: \TaskItem.createdAt) private var items: [TaskItem]
    @Query(sort: \Project.sortOrder) private var projects: [Project]

    @State private var activeAdd: AddAction?
    @State private var showCompleted = false
    @State private var now = Date.now
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("isTomorrowExpanded") private var isTomorrowExpanded = false

    private var relevantItems: [TaskItem] {
        items.filter { $0.isActive && $0.isOpenOrDoneToday }
    }

    private var overdueAll: [TaskItem] {
        let startOfToday = Calendar.current.startOfDay(for: .now)
        return relevantItems.filter { ($0.dueDate ?? .distantFuture) < startOfToday }
    }

    private var todayAll: [TaskItem] {
        relevantItems.filter { Calendar.current.isDateInToday($0.dueDate ?? .distantPast) }
    }

    private var overdueItems: [TaskItem] {
        overdueAll.filter { $0.isVisible(at: now, showCompleted: showCompleted) }.sortedByDue()
    }

    private var todayItems: [TaskItem] {
        todayAll.filter { $0.isVisible(at: now, showCompleted: showCompleted) }.sortedByDue()
    }

    private var projectGroups: [(project: Project, items: [TaskItem])] {
        let grouped = Dictionary(grouping: todayItems.filter { $0.project != nil }) { $0.project! }
        return grouped
            .map { (project: $0.key, items: $0.value) }
            .sorted { $0.project.sortOrder < $1.project.sortOrder }
    }

    private var looseTodayItems: [TaskItem] {
        todayItems.filter { $0.project == nil }
    }

    private var deadlineProjects: [Project] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let limit = calendar.date(byAdding: .day, value: 8, to: startOfToday) ?? startOfToday
        return projects
            .filter { $0.deletedAt == nil && !$0.isArchived }
            .filter { project in
                guard let deadline = project.deadline else { return false }
                return deadline >= startOfToday && deadline < limit
            }
            .sorted { ($0.deadline ?? .distantFuture) < ($1.deadline ?? .distantFuture) }
    }

    private var tomorrowAll: [TaskItem] {
        relevantItems.filter { Calendar.current.isDateInTomorrow($0.dueDate ?? .distantPast) }
    }
    
    private var tomorrowItems: [TaskItem] {
        tomorrowAll.filter { $0.isVisible(at: now) }.sortedByDue()
    }
    
    private var tomorrowCount: Int {
        tomorrowAll.filter { !$0.isCompleted }.count
    }
    
    private var completedTodayCount: Int {
        relevantItems.filter(\.isCompleted).count
    }

    private var progressItems: [TaskItem] {
        overdueAll + todayAll
    }

    private var taskCount: Int {
        progressItems.count
    }

    private var completedCount: Int {
        progressItems.filter(\.isCompleted).count
    }

    private var isEmpty: Bool {
        progressItems.isEmpty && deadlineProjects.isEmpty && tomorrowCount == 0
    }

    var body: some View {
        NavigationStack {
            Group {
                if isEmpty {
                    ContentUnavailableView {
                        Label("No Tasks Today", systemImage: AppTab.today.systemImage)
                    } description: {
                        Text("Tasks due today will appear here.")
                    } actions: {
                        Button("Add Task") { activeAdd = .todayTask }
                            .buttonStyle(.glassProminent)
                    }
                } else {
                    List {
                        if taskCount > 0 {
                            progressSection
                        }

                        if !overdueItems.isEmpty {
                            Section {
                                ForEach(overdueItems) { item in
                                    TaskListRow(item: item)
                                }
                            } header: {
                                Text("Overdue")
                                    .foregroundStyle(.red)
                            }
                            .headerProminence(.increased)
                        }

                        ForEach(projectGroups, id: \.project.id) { group in
                            Section {
                                ForEach(group.items) { item in
                                    TaskListRow(item: item, showsProject: false)
                                }
                            } header: {
                                Label {
                                    Text(group.project.name)
                                        .foregroundStyle(.primary)
                                } icon: {
                                    Image(systemName: group.project.icon)
                                        .foregroundStyle(group.project.color.color)
                                }
                            }
                            .headerProminence(.increased)
                        }

                        if !looseTodayItems.isEmpty {
                            Section("Today") {
                                ForEach(looseTodayItems) { item in
                                    TaskListRow(item: item)
                                }
                            }
                            .headerProminence(.increased)
                        }

                        if !deadlineProjects.isEmpty {
                            Section("Deadlines") {
                                ForEach(deadlineProjects) { project in
                                    DeadlineRow(project: project)
                                }
                            }
                            .headerProminence(.increased)
                        }

                        if tomorrowCount > 0 || !tomorrowItems.isEmpty {
                            Section {
                                Button {
                                    withAnimation {
                                        isTomorrowExpanded.toggle()
                                    }
                                } label: {
                                    HStack {
                                        Text("Tomorrow")
                                            .font(.title3)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text("\(tomorrowCount)")
                                            .foregroundStyle(.secondary)
                                            .monospacedDigit()
                                        Image(systemName: "chevron.right")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.tertiary)
                                            .rotationEffect(.degrees(isTomorrowExpanded ? 90 : 0))
                                    }
                                    .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                                .accessibilityValue(isTomorrowExpanded ? "Expanded" : "Collapsed")
                                .listRowSeparator(.hidden)
                                .listSectionSeparator(.hidden)
                                
                                if isTomorrowExpanded {
                                    ForEach(tomorrowItems) { item in
                                        TaskListRow(item: item)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .animation(.default, value: now)
                    .animation(.default, value: showCompleted)
                }
            }
            .navigationTitle(now.weekdayName)
            .navigationSubtitle(now.dayMonthWide)
            .appToolbar(primary: .todayTask)
            .sheet(item: $activeAdd) { AddSheet(action: $0) }
            .navigationDestination(for: TaskItem.self) { item in
                TaskDetailView(item: item)
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    now = .now
                }
            }
            .task {
                for await _ in NotificationCenter.default.notifications(named: .NSCalendarDayChanged) {
                    now = .now
                }
            }
            .task(id: completedTodayCount) {
                now = .now
                try? await Task.sleep(for: .seconds(TaskItem.completedGracePeriod))
                now = .now
            }
        }
    }

    private var progressSection: some View {
        Section {
            HStack(spacing: 12) {
                ProgressView(value: Double(completedCount), total: Double(taskCount))

                Text("\(completedCount) of \(taskCount) done")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(completedCount)))
            }
            .animation(.spring(duration: 0.4, bounce: 0.2), value: completedCount)
            .animation(.spring(duration: 0.4, bounce: 0.2), value: taskCount)
            .accessibilityElement(children: .combine)
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)

            if completedCount == taskCount {
                HStack {
                    Label("All done", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button(showCompleted ? "Hide Completed" : "Show Completed") {
                        showCompleted.toggle()
                    }
                    .buttonStyle(.borderless)
                    .font(.subheadline)
                }
                .listRowSeparator(.hidden)
            }
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [Project.self, TaskItem.self], inMemory: true)
}
