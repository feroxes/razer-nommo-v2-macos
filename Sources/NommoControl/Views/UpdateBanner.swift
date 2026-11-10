import SwiftUI

struct UpdateBanner: View {
    private enum Layout {
        static let padding: CGFloat = 14
    }

    let version: String
    let onUpdate: () -> Void

    var body: some View {
        HStack {
            Text(Strings.versionAvailable(version))
                .font(.subheadline)
            Spacer(minLength: .zero)
            Button(Strings.update, action: onUpdate)
                .controlSize(.small)
        }
        .padding(Layout.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .tileBackground()
    }
}
