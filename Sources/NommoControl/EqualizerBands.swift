import Foundation
import NommoKit

enum EqualizerBands {
    private static let lowestHertz = 31.25
    private static let stepRatio = 2.0

    static let centerHertz: [Double] = (0..<EqualizerCurve.bandCount).map { band in
        lowestHertz * pow(stepRatio, Double(band))
    }
}
