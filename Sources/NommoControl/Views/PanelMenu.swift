import SwiftUI

struct PanelMenu: View {
    private enum Symbol {
        static let more = "ellipsis.circle"
        static let heart = "heart.fill"
    }

    let updates: UpdateController
    let actions: PanelActions

    var body: some View {
        Menu {
            Button(Strings.aboutApp, action: actions.showAbout)
            Button(Strings.checkForUpdates, action: actions.checkForUpdates)
                .disabled(!updates.canCheckForUpdates)
            Toggle(Strings.checkAutomatically, isOn: checksAutomatically)
            Divider()
            Button(action: actions.donate) {
                Label(Strings.donate, systemImage: Symbol.heart)
            }
            .labelStyle(.titleAndIcon)
            Divider()
            Button(Strings.quit, action: actions.quit)
        } label: {
            Image(systemName: Symbol.more)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .help(Strings.more)
        .accessibilityLabel(Text(Strings.more))
    }

    private var checksAutomatically: Binding<Bool> {
        Binding(
            get: { updates.checksAutomatically },
            set: { updates.checksAutomatically = $0 }
        )
    }
}
