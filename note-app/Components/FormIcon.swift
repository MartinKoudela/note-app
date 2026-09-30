import SwiftUI

struct FormIcon: View {
    let systemName: String
    let color: Color

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 28, height: 28)
            .background(color.gradient, in: .rect(cornerRadius: 7, style: .continuous))
            .accessibilityHidden(true)
    }
}

struct FormRowLabel: View {
    let title: String
    var value: String?
    let systemImage: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            FormIcon(systemName: systemImage, color: color)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                if let value {
                    Text(value)
                        .font(.footnote)
                        .foregroundStyle(.tint)
                        .contentTransition(.numericText())
                }
            }
        }
    }
}
