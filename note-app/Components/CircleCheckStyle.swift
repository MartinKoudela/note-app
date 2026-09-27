import SwiftUI

struct CircleCheckStyle: ToggleStyle {
    var tint: Color = .accentColor
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Image(systemName: configuration.isOn ? "circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(configuration.isOn ? tint : Color.secondary.opacity(0.5))
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
    }
}
