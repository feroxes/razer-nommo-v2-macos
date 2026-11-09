public enum EqualizerSelection: Equatable, Sendable {
    case preset(EqualizerPreset)
    case custom(EqualizerCurve)
    case builtIn

    init(mode: EqualizerMode, curve: EqualizerCurve) {
        switch mode {
        case .builtIn:
            self = .builtIn
        case .custom:
            if let preset = EqualizerPreset(matching: curve) {
                self = .preset(preset)
            } else {
                self = .custom(curve)
            }
        }
    }
}
