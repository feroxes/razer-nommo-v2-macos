public struct SpeakerState: Equatable, Sendable {
    public let subwoofer: SubwooferLevel?
    public let equalizer: EqualizerSelection?
    public let brightness: Brightness?

    public init(subwoofer: SubwooferLevel?, equalizer: EqualizerSelection?, brightness: Brightness?) {
        self.subwoofer = subwoofer
        self.equalizer = equalizer
        self.brightness = brightness
    }
}
