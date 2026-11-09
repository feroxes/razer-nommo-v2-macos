import NommoKit

enum CLIKeyword {
    static let status = "status"
    static let subwoofer = "sub"
    static let equalizer = "eq"
    static let light = "light"
    static let brightness = "brightness"
    static let watch = "watch"
    static let spectrum = "spectrum"
    static let staticColor = "static"
    static let help = "--help"
    static let shortHelp = "-h"
    static let version = "--version"

    static func preset(_ preset: EqualizerPreset) -> String {
        switch preset {
        case .standard: "default"
        case .game: "game"
        case .movie: "movie"
        case .music: "music"
        }
    }

    static func preset(named name: String) -> EqualizerPreset? {
        EqualizerPreset.allCases.first { preset($0) == name }
    }
}
