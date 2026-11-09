import NommoKit

enum CLICommand {
    case status
    case subwoofer(SubwooferLevel)
    case equalizer(EqualizerPreset)
    case lighting(LightingMode)
    case brightness(Brightness)

    private enum Arity {
        static let bare = 0
        static let single = 1
    }

    init?(arguments: [String]) {
        guard let name = arguments.first else { return nil }
        let rest = Array(arguments.dropFirst())
        let value = rest.first
        switch (name, rest.count) {
        case (CLIKeyword.status, Arity.bare):
            self = .status
        case (CLIKeyword.subwoofer, Arity.single):
            guard let number = value.flatMap({ Int($0) }), let level = SubwooferLevel(number) else { return nil }
            self = .subwoofer(level)
        case (CLIKeyword.equalizer, Arity.single):
            guard let preset = value.flatMap(CLIKeyword.preset(named:)) else { return nil }
            self = .equalizer(preset)
        case (CLIKeyword.brightness, Arity.single):
            guard let number = value.flatMap({ Int($0) }), Brightness.percentRange.contains(number) else { return nil }
            self = .brightness(Brightness(clamping: number))
        case (CLIKeyword.light, _):
            guard let mode = Self.lightingMode(rest) else { return nil }
            self = .lighting(mode)
        default:
            return nil
        }
    }

    func run(on device: NommoDevice) throws -> String {
        switch self {
        case .status:
            return CLIOutput.describe(try device.readState())
        case .subwoofer(let level):
            return CLIOutput.subwoofer(try device.writeSubwoofer(level))
        case .equalizer(let preset):
            return CLIOutput.equalizer(try device.writeEqualizer(preset.curve))
        case .lighting(let mode):
            try device.writeLighting(mode)
            return CLIOutput.lightingApplied
        case .brightness(let brightness):
            return CLIOutput.brightness(try device.writeBrightness(brightness))
        }
    }

    private static func lightingMode(_ arguments: [String]) -> LightingMode? {
        guard let kind = arguments.first else { return nil }
        let rest = Array(arguments.dropFirst())
        switch (kind, rest.count) {
        case (CLIKeyword.spectrum, Arity.bare):
            return .spectrum
        case (CLIKeyword.staticColor, Arity.single):
            guard let color = rest.first.flatMap({ LightColor(hex: $0) }) else { return nil }
            return .staticColor(color)
        default:
            return nil
        }
    }
}
