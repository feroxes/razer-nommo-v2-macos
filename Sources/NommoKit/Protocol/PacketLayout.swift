enum PacketLayout {
    static let reportID: UInt8 = 0x07
    static let reportIDIndex = 0
    static let padding: UInt8 = 0x00
    static let checksumSeed: UInt8 = 0x00
    static let length = 91
    static let transactionID: UInt8 = 0x1F
    static let statusIndex = 1
    static let transactionIndex = 2
    static let sizeIndex = 6
    static let classIndex = 7
    static let commandIDIndex = 8
    static let argumentsStart = 9
    static let argumentsCapacity = 80
    static let argumentsEnd = argumentsStart + argumentsCapacity
    static let checksumIndex = 89
    static let checksumRange = 3...88
    static let minimumBodyLength = length - 1
    static let pendingStatuses: Set<UInt8> = [0x00, 0x01]
}
