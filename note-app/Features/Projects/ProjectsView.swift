import SwiftUI

struct ProjectsView: View {
    var body: some View {
        NavigationStack {
            Text("Projects")
                .navigationTitle(AppTab.projects.title)
                .appToolbar()
            
        }
    }
}

#Preview {
    ProjectsView()
}
