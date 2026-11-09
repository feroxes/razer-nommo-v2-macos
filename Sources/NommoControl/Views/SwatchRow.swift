import NommoKit
import SwiftUI

struct SwatchRow: View {
    private enum Layout {
        static let swatchSize: CGFloat = 20
        static let ringGap: CGFloat = 4
        static let ringWidth: CGFloat = 2
        static let edgeWidth: CGFloat = 0.5
    }

    let selection: LightColor?
    let onSelect: (LightColor) -> Void

    var body: some View {
        HStack(spacing: .zero) {
            ForEach(LightingPalette.allCases, id: \.self) { swatch in
                Button {
                    onSelect(swatch.color)
                } label: {
                    circle(swatch.color)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(Strings.swatch(swatch)))
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func circle(_ color: LightColor) -> some View {
        Circle()
            .fill(Color(color))
            .overlay(Circle().strokeBorder(.tertiary, lineWidth: Layout.edgeWidth))
            .frame(width: Layout.swatchSize, height: Layout.swatchSize)
            .padding(Layout.ringGap)
            .overlay {
                if color == selection {
                    Circle().strokeBorder(.primary, lineWidth: Layout.ringWidth)
                }
            }
            .contentShape(Circle())
    }
}
