import NommoKit

enum CLIOutput {
    private enum Label {
        static let subwoofer = "subwoofer"
        static let equalizer = "equalizer"
        static let brightness = "brightness"
        static let ioReturn = "IOReturn"
    }

    private enum Format {
        static let rangeSeparator = "-"
        static let choiceSeparator = "|"
        static let fieldSeparator = ", "
        static let wordSeparator = " "
        static let percentSuffix = "%"
        static let hexPrefix = "0x"
        static let hexRadix = 16
    }

    static let programName = "nommo"
    static let lineTerminator = "\n"
    static let usage = """
    usage: \(programName) <command>
      \(CLIKeyword.status)
      \(CLIKeyword.subwoofer) <\(span(SubwooferLevel.range))>
      \(CLIKeyword.equalizer) <\(presetChoices)>
      \(CLIKeyword.light) \(CLIKeyword.spectrum) | \(CLIKeyword.staticColor) <hex>
      \(CLIKeyword.brightness) <\(span(Brightness.percentRange))>
      \(CLIKeyword.watch)
      \(CLIKeyword.shortHelp), \(CLIKeyword.help)
      \(CLIKeyword.version)
    """
    static let speakerNotFound = "Speaker not found"
    static let speakerOff = "Speaker is off"
    static let noReply = "Speaker did not reply"
    static let unexpectedReply = "Speaker sent an unexpected reply"
    static let disconnected = "disconnected"
    static let connectedPrefix = "connected: "
    static let unknown = "unknown"
    static let customEqualizer = "custom"
    static let builtInEqualizer = "built-in"
    static let lightingApplied = "lighting applied"
    static let developmentVersion = "dev"

    static func version(_ version: String?) -> String {
        programName + Format.wordSeparator + (version ?? developmentVersion)
    }

    static func failure(_ error: Error) -> String {
        guard let speakerError = error as? SpeakerError else { return error.localizedDescription }
        switch speakerError {
        case .transport(let code): return transportFailure(code)
        case .noReply: return noReply
        case .unexpectedReply: return unexpectedReply
        }
    }

    static func describe(_ state: SpeakerState) -> String {
        [
            subwoofer(state.subwoofer),
            equalizer(state.equalizer),
            brightness(state.brightness)
        ].joined(separator: Format.fieldSeparator)
    }

    static func subwoofer(_ level: SubwooferLevel?) -> String {
        field(Label.subwoofer, level.map { String($0.value) } ?? unknown)
    }

    static func equalizer(_ selection: EqualizerSelection?) -> String {
        field(Label.equalizer, equalizerName(selection))
    }

    static func brightness(_ brightness: Brightness?) -> String {
        field(Label.brightness, brightness.map { String($0.percent) + Format.percentSuffix } ?? unknown)
    }

    private static var presetChoices: String {
        EqualizerPreset.allCases.map(CLIKeyword.preset).joined(separator: Format.choiceSeparator)
    }

    private static func equalizerName(_ selection: EqualizerSelection?) -> String {
        switch selection {
        case .preset(let preset): return CLIKeyword.preset(preset)
        case .custom: return customEqualizer
        case .builtIn: return builtInEqualizer
        case nil: return unknown
        }
    }

    private static func field(_ label: String, _ value: String) -> String {
        label + Format.wordSeparator + value
    }

    private static func transportFailure(_ code: Int32) -> String {
        let hex = Format.hexPrefix + String(UInt32(bitPattern: code), radix: Format.hexRadix, uppercase: true)
        return "\(speakerOff) (\(Label.ioReturn) \(hex))"
    }

    private static func span(_ range: ClosedRange<Int>) -> String {
        "\(range.lowerBound)\(Format.rangeSeparator)\(range.upperBound)"
    }
}
