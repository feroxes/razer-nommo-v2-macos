public enum LightingMode: Equatable, Sendable {
    case spectrum
    case staticColor(LightColor)

    public var color: LightColor? {
        switch self {
        case .spectrum: nil
        case .staticColor(let color): color
        }
    }
}
