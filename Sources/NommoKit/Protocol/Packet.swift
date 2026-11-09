enum Packet {
    static func request(for frame: CommandFrame) -> [UInt8] {
        var bytes = [UInt8](repeating: PacketLayout.padding, count: PacketLayout.length)
        bytes[PacketLayout.reportIDIndex] = PacketLayout.reportID
        bytes[PacketLayout.transactionIndex] = PacketLayout.transactionID
        bytes[PacketLayout.sizeIndex] = frame.size
        bytes[PacketLayout.classIndex] = frame.commandClass
        bytes[PacketLayout.commandIDIndex] = frame.commandID
        for (offset, byte) in frame.arguments.prefix(PacketLayout.argumentsCapacity).enumerated() {
            bytes[PacketLayout.argumentsStart + offset] = byte
        }
        bytes[PacketLayout.checksumIndex] = checksum(of: bytes)
        return bytes
    }

    static func checksum(of bytes: [UInt8]) -> UInt8 {
        bytes[PacketLayout.checksumRange].reduce(PacketLayout.checksumSeed, ^)
    }

    static func reply(from raw: [UInt8]) -> Reply? {
        let bytes: [UInt8]
        if raw.count >= PacketLayout.length && raw[PacketLayout.reportIDIndex] == PacketLayout.reportID {
            bytes = raw
        } else if raw.count >= PacketLayout.minimumBodyLength {
            bytes = [PacketLayout.reportID] + raw
        } else {
            return nil
        }
        return Reply(
            status: bytes[PacketLayout.statusIndex],
            commandClass: bytes[PacketLayout.classIndex],
            commandID: bytes[PacketLayout.commandIDIndex],
            arguments: Array(bytes[PacketLayout.argumentsStart..<PacketLayout.argumentsEnd])
        )
    }
}
