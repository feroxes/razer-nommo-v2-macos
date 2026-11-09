import SwiftUI

private enum TileLayout {
    static let spacing: CGFloat = 10
    static let headerSpacing: CGFloat = 8
    static let iconWidth: CGFloat = 18
    static let padding: CGFloat = 14
}

struct Tile<Accessory: View, Content: View>: View {
    let symbol: String
    let title: String
    @ViewBuilder let accessory: Accessory
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: TileLayout.spacing) {
            header
            content
        }
        .padding(TileLayout.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .tileBackground()
    }

    private var header: some View {
        HStack(spacing: TileLayout.headerSpacing) {
            Image(systemName: symbol)
                .foregroundStyle(.tint)
                .frame(width: TileLayout.iconWidth)
            Text(title)
                .font(.headline)
            Spacer(minLength: .zero)
            accessory
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}

extension Tile where Accessory == EmptyView {
    init(symbol: String, title: String, @ViewBuilder content: () -> Content) {
        self.init(symbol: symbol, title: title, accessory: { EmptyView() }, content: content)
    }
}
