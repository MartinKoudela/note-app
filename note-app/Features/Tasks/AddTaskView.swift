import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var dueDate: Date?
    @State private var hasReminder: Bool
    
    init(dueDate: Date? = nil, hasReminder: Bool = false) {
        _dueDate = State(initialValue: dueDate)
        _hasReminder = State(initialValue: hasReminder)
    }
    
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                Toggle("Remind me", isOn: $hasReminder)
            }
            .navigationTitle("New Task")
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
    AddTaskView()
}
