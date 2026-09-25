import SwiftUI

struct ProjectsView: View {
    var body: some View {
        NavigationStack {
            Text("Projects")
                .navigationTitle("Projects")
                .appToolbar()

        }
    }
}

#Preview {
    ProjectsView()
}
