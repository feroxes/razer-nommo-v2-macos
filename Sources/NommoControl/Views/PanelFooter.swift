import AppKit
import SwiftUI

struct PanelFooter: View {
    let launchAtLogin: LaunchAtLogin

    var body: some View {
        HStack {
            Toggle(Strings.launchAtLogin, isOn: isEnabled)
                .toggleStyle(.switch)
            Spacer(minLength: .zero)
            DonateButton()
            Button(Strings.quit) {
                NSApplication.shared.terminate(nil)
            }
        }
        .controlSize(.small)
    }

    private var isEnabled: Binding<Bool> {
        Binding(
            get: { launchAtLogin.isEnabled },
            set: { launchAtLogin.setEnabled($0) }
        )
    }
}
