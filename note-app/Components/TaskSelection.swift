import SwiftUI
import SwiftData

struct TaskSelection: ViewModifier {
    @Binding var isSelecting: Bool
    @Binding var selection: Set<PersistentIdentifier>
    let items: [TaskItem]

    @State private var editMode: EditMode = .inactive
    @State private var showDeleteConfirmation = false

    private var selectedItems: [TaskItem] {
        items.filter { selection.contains($0.persistentModelID) }
    }

    private var allSelected: Bool {
        !items.isEmpty && selectedItems.count == items.count
    }

    private var allCompleted: Bool {
        !selectedItems.isEmpty && selectedItems.allSatisfy(\.isCompleted)
    }

    private var title: String {
        switch selectedItems.count {
        case 0: "Select Tasks"
        case 1: "1 Selected"
        default: "\(selectedItems.count) Selected"
        }
    }

    func body(content: Content) -> some View {
        content
            .environment(\.editMode, $editMode)
            .environment(\.startTaskSelection) { item in
                selection = [item.persistentModelID]
                isSelecting = true
            }
            .toolbar(isSelecting ? .hidden : .visible, for: .tabBar)
            .toolbar {
                if isSelecting {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(allSelected ? "Deselect All" : "Select All") {
                            withAnimation {
                                selection = allSelected ? [] : Set(items.map(\.persistentModelID))
                            }
                        }
                    }

                    ToolbarItem(placement: .principal) {
                        Text(title)
                            .font(.headline)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button(role: .confirm) {
                            finish()
                        }
                    }

                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            perform { TaskActions.setCompleted(selectedItems, !allCompleted) }
                        } label: {
                            Label(allCompleted ? "Mark as Not Done" : "Complete",
                                  systemImage: allCompleted ? "circle" : "checkmark.circle")
                        }
                        .disabled(selectedItems.isEmpty)
                    }

                    ToolbarSpacer(.flexible, placement: .bottomBar)

                    ToolbarItemGroup(placement: .bottomBar) {
                        TaskActionMenus(items: selectedItems)
                            .disabled(selectedItems.isEmpty)
                    }

                    ToolbarSpacer(.flexible, placement: .bottomBar)

                    ToolbarItemGroup(placement: .bottomBar) {
                        Button {
                            perform { TaskActions.archive(selectedItems) }
                        } label: {
                            Label(MoreDestination.archive.title, systemImage: MoreDestination.archive.systemImage)
                        }
                        .disabled(selectedItems.isEmpty)

                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: MoreDestination.bin.systemImage)
                        }
                        .tint(.red)
                        .disabled(selectedItems.isEmpty)
                    }
                }
            }
            .confirmationDialog(
                selectedItems.count == 1 ? "Move 1 task to Bin?" : "Move \(selectedItems.count) tasks to Bin?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Move to Bin", role: .destructive) {
                    perform { TaskActions.delete(selectedItems) }
                }
            }
            .onChange(of: isSelecting) { _, selecting in
                withAnimation(.snappy) {
                    editMode = selecting ? .active : .inactive
                }
                if !selecting {
                    selection = []
                }
            }
            .onChange(of: editMode) { _, mode in
                if mode.isEditing != isSelecting {
                    isSelecting = mode.isEditing
                }
            }
            .animation(.snappy, value: isSelecting)
    }

    private func perform(_ action: () -> Void) {
        withAnimation {
            action()
        }
        finish()
    }

    private func finish() {
        withAnimation(.snappy) {
            isSelecting = false
        }
    }
}

extension View {
    func taskSelection(isSelecting: Binding<Bool>, selection: Binding<Set<PersistentIdentifier>>, items: [TaskItem]) -> some View {
        modifier(TaskSelection(isSelecting: isSelecting, selection: selection, items: items))
    }
}
