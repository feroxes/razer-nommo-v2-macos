enum SpeakerCommand: Equatable, Sendable {
    case readSubwoofer
    case writeSubwoofer(SubwooferLevel)
    case readEqualizerMode
    case readEqualizerCurve
    case writeEqualizerCurve(EqualizerCurve)
    case readBrightness
    case writeBrightness(Brightness)
    case enterFrameMode
    case fillFrame(LightColor)
    case resumeAnimation

    var frame: CommandFrame {
        switch self {
        case .readSubwoofer:
            return audio(CommandCode.readSubwooferID, CommandCode.subwooferSize)
        case .writeSubwoofer(let level):
            return audio(CommandCode.writeSubwooferID, CommandCode.subwooferSize, [CommandCode.zeroByte, UInt8(level.value)])
        case .readEqualizerMode:
            return audio(CommandCode.readEqualizerModeID, CommandCode.equalizerModeSize)
        case .readEqualizerCurve:
            return audio(CommandCode.readEqualizerCurveID, CommandCode.equalizerCurveSize)
        case .writeEqualizerCurve(let curve):
            return audio(CommandCode.writeEqualizerCurveID, CommandCode.equalizerCurveSize, [CommandCode.zeroByte] + curve.bytes)
        case .readBrightness:
            return lighting(CommandCode.readBrightnessID, CommandCode.brightnessSize, CommandCode.brightnessPrefix)
        case .writeBrightness(let brightness):
            return lighting(CommandCode.writeBrightnessID, CommandCode.brightnessSize, CommandCode.brightnessPrefix + [brightness.byte])
        case .enterFrameMode:
            return lighting(CommandCode.animationID, CommandCode.animationSize, CommandCode.enterFrameModeArguments)
        case .fillFrame(let color):
            let pixels = Array([[UInt8]](repeating: [color.red, color.green, color.blue], count: CommandCode.ledCount).joined())
            return lighting(CommandCode.fillFrameID, CommandCode.fillFrameSize, CommandCode.fillFramePrefix + pixels)
        case .resumeAnimation:
            return lighting(CommandCode.animationID, CommandCode.animationSize, CommandCode.resumeAnimationArguments)
        }
    }

    private func audio(_ id: UInt8, _ size: UInt8, _ arguments: [UInt8] = []) -> CommandFrame {
        CommandFrame(commandClass: CommandCode.audioClass, commandID: id, size: size, arguments: arguments)
    }

    private func lighting(_ id: UInt8, _ size: UInt8, _ arguments: [UInt8] = []) -> CommandFrame {
        CommandFrame(commandClass: CommandCode.lightingClass, commandID: id, size: size, arguments: arguments)
    }
}
