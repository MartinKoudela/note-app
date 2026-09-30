import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    
    var body: some View {
        NavigationStack {
            Text("Project Detail")
                .navigationTitle(AppTab.projects.title)
                .appToolbar(primary: .project)
        }
    }
}

#Preview {
    ProjectDetailView()
        .modelContainer(for: [Project.self, TaskItem.self], inMemory: true)
    
}
