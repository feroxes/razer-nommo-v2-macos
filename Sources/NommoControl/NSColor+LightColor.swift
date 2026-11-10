import AppKit
import NommoKit

extension NSColor {
    private static let opaque: CGFloat = 1

    convenience init(_ light: LightColor) {
        self.init(
            srgbRed: CGFloat(light.red) / LightColor.channelMax,
            green: CGFloat(light.green) / LightColor.channelMax,
            blue: CGFloat(light.blue) / LightColor.channelMax,
            alpha: Self.opaque
        )
    }
}

extension LightColor {
    static let channelMax = CGFloat(UInt8.max)
    private static let unitRange: ClosedRange<CGFloat> = 0...1

    init?(_ color: NSColor) {
        guard let rgb = color.usingColorSpace(.sRGB) else { return nil }
        self.init(
            red: Self.channel(rgb.redComponent),
            green: Self.channel(rgb.greenComponent),
            blue: Self.channel(rgb.blueComponent)
        )
    }

    private static func channel(_ component: CGFloat) -> UInt8 {
        let clamped = min(max(component, unitRange.lowerBound), unitRange.upperBound)
        return UInt8((clamped * channelMax).rounded())
    }
}
