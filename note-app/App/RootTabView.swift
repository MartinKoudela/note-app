import SwiftUI

enum AppTab: Hashable {
    case today, projects, reminders, search
    
    var title: String {
        switch self {
        case .today: "Today"
        case .projects: "Projects"
        case .reminders: "Reminders"
        case .search: "Search"
        }
    }
    
    var systemImage: String {
        switch self {
        case .today: "sun.max"
        case .projects: "folder"
        case .reminders: "bell"
        case .search: "magnifyingglass"
        }
    }
}

struct RootTabView: View {
    @State private var selection: AppTab = .today
    
    var body: some View {
        TabView(selection: $selection) {
            Tab(AppTab.today.title, systemImage: AppTab.today.systemImage, value: .today) {
                TodayView()
            }
            Tab(AppTab.projects.title, systemImage: AppTab.projects.systemImage, value: .projects) {
                ProjectsView()
            }
            Tab(AppTab.reminders.title, systemImage: AppTab.reminders.systemImage, value: .reminders) {
                RemindersView()
            }
            Tab(value: .search, role: .search) {
                SearchView()
                
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewSearchActivation(.searchTabSelection)
    }
}

#Preview {
    RootTabView()
}
