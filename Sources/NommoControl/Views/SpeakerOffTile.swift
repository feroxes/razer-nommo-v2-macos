import SwiftUI

struct SpeakerOffTile: View {
    private enum Layout {
        static let verticalPadding: CGFloat = 20
    }

    private enum Symbol {
        static let off = "speaker.slash.fill"
    }

    var body: some View {
        Label(Strings.speakerOff, systemImage: Symbol.off)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Layout.verticalPadding)
            .tileBackground()
    }
}
