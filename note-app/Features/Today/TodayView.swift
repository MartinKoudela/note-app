import SwiftUI

struct TodayView: View {
    // test data
    private let taskCount = 3
    private let completedCount = 2

    var body: some View {
        NavigationStack {
            Group {
                if taskCount == 0 {
                    ContentUnavailableView {
                        Label("No Tasks Today", systemImage: AppTab.today.systemImage)
                    } description: {
                        Text("Tasks due today will appear here.")
                    } actions: {
                        Button("Add Task") {
                            print("add")
                        }
                        .buttonStyle(.glassProminent)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            ProgressView(value: Double(completedCount), total: Double(taskCount))

                            Text("\(completedCount) of \(taskCount) done")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        .accessibilityElement(children: .combine) // voiceover

                        if completedCount == taskCount {
                            Label("All done", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Tasks list")
                        }
                    }
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .navigationTitle(Date.now.formatted(.dateTime.weekday(.wide)).capitalized)
            .navigationSubtitle(Date.now.formatted(.dateTime.day().month(.wide)))
            .appToolbar()
        }
    }
}

#Preview {
    TodayView()
}
