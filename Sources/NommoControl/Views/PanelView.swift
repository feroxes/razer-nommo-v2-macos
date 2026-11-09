import SwiftUI

struct PanelView: View {
    private enum Layout {
        static let width: CGFloat = 320
        static let padding: CGFloat = 16
        static let spacing: CGFloat = 10
        static let edgeInset: CGFloat = 4
    }

    let model: SpeakerModel
    let launchAtLogin: LaunchAtLogin

    var body: some View {
        VStack(spacing: Layout.spacing) {
            PanelHeader(isConnected: model.connection == .connected)
                .padding(.horizontal, Layout.edgeInset)
            tiles
            PanelFooter(launchAtLogin: launchAtLogin)
                .padding(.horizontal, Layout.edgeInset)
        }
        .padding(Layout.padding)
        .frame(width: Layout.width)
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var tiles: some View {
        switch model.connection {
        case .disconnected:
            SpeakerOffTile()
        case .connected:
            SubwooferTile(model: model)
            EqualizerTile(model: model)
            LightingTile(model: model)
        }
    }
}
