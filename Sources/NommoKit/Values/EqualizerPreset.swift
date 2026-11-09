public enum EqualizerPreset: CaseIterable, Sendable {
    case standard
    case game
    case movie
    case music

    public var curve: EqualizerCurve {
        switch self {
        case .standard: .flat
        case .game: EqualizerCurve(fitting: [-4, -4, -3, -2, 0, 1, 1, 0, 1, -3])
        case .movie: EqualizerCurve(fitting: [3, 4, 3, -2, -3, -2, -3, 2, 3, 1])
        case .music: EqualizerCurve(fitting: [-1, -1, -1, -3, 0, 3, 2, 0, 2, 0])
        }
    }

    init?(matching curve: EqualizerCurve) {
        guard let preset = Self.allCases.first(where: { $0.curve == curve }) else { return nil }
        self = preset
    }
}
