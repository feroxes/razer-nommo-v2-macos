import NommoKit

enum CLICommand {
    case status
    case subwoofer(SubwooferLevel)
    case equalizer(EqualizerPreset)
    case lighting(LightingMode)
    case brightness(Brightness)
    case power
    case powerSaving(Bool)
    case powerOffDelay(PowerOffDelay)

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
        case (CLIKeyword.power, Arity.bare):
            self = .power
        case (CLIKeyword.power, Arity.single):
            guard let command = value.flatMap(Self.powerCommand) else { return nil }
            self = command
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
        case .power:
            return CLIOutput.autoPowerOff(try device.readState().autoPowerOff)
        case .powerSaving(let isEnabled):
            return CLIOutput.autoPowerOff(try device.writePowerSaving(isEnabled))
        case .powerOffDelay(let delay):
            try device.writePowerOffDelay(delay)
            return CLIOutput.autoPowerOff(try device.writePowerSaving(true))
        }
    }

    private static func powerCommand(_ argument: String) -> CLICommand? {
        switch argument {
        case CLIKeyword.on: return .powerSaving(true)
        case CLIKeyword.off: return .powerSaving(false)
        default: return Int(argument).flatMap(PowerOffDelay.init(minutes:)).map { .powerOffDelay($0) }
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
