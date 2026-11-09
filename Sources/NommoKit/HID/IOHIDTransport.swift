import Foundation
import IOKit.hid

final class IOHIDTransport: ReportTransport {
    private let device: IOHIDDevice

    init(device: IOHIDDevice) {
        self.device = device
    }

    func exchange(_ request: [UInt8]) throws -> [UInt8] {
        try send(request)
        for _ in 0..<HIDConstants.maxReplyAttempts {
            usleep(HIDConstants.replyDelayMicroseconds)
            let raw = try receive()
            if let reply = Packet.reply(from: raw), !reply.isPending {
                return raw
            }
        }
        throw SpeakerError.noReply
    }

    private func send(_ request: [UInt8]) throws {
        try check(IOHIDDeviceSetReport(device, kIOHIDReportTypeFeature, CFIndex(PacketLayout.reportID), request, request.count))
    }

    private func receive() throws -> [UInt8] {
        var buffer = [UInt8](repeating: PacketLayout.padding, count: PacketLayout.length)
        var length = buffer.count
        let result = IOHIDDeviceGetReport(device, kIOHIDReportTypeFeature, CFIndex(PacketLayout.reportID), &buffer, &length)
        try check(result)
        return Array(buffer.prefix(length))
    }

    private func check(_ result: IOReturn) throws {
        guard result == kIOReturnSuccess else {
            throw SpeakerError.transport(result)
        }
    }
}
