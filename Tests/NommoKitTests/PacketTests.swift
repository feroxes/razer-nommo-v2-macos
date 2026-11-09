import Testing
@testable import NommoKit

@Suite("Packet")
struct PacketTests {
    private static func subwooferReply(status: UInt8) -> [UInt8] {
        [0x07, status, 0x1F, 0x00, 0x00, 0x00, 0x02, 0x08, 0x87, 0x00, 0x02] + Array(repeating: 0x00, count: 80)
    }

    @Test("Request has report id, header, arguments and checksum")
    func request() {
        let serial = Packet.request(for: CommandFrame(commandClass: 0x00, commandID: 0x82, size: 0x16, arguments: []))
        #expect(serial.count == 91)
        #expect(Array(serial[0...8]) == [0x07, 0x00, 0x1F, 0x00, 0x00, 0x00, 0x16, 0x00, 0x82])
        #expect(serial[89] == 0x94)
        #expect(serial[90] == 0x00)
        let subwoofer = Packet.request(for: CommandFrame(commandClass: 0x08, commandID: 0x07, size: 0x02, arguments: [0x00, 0x02]))
        #expect(Array(subwoofer[9...10]) == [0x00, 0x02])
        #expect(subwoofer[89] == 0x0F)
    }

    @Test("Reply exposes status, command and 80 argument bytes")
    func reply() {
        let reply = Packet.reply(from: Self.subwooferReply(status: 0x02))
        #expect(reply?.status == 0x02)
        #expect(reply?.commandID == 0x87)
        #expect(reply?.arguments.count == 80)
        #expect(Array(reply?.arguments.prefix(2) ?? []) == [0x00, 0x02])
    }

    @Test("Reply without report id prefix is accepted")
    func replyWithoutReportID() {
        #expect(Packet.reply(from: Array(Self.subwooferReply(status: 0x02).dropFirst()))?.commandID == 0x87)
    }

    @Test("Short reply is rejected")
    func shortReply() {
        #expect(Packet.reply(from: [0x07, 0x02]) == nil)
    }

    @Test("Busy reply is pending")
    func busyReply() {
        #expect(Packet.reply(from: Self.subwooferReply(status: 0x01))?.isPending == true)
    }
}
