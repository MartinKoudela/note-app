import SwiftUI

struct TaskRow: View {
    let item: TaskItem

    var body: some View {
        Label(item.title, systemImage: item.isCompleted ? "circle.fill" : "circle")
    }
}
