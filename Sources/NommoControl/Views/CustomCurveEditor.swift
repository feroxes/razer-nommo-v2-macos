import NommoKit
import SwiftUI

struct CustomCurveEditor: View {
    private enum Layout {
        static let labelSpacing: CGFloat = 4
    }

    private static let gainFormat = IntegerFormatStyle<Int>().sign(strategy: .always(includingZero: false))

    let model: SpeakerModel

    var body: some View {
        HStack(spacing: .zero) {
            ForEach(Array(zip(Strings.bandLabels, model.customCurve.gains).enumerated()), id: \.offset) { band, entry in
                let (label, value) = entry
                VStack(spacing: Layout.labelSpacing) {
                    Text(value, format: Self.gainFormat)
                        .monospacedDigit()
                    VerticalGainSlider(gain: gain(at: band), range: EqualizerCurve.gainRange, onCommit: model.commitCustomCurve)
                        .accessibilityLabel(Text(label))
                    Text(label)
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func gain(at band: Int) -> Binding<Int> {
        Binding(
            get: { model.customCurve.gains[band] },
            set: { newGain in
                var gains = model.customCurve.gains
                gains[band] = newGain
                if let curve = EqualizerCurve(clamping: gains) {
                    model.customCurve = curve
                }
            }
        )
    }
}
