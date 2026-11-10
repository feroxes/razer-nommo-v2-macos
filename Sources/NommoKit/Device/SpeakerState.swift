public struct SpeakerState: Equatable, Sendable {
    public let subwoofer: SubwooferLevel?
    public let equalizer: EqualizerSelection?
    public let brightness: Brightness?
    public let autoPowerOff: AutoPowerOff?

    public init(subwoofer: SubwooferLevel?, equalizer: EqualizerSelection?, brightness: Brightness?, autoPowerOff: AutoPowerOff?) {
        self.subwoofer = subwoofer
        self.equalizer = equalizer
        self.brightness = brightness
        self.autoPowerOff = autoPowerOff
    }
}
