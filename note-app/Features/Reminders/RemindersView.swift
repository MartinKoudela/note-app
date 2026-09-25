import SwiftUI

struct RemindersView: View {
    var body: some View {
        NavigationStack {
            Text("Reminders")
                .navigationTitle("Reminders")
                .appToolbar()

        }
    }
}

#Preview {
    RemindersView()
}
