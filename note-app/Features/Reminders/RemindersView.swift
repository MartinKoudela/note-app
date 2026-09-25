import SwiftUI

struct RemindersView: View {
    var body: some View {
        NavigationStack {
            Text("Reminders")
                .navigationTitle(AppTab.reminders.title)
                .appToolbar()
            
        }
    }
}

#Preview {
    RemindersView()
}
