import SwiftUI

struct ProjectIcon: View {
    let icon: String
    let color: ProjectColor
    var size: CGFloat = 32

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size * 0.45, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(color.color.gradient, in: .rect(cornerRadius: size * 0.28, style: .continuous))
            .accessibilityHidden(true)
    }
}
