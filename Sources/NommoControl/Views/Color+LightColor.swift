import NommoKit
import SwiftUI

extension Color {
    init(_ light: LightColor) {
        self.init(
            .sRGB,
            red: CGFloat(light.red) / LightColor.channelMax,
            green: CGFloat(light.green) / LightColor.channelMax,
            blue: CGFloat(light.blue) / LightColor.channelMax
        )
    }
}
