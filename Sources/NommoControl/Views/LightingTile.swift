import NommoKit
import SwiftUI

struct LightingTile: View {
    private enum Layout {
        static let brightnessSpacing: CGFloat = 8
    }

    private enum Symbol {
        static let lighting = "lightbulb.fill"
        static let dim = "sun.min"
        static let bright = "sun.max"
    }

    @Bindable var model: SpeakerModel

    var body: some View {
        Tile(symbol: Symbol.lighting, title: Strings.lighting) {
            Picker(Strings.lighting, selection: kind) {
                ForEach(LightingKind.allCases, id: \.self) { kind in
                    Text(kind.title).tag(kind)
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            SwatchRow(selection: model.lighting.color) { color in
                model.selectColor(color)
            }
            brightness
        }
    }

    private var brightness: some View {
        HStack(spacing: Layout.brightnessSpacing) {
            Image(systemName: Symbol.dim)
            IntegerSlider(value: $model.brightnessPercent, range: Brightness.percentRange, onCommit: model.commitBrightness)
                .accessibilityLabel(Text(Strings.brightness))
            Image(systemName: Symbol.bright)
        }
        .foregroundStyle(.secondary)
    }

    private var kind: Binding<LightingKind> {
        Binding(
            get: { LightingKind(model.lighting) },
            set: { model.setLighting($0.mode(color: model.lightingColor)) }
        )
    }
}

private enum LightingKind: CaseIterable {
    case spectrum
    case staticColor

    init(_ mode: LightingMode) {
        switch mode {
        case .spectrum: self = .spectrum
        case .staticColor: self = .staticColor
        }
    }

    var title: String {
        switch self {
        case .spectrum: Strings.spectrum
        case .staticColor: Strings.staticColor
        }
    }

    func mode(color: LightColor) -> LightingMode {
        switch self {
        case .spectrum: .spectrum
        case .staticColor: .staticColor(color)
        }
    }
}
