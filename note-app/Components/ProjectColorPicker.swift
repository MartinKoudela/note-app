import SwiftUI

struct ProjectColorPicker: View {
    @Binding var selection: ProjectColor

    private let columns = [GridItem(.adaptive(minimum: 44))]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(ProjectColor.allCases, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    Circle()
                        .fill(option.color)
                        .frame(width: 32, height: 32)
                        .padding(4)
                        .overlay {
                            if option == selection {
                                Circle().stroke(.secondary, lineWidth: 2)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(option.rawValue.capitalized)
                .accessibilityAddTraits(option == selection ? .isSelected : [])
            }
        }
        .padding(.vertical, 4)
    }
}
