import NommoKit
import SwiftUI

struct SwatchRow: View {
    private enum Layout {
        static let swatchSize: CGFloat = 20
        static let ringGap: CGFloat = 4
        static let ringWidth: CGFloat = 2
        static let edgeWidth: CGFloat = 0.5
    }

    private enum Wheel {
        static let colors: [Color] = [.red, .yellow, .green, .cyan, .blue, .purple, .red]
    }

    let selection: LightColor?
    let onSelect: @MainActor (LightColor) -> Void
    let onPickColor: @MainActor () -> Void

    var body: some View {
        HStack(spacing: .zero) {
            ForEach(LightingPalette.allCases, id: \.self) { swatch in
                Button {
                    onSelect(swatch.color)
                } label: {
                    circle(Color(swatch.color), isSelected: swatch.color == selection)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(Strings.swatch(swatch)))
                .accessibilityAddTraits(swatch.color == selection ? .isSelected : [])
                .frame(maxWidth: .infinity)
            }
            Button(action: onPickColor) {
                circle(AngularGradient(colors: Wheel.colors, center: .center), isSelected: isCustomSelected)
            }
            .buttonStyle(.plain)
            .help(Strings.customColor)
            .accessibilityLabel(Text(Strings.customColor))
            .accessibilityAddTraits(isCustomSelected ? .isSelected : [])
            .frame(maxWidth: .infinity)
        }
    }

    private var isCustomSelected: Bool {
        guard let selection else { return false }
        return !LightingPalette.allCases.contains { $0.color == selection }
    }

    private func circle(_ fill: some ShapeStyle, isSelected: Bool) -> some View {
        Circle()
            .fill(fill)
            .overlay(Circle().strokeBorder(.tertiary, lineWidth: Layout.edgeWidth))
            .frame(width: Layout.swatchSize, height: Layout.swatchSize)
            .padding(Layout.ringGap)
            .overlay {
                if isSelected {
                    Circle().strokeBorder(.primary, lineWidth: Layout.ringWidth)
                }
            }
            .contentShape(Circle())
    }
}
