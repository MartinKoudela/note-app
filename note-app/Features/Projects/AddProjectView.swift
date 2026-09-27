import SwiftUI

struct AddProjectView: View {
    
    @Environment(\.dismiss) private var dismiss
    
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
                    Button(role: .confirm) { dismiss() }
                        .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddProjectView()
}
