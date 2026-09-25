import SwiftUI

enum AppTab: Hashable {
    case today, projects, reminders, search
}

struct RootTabView: View {
    @State private var selection: AppTab = .today


    var body: some View {
        TabView(selection: $selection) {
            Tab("Today", systemImage: "sun.max", value: .today) {
                TodayView()
            }
            Tab("Projects", systemImage: "folder", value: .projects) {
                ProjectsView()
            }
            Tab("Reminders", systemImage: "bell", value: .reminders) {
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
