import SwiftUI
import SwiftData

@main struct NoteApp: App {
    init() {
        NotificationService.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: [Project.self, TaskItem.self])
    }
}
