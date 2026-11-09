import NommoKit
import SwiftUI

extension Color {
    private static let channelMax = Double(UInt8.max)

    init(_ light: LightColor) {
        self.init(
            .sRGB,
            red: Double(light.red) / Self.channelMax,
            green: Double(light.green) / Self.channelMax,
            blue: Double(light.blue) / Self.channelMax
        )
    }
}
