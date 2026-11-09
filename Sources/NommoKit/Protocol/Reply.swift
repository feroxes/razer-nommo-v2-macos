struct Reply: Equatable, Sendable {
    let status: UInt8
    let commandClass: UInt8
    let commandID: UInt8
    let arguments: [UInt8]

    var isPending: Bool {
        PacketLayout.pendingStatuses.contains(status)
    }
}
