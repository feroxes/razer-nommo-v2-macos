import SwiftUI

struct IntegerSlider: View {
    private static let step = 1.0

    @Binding var value: Int
    let range: ClosedRange<Int>
    var showsSteps = false
    let onCommit: () -> Void

    var body: some View {
        if showsSteps {
            Slider(value: doubleValue, in: bounds, step: Self.step, onEditingChanged: commitOnRelease)
        } else {
            Slider(value: doubleValue, in: bounds, onEditingChanged: commitOnRelease)
        }
    }

    private var bounds: ClosedRange<Double> {
        Double(range.lowerBound)...Double(range.upperBound)
    }

    private var doubleValue: Binding<Double> {
        Binding(
            get: { Double(value) },
            set: { value = Int($0.rounded()) }
        )
    }

    private func commitOnRelease(_ isEditing: Bool) {
        if !isEditing {
            onCommit()
        }
    }
}
