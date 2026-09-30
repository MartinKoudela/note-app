import SwiftUI

struct ProjectIconPicker: View {
    @Binding var selection: String
    var color: ProjectColor

    static let icons = [
        "folder", "briefcase", "book", "graduationcap",
        "house", "cart", "heart", "star",
        "flag", "paintbrush", "hammer", "laptopcomputer",
        "chevron.left.forwardslash.chevron.right", "terminal", "server.rack", "cpu",
        "iphone", "globe", "camera", "music.note"
    ]

    private let columns = [GridItem(.adaptive(minimum: 44))]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Self.icons, id: \.self) { option in
                let isSelected = option == selection

                Button {
                    selection = option
                } label: {
                    Image(systemName: option)
                        .font(.title3)
                        .frame(width: 40, height: 40)
                        .foregroundStyle(isSelected ? Color.white : Color.primary)
                        .background(isSelected ? color.color : Color.secondary.opacity(0.15), in: .circle)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(option)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(.vertical, 4)
    }
}
