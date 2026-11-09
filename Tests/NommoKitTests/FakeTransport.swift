@testable import NommoKit

final class FakeTransport: ReportTransport {
    private enum Response {
        static let successStatus: UInt8 = 0x02
        static let readFlag: UInt8 = 0x80
        static let customModeArguments = [CommandCode.zeroByte, Fixture.customMode]
    }

    var memory: [UInt8: [UInt8: [UInt8]]]
    var sent: [[UInt8]] = []
    var failure: SpeakerError?
    var answerWithCommandID: UInt8?
    var failuresBeforeSuccess = 0

    init(memory: [UInt8: [UInt8: [UInt8]]]) {
        self.memory = memory
    }

    func exchange(_ request: [UInt8]) throws -> [UInt8] {
        sent.append(request)
        if failuresBeforeSuccess > 0 {
            failuresBeforeSuccess -= 1
            throw SpeakerError.noReply
        }
        if let failure {
            throw failure
        }
        let commandClass = request[PacketLayout.classIndex]
        let commandID = request[PacketLayout.commandIDIndex]
        remember(request, commandClass: commandClass, commandID: commandID)

        var response = request
        response[PacketLayout.statusIndex] = Response.successStatus
        let stored = memory[commandClass]?[commandID] ?? []
        for offset in 0..<PacketLayout.argumentsCapacity {
            response[PacketLayout.argumentsStart + offset] = offset < stored.count ? stored[offset] : PacketLayout.padding
        }
        if let answerWithCommandID {
            response[PacketLayout.commandIDIndex] = answerWithCommandID
        }
        return response
    }

    private func remember(_ request: [UInt8], commandClass: UInt8, commandID: UInt8) {
        guard commandID & Response.readFlag == 0 else { return }
        let size = Int(request[PacketLayout.sizeIndex])
        let arguments = Array(request[PacketLayout.argumentsStart..<PacketLayout.argumentsStart + size])
        memory[commandClass, default: [:]][commandID | Response.readFlag] = arguments
        if commandClass == CommandCode.audioClass && commandID == CommandCode.writeEqualizerCurveID {
            memory[commandClass, default: [:]][CommandCode.readEqualizerModeID] = Response.customModeArguments
        }
    }
}
