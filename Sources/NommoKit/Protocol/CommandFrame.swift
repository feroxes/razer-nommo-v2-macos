struct CommandFrame: Equatable, Sendable {
    let commandClass: UInt8
    let commandID: UInt8
    let size: UInt8
    let arguments: [UInt8]
}
