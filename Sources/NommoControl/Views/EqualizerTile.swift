import NommoKit
import SwiftUI

struct EqualizerTile: View {
    private enum Layout {
        static let capsuleSpacing: CGFloat = 4
    }

    private enum Symbol {
        static let equalizer = "slider.vertical.3"
    }

    let model: SpeakerModel

    var body: some View {
        Tile(symbol: Symbol.equalizer, title: Strings.equalizer) {
            if model.equalizer == .builtIn {
                Text(Strings.builtIn)
            }
        } content: {
            HStack(spacing: Layout.capsuleSpacing) {
                ForEach(EqualizerPreset.allCases, id: \.self) { preset in
                    choice(Strings.preset(preset), isSelected: model.equalizer == .preset(preset)) {
                        model.selectPreset(preset)
                    }
                }
                choice(Strings.custom, isSelected: isCustom) {
                    model.selectCustom()
                }
            }
            if isCustom {
                CustomCurveEditor(model: model)
            }
        }
    }

    private var isCustom: Bool {
        guard case .custom = model.equalizer else { return false }
        return true
    }

    private func choice(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .buttonStyle(ChoiceCapsuleStyle(isSelected: isSelected))
    }
}
