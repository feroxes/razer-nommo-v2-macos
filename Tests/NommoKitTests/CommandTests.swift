import Testing
@testable import NommoKit

@Suite("Commands")
struct CommandTests {
    private static let tintPixel: [UInt8] = [0x12, 0x34, 0x56]

    @Test("Each command builds its wire frame")
    func frames() throws {
        let level = try #require(SubwooferLevel(2))
        let cases: [(SpeakerCommand, CommandFrame)] = [
            (.readSubwoofer, CommandFrame(commandClass: 0x08, commandID: 0x87, size: 0x02, arguments: [])),
            (.writeSubwoofer(level), CommandFrame(commandClass: 0x08, commandID: 0x07, size: 0x02, arguments: [0x00, 0x02])),
            (.readEqualizerMode, CommandFrame(commandClass: 0x08, commandID: 0x82, size: 0x02, arguments: [])),
            (.readEqualizerCurve, CommandFrame(commandClass: 0x08, commandID: 0x84, size: 0x0B, arguments: [])),
            (.writeEqualizerCurve(EqualizerPreset.music.curve), CommandFrame(commandClass: 0x08, commandID: 0x04, size: 0x0B, arguments: [0x00] + Fixture.musicBytes)),
            (.readBrightness, CommandFrame(commandClass: 0x0F, commandID: 0x84, size: 0x03, arguments: [0x01, 0x00])),
            (.writeBrightness(Brightness(byte: 0xE5)), CommandFrame(commandClass: 0x0F, commandID: 0x04, size: 0x03, arguments: [0x01, 0x00, 0xE5])),
            (.enterFrameMode, CommandFrame(commandClass: 0x0F, commandID: 0x02, size: 0x06, arguments: [0x00, 0x00, 0x08, 0x00, 0x01])),
            (.resumeAnimation, CommandFrame(commandClass: 0x0F, commandID: 0x02, size: 0x06, arguments: [0x00, 0x00, 0x00])),
            (.fillFrame(Fixture.tint), CommandFrame(commandClass: 0x0F, commandID: 0x03, size: 0x29, arguments: [0x00, 0x00, 0x00, 0x00, 0x0B] + Array(Array(repeating: Self.tintPixel, count: 12).joined())))
        ]
        for (command, expected) in cases {
            #expect(command.frame == expected)
        }
    }

    @Test("Fill frame carries 41 arguments ending with an RGB pixel")
    func fillFrame() {
        let fill = SpeakerCommand.fillFrame(Fixture.tint).frame
        #expect(fill.arguments.count == 41)
        #expect(Array(fill.arguments.suffix(3)) == Self.tintPixel)
    }
}
