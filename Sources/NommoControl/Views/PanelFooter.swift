import SwiftUI

struct PanelFooter: View {
    let launchAtLogin: LaunchAtLogin
    let updates: UpdateController
    let actions: PanelActions

    var body: some View {
        HStack {
            Toggle(Strings.launchAtLogin, isOn: isEnabled)
                .toggleStyle(.switch)
            Spacer(minLength: .zero)
            DonateButton(action: actions.donate)
            PanelMenu(updates: updates, actions: actions)
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
