import SwiftUI

struct TileBackground: ViewModifier {
    private enum Style {
        static let cornerRadius: CGFloat = 16
        static let fillOpacity = 0.05
        static let strokeOpacity = 0.1
        static let strokeWidth: CGFloat = 1
    }

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: Style.cornerRadius, style: .continuous)
        content
            .background(Color.primary.opacity(Style.fillOpacity), in: shape)
            .overlay(shape.strokeBorder(Color.primary.opacity(Style.strokeOpacity), lineWidth: Style.strokeWidth))
    }
}

extension View {
    func tileBackground() -> some View {
        modifier(TileBackground())
    }
}
