import SwiftUI

struct PanelHeader: View {
    private enum Layout {
        static let spacing: CGFloat = 8
        static let statusSpacing: CGFloat = 6
        static let dotSize: CGFloat = 7
    }

    let isConnected: Bool

    var body: some View {
        HStack(spacing: Layout.spacing) {
            Image(nsImage: SpeakerGlyph.image)
                .renderingMode(.template)
                .foregroundStyle(.secondary)
            Text(Strings.title)
                .font(.title3.weight(.semibold))
            Spacer(minLength: .zero)
            HStack(spacing: Layout.statusSpacing) {
                Circle()
                    .fill(isConnected ? Color.green : Color.gray)
                    .frame(width: Layout.dotSize, height: Layout.dotSize)
                Text(isConnected ? Strings.connected : Strings.off)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
