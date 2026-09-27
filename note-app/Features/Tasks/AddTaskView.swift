import SwiftUI

struct AddTaskView: View {
    var body: some View {
        NavigationStack {
            Text("Add Task")
                .navigationTitle("Add Task")
        }
    }
}

#Preview {
    AddTaskView()
}
