import Testing
@testable import NommoKit

@Suite("Auto power-off")
struct PowerTests {
    private static let sixtyMinutes: [UInt8] = [0x0E, 0x10]
    private static let unknownSwitch: UInt8 = 0x07

    private static func speaker(powerSaving: UInt8 = 0x01, delay: [UInt8] = [0x03, 0x84]) -> FakeTransport {
        .speaker(
            subwoofer: Fixture.subwooferByte,
            equalizerMode: Fixture.customMode,
            curve: Fixture.musicBytes,
            brightness: Fixture.brightnessByte,
            powerSaving: powerSaving,
            powerOffDelay: delay
        )
    }

    @Test("Delays are 15, 30 and 45 minutes in seconds")
    func delays() {
        #expect(PowerOffDelay.allCases.map(\.minutes) == [15, 30, 45])
        #expect(PowerOffDelay(minutes: 30) == .thirtyMinutes)
        #expect(PowerOffDelay(minutes: 60) == nil)
        #expect(PowerOffDelay.fortyFiveMinutes.bytes == [0x0A, 0x8C])
        #expect(PowerOffDelay(bytes: [0x07, 0x08]) == .thirtyMinutes)
        #expect(PowerOffDelay(bytes: Self.sixtyMinutes) == nil)
    }

    @Test("Each power command builds its wire frame")
    func frames() {
        let cases: [(SpeakerCommand, CommandFrame)] = [
            (.readPowerSaving, CommandFrame(commandClass: 0x07, commandID: 0x88, size: 0x02, arguments: [])),
            (.writePowerSaving(true), CommandFrame(commandClass: 0x07, commandID: 0x08, size: 0x02, arguments: [0x00, 0x01])),
            (.writePowerSaving(false), CommandFrame(commandClass: 0x07, commandID: 0x08, size: 0x02, arguments: [0x00, 0x00])),
            (.readPowerOffDelay, CommandFrame(commandClass: 0x07, commandID: 0x83, size: 0x02, arguments: [])),
            (.writePowerOffDelay(.thirtyMinutes), CommandFrame(commandClass: 0x07, commandID: 0x03, size: 0x02, arguments: [0x07, 0x08]))
        ]
        for (command, expected) in cases {
            #expect(command.frame == expected)
        }
    }

    @Test("State includes the power-off switch and delay")
    func readState() throws {
        let state = try NommoDevice(transport: Self.speaker()).readState()
        #expect(state.autoPowerOff == AutoPowerOff(isEnabled: true, delay: .fifteenMinutes))
    }

    @Test("Unknown delay reads as nil and unknown switch as no state")
    func unknownValues() throws {
        let unknownDelay = try NommoDevice(transport: Self.speaker(delay: Self.sixtyMinutes)).readState()
        #expect(unknownDelay.autoPowerOff == AutoPowerOff(isEnabled: true, delay: nil))
        let unknownSwitch = try NommoDevice(transport: Self.speaker(powerSaving: Self.unknownSwitch)).readState()
        #expect(unknownSwitch.autoPowerOff == nil)
    }

    @Test("Switch is written and read back")
    func writeSwitch() throws {
        let fake = Self.speaker()
        #expect(try NommoDevice(transport: fake).writePowerSaving(false) == AutoPowerOff(isEnabled: false, delay: .fifteenMinutes))
        #expect(fake.sent.contains(Packet.request(for: SpeakerCommand.writePowerSaving(false).frame)))
    }

    @Test("Delay is written and read back")
    func writeDelay() throws {
        let fake = Self.speaker()
        #expect(try NommoDevice(transport: fake).writePowerOffDelay(.fortyFiveMinutes) == AutoPowerOff(isEnabled: true, delay: .fortyFiveMinutes))
        #expect(fake.sent.contains(Packet.request(for: SpeakerCommand.writePowerOffDelay(.fortyFiveMinutes).frame)))
    }
}
