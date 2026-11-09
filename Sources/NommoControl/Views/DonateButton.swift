import AppKit
import SwiftUI

struct DonateButton: View {
    private enum Symbol {
        static let heart = "heart.fill"
    }

    var body: some View {
        Button(action: openDonation) {
            Image(systemName: Symbol.heart)
        }
        .buttonStyle(.borderless)
        .foregroundStyle(.red)
        .help(Strings.supportProject)
        .accessibilityLabel(Text(Strings.supportProject))
    }

    private func openDonation() {
        guard let url = ProjectLinks.donation else { return }
        NSWorkspace.shared.open(url)
    }
}
