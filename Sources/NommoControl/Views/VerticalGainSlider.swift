import SwiftUI

struct VerticalGainSlider: View {
    private enum Layout {
        static let height: CGFloat = 92
        static let width: CGFloat = 22
        static let trackWidth: CGFloat = 4
        static let knobSize: CGFloat = 12
        static let knobRadius = knobSize / 2
        static let knobBorderWidth: CGFloat = 0.5
        static let knobShadowRadius: CGFloat = 1
        static let travel = height - knobSize
    }

    private static let neutralGain = 0
    private static let accessibilityStep = 1
    private static let fractionRange: ClosedRange<CGFloat> = 0...1

    @Binding var gain: Int
    let range: ClosedRange<Int>
    let onCommit: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Capsule()
                .fill(.quaternary)
                .frame(width: Layout.trackWidth)
            Capsule()
                .fill(Color.accentColor)
                .frame(width: Layout.trackWidth, height: abs(knobCenter - neutralCenter))
                .offset(y: min(knobCenter, neutralCenter))
            Circle()
                .fill(.white)
                .overlay(Circle().strokeBorder(.quaternary, lineWidth: Layout.knobBorderWidth))
                .shadow(radius: Layout.knobShadowRadius)
                .frame(width: Layout.knobSize, height: Layout.knobSize)
                .offset(y: knobCenter - Layout.knobRadius)
        }
        .frame(width: Layout.width, height: Layout.height)
        .contentShape(Rectangle())
        .gesture(drag)
        .accessibilityElement()
        .accessibilityValue(Text(gain, format: .number))
        .accessibilityAdjustableAction(adjust)
    }

    private var knobCenter: CGFloat {
        center(of: gain)
    }

    private var neutralCenter: CGFloat {
        center(of: Self.neutralGain)
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: .zero)
            .onChanged { gain = value(at: $0.location.y) }
            .onEnded { drag in
                gain = value(at: drag.location.y)
                onCommit()
            }
    }

    private var span: CGFloat {
        CGFloat(range.upperBound - range.lowerBound)
    }

    private func center(of value: Int) -> CGFloat {
        Layout.knobRadius + CGFloat(range.upperBound - value) / span * Layout.travel
    }

    private func value(at y: CGFloat) -> Int {
        let traveled = (y - Layout.knobRadius) / Layout.travel
        let fraction = min(max(traveled, Self.fractionRange.lowerBound), Self.fractionRange.upperBound)
        return range.upperBound - Int((fraction * span).rounded())
    }

    private func adjust(_ direction: AccessibilityAdjustmentDirection) {
        switch direction {
        case .increment:
            gain = min(gain + Self.accessibilityStep, range.upperBound)
        case .decrement:
            gain = max(gain - Self.accessibilityStep, range.lowerBound)
        @unknown default:
            return
        }
        onCommit()
    }
}
