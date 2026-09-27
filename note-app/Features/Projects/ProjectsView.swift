import SwiftUI

struct ProjectsView: View {
    
    private let projects: [Project] = []
    
    
    private var projectCount: Int {
        projects.count
    }
    
    @State private var showAddProject = false
    
    var body: some View {
        NavigationStack {
            Group {
                if projectCount == 0 {
                    ContentUnavailableView {
                        Label("No Projects", systemImage: AppTab.projects.systemImage)
                    } description: {
                        Text("Projects will appear here.")
                    } actions: {
                        Button("Add Project") {
                            showAddProject = true
                        }
                        .buttonStyle(.glassProminent)
                    }
                } else {
                    Text("Projects")
                }
            }
            .navigationTitle(AppTab.projects.title)
            .appToolbar()
            .sheet(isPresented: $showAddProject) {
                AddProjectView()
            }
        }
    }
}

#Preview {
    ProjectsView()
}
