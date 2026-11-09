import Testing
@testable import NommoKit

@Suite("Device")
struct DeviceTests {
    private static let transportFailure = Int32(bitPattern: 0xE000_02D6)
    private static let unknownCommandID: UInt8 = 0x99

    private static func musicSpeaker() -> FakeTransport {
        .speaker(subwoofer: Fixture.subwooferByte, equalizerMode: Fixture.customMode, curve: Fixture.musicBytes, brightness: Fixture.brightnessByte)
    }

    @Test("Reads subwoofer, equalizer and brightness")
    func readState() throws {
        let device = NommoDevice(transport: Self.musicSpeaker())
        #expect(try device.readState() == SpeakerState(subwoofer: SubwooferLevel(2), equalizer: .preset(.music), brightness: Brightness(byte: 0xE5)))
    }

    @Test("Subwoofer is written and read back")
    func writeSubwoofer() throws {
        let fake = Self.musicSpeaker()
        let level = try #require(SubwooferLevel(7))
        #expect(try NommoDevice(transport: fake).writeSubwoofer(level) == level)
        #expect(fake.sent.contains(Packet.request(for: SpeakerCommand.writeSubwoofer(level).frame)))
    }

    @Test("Equalizer is written and resolved to a preset")
    func writeEqualizer() throws {
        #expect(try NommoDevice(transport: Self.musicSpeaker()).writeEqualizer(EqualizerPreset.game.curve) == .preset(.game))
    }

    @Test("Static color enters frame mode then fills the frame")
    func staticColor() throws {
        let fake = Self.musicSpeaker()
        try NommoDevice(transport: fake).writeLighting(.staticColor(Fixture.tint))
        #expect(fake.sent == [Packet.request(for: SpeakerCommand.enterFrameMode.frame), Packet.request(for: SpeakerCommand.fillFrame(Fixture.tint).frame)])
    }

    @Test("Spectrum resumes the animation")
    func spectrum() throws {
        let fake = Self.musicSpeaker()
        try NommoDevice(transport: fake).writeLighting(.spectrum)
        #expect(fake.sent == [Packet.request(for: SpeakerCommand.resumeAnimation.frame)])
    }

    @Test("Zero replies still parse and report the built-in equalizer")
    func zeroReplies() {
        let fake = FakeTransport.speaker(subwoofer: 0x00, equalizerMode: Fixture.builtInMode, curve: EqualizerCurve.flat.bytes, brightness: 0x00)
        let state = try? NommoDevice(transport: fake).readState()
        #expect(state != nil)
        #expect(state?.subwoofer == nil)
        #expect(state?.equalizer == .builtIn)
    }

    @Test("Transport error propagates")
    func transportError() {
        let broken = FakeTransport(memory: [:])
        broken.failure = .transport(Self.transportFailure)
        #expect(throws: SpeakerError.transport(Self.transportFailure)) {
            try NommoDevice(transport: broken).readState()
        }
    }

    @Test("Reply for another command is rejected")
    func mismatchedReply() {
        let mismatched = FakeTransport(memory: [:])
        mismatched.answerWithCommandID = Self.unknownCommandID
        #expect(throws: SpeakerError.unexpectedReply) {
            try NommoDevice(transport: mismatched).readState()
        }
    }
}
