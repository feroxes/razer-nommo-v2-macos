import SwiftUI

struct TileSwitch: View {
    let title: String
    let isOn: Binding<Bool>

    var body: some View {
        Toggle(title, isOn: isOn)
            .toggleStyle(.switch)
            .labelsHidden()
            .controlSize(.mini)
    }
}
