import Foundation
import Testing
@testable import NommoKit

@Suite("Session")
struct SessionTests {
    private static let noDelay: TimeInterval = 0
    private static let readFlag: UInt8 = 0x80

    private static func oddSpeaker() throws -> (FakeTransport, EqualizerCurve) {
        let odd = try #require(EqualizerCurve(clamping: Fixture.unknownGains))
        let fake = FakeTransport.speaker(subwoofer: Fixture.subwooferByte, equalizerMode: Fixture.customMode, curve: odd.bytes, brightness: Fixture.brightnessByte)
        return (fake, odd)
    }

    private static func start(_ fake: FakeTransport, settings: SettingsStore = SettingsStore(defaults: InMemoryDefaults())) throws -> SpeakerState {
        try SpeakerSession(device: NommoDevice(transport: fake), settings: settings, retryDelay: noDelay).start()
    }

    @Test("Lighting defaults to spectrum and persists")
    func lightingPersists() {
        let store = SettingsStore(defaults: InMemoryDefaults())
        #expect(store.lighting == .spectrum)
        store.lighting = .staticColor(Fixture.cyan)
        #expect(SettingsStore(defaults: store.defaults).lighting == .staticColor(Fixture.cyan))
    }

    @Test("Unknown stored value falls back to spectrum", arguments: [
        #"{"breathing":{"_0":{"red":68,"green":214,"blue":44}}}"#,
        #"{"staticColor":{"_0":{"red":0,"green":255,"blue":255}}}"#,
        #"{"kind":"breathing"}"#
    ])
    func unknownLightingFallsBack(stored: String) {
        let store = SettingsStore(defaults: InMemoryDefaults())
        store.defaults.set(Data(stored.utf8), forKey: SettingsStore.Key.lighting)
        #expect(store.lighting == .spectrum)
    }

    @Test("Lighting is stored with readable keys")
    func readableLighting() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let staticColor = String(decoding: try encoder.encode(LightingMode.staticColor(Fixture.cyan)), as: UTF8.self)
        #expect(staticColor == #"{"color":{"blue":255,"green":255,"red":0},"kind":"staticColor"}"#)
        #expect(String(decoding: try encoder.encode(LightingMode.spectrum), as: UTF8.self) == #"{"kind":"spectrum"}"#)
    }

    @Test("Connect reports and saves an unknown curve and applies stored lighting without audio writes")
    func connect() throws {
        let (fake, odd) = try Self.oddSpeaker()
        let settings = SettingsStore(defaults: InMemoryDefaults())
        settings.lighting = .staticColor(Fixture.violet)
        let state = try Self.start(fake, settings: settings)
        #expect(state.equalizer == .custom(odd))
        #expect(settings.customCurve == odd)
        #expect(fake.sent.last == Packet.request(for: SpeakerCommand.fillFrame(Fixture.violet).frame))
        #expect(!fake.sent.contains { $0[PacketLayout.commandIDIndex] & Self.readFlag == 0 && $0[PacketLayout.classIndex] == CommandCode.audioClass })
    }

    @Test("Retries after power-on errors")
    func retries() throws {
        let (fake, _) = try Self.oddSpeaker()
        fake.failuresBeforeSuccess = 2
        #expect((try? Self.start(fake)) != nil)
    }

    @Test("Gives up after three attempts")
    func givesUp() throws {
        let (fake, _) = try Self.oddSpeaker()
        fake.failuresBeforeSuccess = 5
        #expect((try? Self.start(fake)) == nil)
    }
}
