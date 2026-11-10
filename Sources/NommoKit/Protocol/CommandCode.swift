enum CommandCode {
    static let audioClass: UInt8 = 0x08
    static let lightingClass: UInt8 = 0x0F
    static let powerClass: UInt8 = 0x07

    static let subwooferSize: UInt8 = 0x02
    static let equalizerModeSize: UInt8 = 0x02
    static let equalizerCurveSize: UInt8 = 0x0B
    static let brightnessSize: UInt8 = 0x03
    static let animationSize: UInt8 = 0x06
    static let fillFrameSize: UInt8 = 0x29
    static let powerSavingSize: UInt8 = 0x02
    static let powerOffDelaySize: UInt8 = 0x02

    static let writeSubwooferID: UInt8 = 0x07
    static let readSubwooferID: UInt8 = 0x87
    static let readEqualizerModeID: UInt8 = 0x82
    static let writeEqualizerCurveID: UInt8 = 0x04
    static let readEqualizerCurveID: UInt8 = 0x84
    static let writeBrightnessID: UInt8 = 0x04
    static let readBrightnessID: UInt8 = 0x84
    static let animationID: UInt8 = 0x02
    static let fillFrameID: UInt8 = 0x03
    static let writePowerSavingID: UInt8 = 0x08
    static let readPowerSavingID: UInt8 = 0x88
    static let writePowerOffDelayID: UInt8 = 0x03
    static let readPowerOffDelayID: UInt8 = 0x83

    static let zeroByte: UInt8 = 0x00
    static let switchOn: UInt8 = 0x01
    static let switchOff: UInt8 = 0x00
    static let brightnessPrefix: [UInt8] = [0x01, 0x00]
    static let resumeAnimationArguments: [UInt8] = [0x00, 0x00, 0x00]
    static let enterFrameModeArguments: [UInt8] = [0x00, 0x00, 0x08, 0x00, 0x01]
    static let fillFramePrefix: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x0B]
    static let ledCount = 12
}
