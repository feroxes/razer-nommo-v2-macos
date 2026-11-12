import NommoKit
import SwiftUI

struct PowerTile: View {
    private enum Layout {
        static let capsuleSpacing: CGFloat = 4
    }

    private enum Symbol {
        static let power = "power"
    }

    let model: SpeakerModel
    let state: AutoPowerOff

    var body: some View {
        Tile(symbol: Symbol.power, title: Strings.autoPowerOff) {
            TileSwitch(title: Strings.autoPowerOff, isOn: isEnabled)
        } content: {
            HStack(spacing: Layout.capsuleSpacing) {
                ForEach(PowerOffDelay.allCases, id: \.self) { delay in
                    Button(Strings.minutes(delay.minutes)) {
                        model.selectPowerOffDelay(delay)
                    }
                    .buttonStyle(ChoiceCapsuleStyle(isSelected: state.delay == delay))
                }
            }
            .switchedOff(!state.isEnabled)
            Text(Strings.autoPowerOffHint)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var isEnabled: Binding<Bool> {
        Binding(
            get: { state.isEnabled },
            set: { model.setPowerSaving($0) }
        )
    }
}
