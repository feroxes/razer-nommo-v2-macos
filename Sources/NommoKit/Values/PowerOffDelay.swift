public enum PowerOffDelay: Int, CaseIterable, Sendable {
    case fifteenMinutes = 900
    case thirtyMinutes = 1800
    case fortyFiveMinutes = 2700

    private static let secondsPerMinute = 60
    private static let byteBits = 8
    private static let byteMask = 0xFF
    private static let byteCount = 2

    public var minutes: Int {
        rawValue / Self.secondsPerMinute
    }

    public init?(minutes: Int) {
        self.init(rawValue: minutes * Self.secondsPerMinute)
    }

    init?(bytes: [UInt8]) {
        guard bytes.count >= Self.byteCount else { return nil }
        self.init(rawValue: Int(bytes[0]) << Self.byteBits | Int(bytes[1]))
    }

    var bytes: [UInt8] {
        [UInt8(rawValue >> Self.byteBits & Self.byteMask), UInt8(rawValue & Self.byteMask)]
    }
}
