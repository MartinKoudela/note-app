import SwiftUI

struct TaskListRow: View {
    let item: TaskItem
    var showsProject = true

    var body: some View {
        NavigationLink(value: item) {
            TaskRow(item: item, showsProject: showsProject)
        }
        .taskSwipeActions(item)
        .listSectionSeparator(.hidden)
    }
}
