import NommoKit
import SwiftUI

struct SubwooferTile: View {
    private enum Symbol {
        static let subwoofer = "speaker.wave.3.fill"
    }

    @Bindable var model: SpeakerModel

    var body: some View {
        Tile(symbol: Symbol.subwoofer, title: Strings.subwoofer) {
            Text(Strings.subwooferLevel(model.subwoofer))
        } content: {
            IntegerSlider(value: $model.subwoofer, range: SubwooferLevel.range, showsSteps: true, onCommit: model.commitSubwoofer)
                .accessibilityLabel(Text(Strings.subwoofer))
        }
    }
}
