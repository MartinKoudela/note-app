import SwiftUI
import SwiftData

struct AddProjectView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    
    @State private var title = ""
    @State private var deadline: Date?
    
    init(deadline: Date? = nil) {
        _deadline = State(initialValue: deadline)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
            }
            .navigationTitle("New Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        let project = Project(name: title, deadline: deadline)
                        modelContext.insert(project)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddProjectView()
        .modelContainer(for: [Project.self, TaskItem.self], inMemory: true)
}
