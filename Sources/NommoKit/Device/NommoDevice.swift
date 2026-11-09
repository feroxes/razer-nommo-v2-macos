public final class NommoDevice: @unchecked Sendable {
    private enum ArgumentIndex {
        static let subwoofer = 1
        static let equalizerMode = 1
        static let equalizerBands = 1...EqualizerCurve.bandCount
        static let brightness = 2
    }

    private let transport: ReportTransport

    init(transport: ReportTransport) {
        self.transport = transport
    }

    public func readState() throws -> SpeakerState {
        SpeakerState(
            subwoofer: try readSubwoofer(),
            equalizer: try readEqualizer(),
            brightness: try readBrightness()
        )
    }

    @discardableResult
    public func writeSubwoofer(_ level: SubwooferLevel) throws -> SubwooferLevel? {
        try send(.writeSubwoofer(level))
        return try readSubwoofer()
    }

    @discardableResult
    public func writeEqualizer(_ curve: EqualizerCurve) throws -> EqualizerSelection? {
        try send(.writeEqualizerCurve(curve))
        return try readEqualizer()
    }

    @discardableResult
    public func writeBrightness(_ brightness: Brightness) throws -> Brightness? {
        try send(.writeBrightness(brightness))
        return try readBrightness()
    }

    public func writeLighting(_ mode: LightingMode) throws {
        switch mode {
        case .spectrum:
            try send(.resumeAnimation)
        case .staticColor(let color):
            try send(.enterFrameMode)
            try send(.fillFrame(color))
        }
    }

    private func readSubwoofer() throws -> SubwooferLevel? {
        let reply = try send(.readSubwoofer)
        return SubwooferLevel(Int(reply.arguments[ArgumentIndex.subwoofer]))
    }

    private func readEqualizer() throws -> EqualizerSelection? {
        let mode = EqualizerMode(byte: try send(.readEqualizerMode).arguments[ArgumentIndex.equalizerMode])
        if mode == .builtIn {
            return .builtIn
        }
        let bands = Array(try send(.readEqualizerCurve).arguments[ArgumentIndex.equalizerBands])
        guard let curve = EqualizerCurve(bytes: bands) else { return nil }
        return EqualizerSelection(mode: mode, curve: curve)
    }

    private func readBrightness() throws -> Brightness? {
        Brightness(byte: try send(.readBrightness).arguments[ArgumentIndex.brightness])
    }

    @discardableResult
    private func send(_ command: SpeakerCommand) throws -> Reply {
        let frame = command.frame
        let raw = try transport.exchange(Packet.request(for: frame))
        guard let reply = Packet.reply(from: raw) else { throw SpeakerError.noReply }
        guard reply.commandClass == frame.commandClass, reply.commandID == frame.commandID else {
            throw SpeakerError.unexpectedReply
        }
        return reply
    }
}
