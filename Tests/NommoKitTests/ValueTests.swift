import Foundation
import Testing
@testable import NommoKit

@Suite("Values")
struct ValueTests {
    private static let decoder = JSONDecoder()

    @Test("Subwoofer level accepts 1 to 7 only")
    func subwooferLevel() {
        #expect(SubwooferLevel(0) == nil)
        #expect(SubwooferLevel(8) == nil)
        #expect(SubwooferLevel(7)?.value == 7)
    }

    @Test("Curve converts between gains and bytes")
    func curveBytes() {
        #expect(EqualizerPreset.music.curve.bytes == Fixture.musicBytes)
        #expect(EqualizerCurve(bytes: Fixture.musicBytes)?.gains == Fixture.musicGains)
        #expect(EqualizerCurve(bytes: [0x19] + Array(repeating: 0x0C, count: 9)) == nil)
    }

    @Test("Curve needs ten bands and clamps gains to ±12")
    func curveGains() {
        #expect(EqualizerCurve(clamping: Array(repeating: 0, count: 9)) == nil)
        #expect(EqualizerCurve(clamping: [15] + Array(repeating: 0, count: 9))?.bytes.first == 0x18)
    }

    @Test("Flat curve has ten neutral bands")
    func flatCurve() {
        #expect(EqualizerCurve.flat.gains == Array(repeating: 0, count: 10))
    }

    @Test("Preset curves have ten bands and differ from each other")
    func presetCurves() {
        let curves = EqualizerPreset.allCases.map(\.curve.gains)
        #expect(curves.allSatisfy { $0.count == 10 })
        #expect(Set(curves).count == EqualizerPreset.allCases.count)
    }

    @Test("Four presets matched by curve")
    func presets() {
        #expect(EqualizerPreset.allCases.count == 4)
        #expect(EqualizerPreset(matching: EqualizerPreset.game.curve) == .game)
    }

    @Test("Selection resolves mode and curve")
    func selection() throws {
        let odd = try #require(EqualizerCurve(clamping: Fixture.unknownGains))
        #expect(EqualizerSelection(mode: .custom, curve: EqualizerPreset.music.curve) == .preset(.music))
        #expect(EqualizerSelection(mode: .custom, curve: odd) == .custom(odd))
        #expect(EqualizerSelection(mode: EqualizerMode(byte: Fixture.builtInMode), curve: .flat) == .builtIn)
        #expect(EqualizerMode(byte: Fixture.customMode) == .custom)
    }

    @Test("Brightness converts between percent and byte")
    func brightness() {
        #expect(Brightness(byte: 0xE5).percent == 90)
        #expect(Brightness.percentRange.allSatisfy { Brightness(byte: Brightness(clamping: $0).byte).percent == $0 })
        #expect(Brightness(clamping: 140).percent == 100)
    }

    @Test("Color parses six hex digits with or without hash")
    func hexColor() {
        #expect(LightColor(hex: "#00ffff") == LightColor(red: 0x00, green: 0xFF, blue: 0xFF))
        #expect(LightColor(hex: "FF8000") == LightColor(red: 0xFF, green: 0x80, blue: 0x00))
        #expect(LightColor(hex: "#0ff") == nil)
        #expect(LightColor(hex: "zzzzzz") == nil)
    }

    @Test("Lighting mode exposes its static color")
    func lightingColor() {
        #expect(LightingMode.spectrum.color == nil)
        #expect(LightingMode.staticColor(Fixture.cyan).color == Fixture.cyan)
    }

    @Test("Curve decoding rejects wrong band count, clamps gains and round-trips")
    func curveDecoding() throws {
        #expect(throws: DecodingError.self) {
            try Self.decoder.decode(EqualizerCurve.self, from: Data(#"{"gains":[0,0,0,0,0,0,0,0,0]}"#.utf8))
        }
        let clamped = try Self.decoder.decode(EqualizerCurve.self, from: Data(#"{"gains":[-20,0,0,0,0,0,0,0,0,0]}"#.utf8))
        #expect(clamped.bytes.allSatisfy { $0 <= EqualizerCurve.maxByte })
        let movie = EqualizerPreset.movie.curve
        #expect(try Self.decoder.decode(EqualizerCurve.self, from: JSONEncoder().encode(movie)) == movie)
    }

    @Test("Brightness decoding clamps percent")
    func brightnessDecoding() throws {
        #expect(try Self.decoder.decode(Brightness.self, from: Data(#"{"percent":500}"#.utf8)).percent == 100)
        #expect(try Self.decoder.decode(Brightness.self, from: Data(#"{"percent":-5}"#.utf8)).byte == 0)
    }
}
