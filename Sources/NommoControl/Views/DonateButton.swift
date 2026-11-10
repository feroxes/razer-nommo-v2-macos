import SwiftUI

struct DonateButton: View {
    private enum Symbol {
        static let heart = "heart.fill"
    }

    let action: @MainActor () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: Symbol.heart)
        }
        .buttonStyle(.borderless)
        .foregroundStyle(.red)
        .help(Strings.supportProject)
        .accessibilityLabel(Text(Strings.supportProject))
    }
}
