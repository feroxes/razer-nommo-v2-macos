import NommoKit

enum Strings {
    static let title = "Nommo V2"
    static let connected = "Connected"
    static let off = "Off"
    static let speakerOff = "Speaker is off"
    static let subwoofer = "Subwoofer"
    static let equalizer = "Equalizer"
    static let custom = "Custom"
    static let builtIn = "Built-in"
    static let lighting = "Lighting"
    static let spectrum = "Spectrum"
    static let staticColor = "Static"
    static let brightness = "Brightness"
    static let launchAtLogin = "Launch at login"
    static let quit = "Quit"
    static let supportProject = "Support the project"

    static let bandLabels = EqualizerBands.centerHertz.map(bandLabel)

    private static let levelSeparator = " / "
    private static let hertzPerKilohertz = 1_000.0
    private static let kilohertzSuffix = "k"

    static func subwooferLevel(_ level: Int) -> String {
        "\(level)\(levelSeparator)\(SubwooferLevel.range.upperBound)"
    }

    static func preset(_ preset: EqualizerPreset) -> String {
        switch preset {
        case .standard: "Default"
        case .game: "Game"
        case .movie: "Movie"
        case .music: "Music"
        }
    }

    static func swatch(_ swatch: LightingPalette) -> String {
        switch swatch {
        case .red: "Red"
        case .orange: "Orange"
        case .yellow: "Yellow"
        case .green: "Green"
        case .cyan: "Cyan"
        case .blue: "Blue"
        case .violet: "Violet"
        case .white: "White"
        }
    }

    private static func bandLabel(hertz: Double) -> String {
        guard hertz >= hertzPerKilohertz else { return String(Int(hertz.rounded())) }
        return String(Int((hertz / hertzPerKilohertz).rounded())) + kilohertzSuffix
    }
}
