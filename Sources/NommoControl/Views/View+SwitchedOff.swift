import SwiftUI

private enum SwitchedOffStyle {
    static let onOpacity = 1.0
    static let offOpacity = 0.4
}

extension View {
    func switchedOff(_ isOff: Bool) -> some View {
        disabled(isOff)
            .opacity(isOff ? SwitchedOffStyle.offOpacity : SwitchedOffStyle.onOpacity)
    }
}
