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
    let updates: UpdateController
    let actions: PanelActions

    var body: some View {
        VStack(spacing: Layout.spacing) {
            PanelHeader(isConnected: model.connection == .connected)
                .padding(.horizontal, Layout.edgeInset)
            tiles
            if let version = updates.availableVersion {
                UpdateBanner(version: version, onUpdate: actions.checkForUpdates)
            }
            PanelFooter(launchAtLogin: launchAtLogin, updates: updates, actions: actions)
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
            if let autoPowerOff = model.autoPowerOff {
                PowerTile(model: model, state: autoPowerOff)
            }
        }
    }
}
