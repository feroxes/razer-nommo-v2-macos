import NommoKit
import SwiftUI

struct PowerTile: View {
    private enum Layout {
        static let capsuleSpacing: CGFloat = 4
        static let enabledOpacity = 1.0
        static let disabledOpacity = 0.4
    }

    private enum Symbol {
        static let power = "power"
    }

    let model: SpeakerModel
    let state: AutoPowerOff

    var body: some View {
        Tile(symbol: Symbol.power, title: Strings.autoPowerOff) {
            Toggle(Strings.autoPowerOff, isOn: isEnabled)
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.mini)
        } content: {
            HStack(spacing: Layout.capsuleSpacing) {
                ForEach(PowerOffDelay.allCases, id: \.self) { delay in
                    Button(Strings.minutes(delay.minutes)) {
                        model.selectPowerOffDelay(delay)
                    }
                    .buttonStyle(ChoiceCapsuleStyle(isSelected: state.delay == delay))
                }
            }
            .disabled(!state.isEnabled)
            .opacity(state.isEnabled ? Layout.enabledOpacity : Layout.disabledOpacity)
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
