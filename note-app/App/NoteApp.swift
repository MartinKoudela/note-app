import SwiftUI
import SwiftData

@main struct NoteApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Project.self, TaskItem.self, Page.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        NotificationService.configure(container: container)
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(container)
    }
}
