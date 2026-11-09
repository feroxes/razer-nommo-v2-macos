enum EqualizerMode: Equatable, Sendable {
    static let customByte: UInt8 = 0x10

    case custom
    case builtIn

    init(byte: UInt8) {
        self = byte == Self.customByte ? .custom : .builtIn
    }
}
