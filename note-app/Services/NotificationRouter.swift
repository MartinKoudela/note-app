import Foundation
import Observation

@Observable
final class NotificationRouter {
    static let shared = NotificationRouter()

    var taskToOpen: TaskItem?

    private init() {}
}
