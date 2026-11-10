import NommoKit

enum LightingPalette: CaseIterable {
    case red
    case orange
    case yellow
    case green
    case cyan
    case blue
    case violet

    static let initialStatic = LightingPalette.green.color

    var color: LightColor {
        switch self {
        case .red: LightColor(red: 0xFF, green: 0x00, blue: 0x00)
        case .orange: LightColor(red: 0xFF, green: 0x7A, blue: 0x00)
        case .yellow: LightColor(red: 0xFF, green: 0xD4, blue: 0x00)
        case .green: LightColor(red: 0x44, green: 0xD6, blue: 0x2C)
        case .cyan: LightColor(red: 0x00, green: 0xE5, blue: 0xFF)
        case .blue: LightColor(red: 0x00, green: 0x47, blue: 0xFF)
        case .violet: LightColor(red: 0x8A, green: 0x2B, blue: 0xE2)
        }
    }
}
