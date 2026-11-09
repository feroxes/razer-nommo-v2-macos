import SwiftUI

struct ChoiceCapsuleStyle: ButtonStyle {
    private enum Layout {
        static let horizontalPadding: CGFloat = 4
        static let verticalPadding: CGFloat = 4
        static let lineLimit = 1
        static let pressedOpacity = 0.7
        static let restingOpacity = 1.0
    }

    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .lineLimit(Layout.lineLimit)
            .padding(.horizontal, Layout.horizontalPadding)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Layout.verticalPadding)
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .background(fill, in: Capsule())
            .opacity(configuration.isPressed ? Layout.pressedOpacity : Layout.restingOpacity)
    }

    private var fill: AnyShapeStyle {
        isSelected ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.quaternary)
    }
}
