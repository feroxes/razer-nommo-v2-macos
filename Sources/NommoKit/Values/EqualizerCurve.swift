public struct EqualizerCurve: Equatable, Codable, Sendable {
    public static let bandCount = 10
    public static let gainRange = -12...12
    static let neutralGain = 0
    static let byteOffset = 0x0C
    static let maxByte: UInt8 = 0x18

    static let flat = EqualizerCurve(fitting: [])

    public let gains: [Int]

    private enum CodingKeys: String, CodingKey {
        case gains
    }

    private static let wrongBandCountDescription = "Wrong band count"

    public init?(clamping gains: [Int]) {
        guard gains.count == Self.bandCount else { return nil }
        self.init(fitting: gains)
    }

    init(fitting gains: [Int]) {
        let padded = gains + Array(repeating: Self.neutralGain, count: Self.bandCount)
        self.gains = padded.prefix(Self.bandCount).map(Self.clamped)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decoded = try container.decode([Int].self, forKey: .gains)
        guard let curve = EqualizerCurve(clamping: decoded) else {
            throw DecodingError.dataCorruptedError(forKey: .gains, in: container, debugDescription: Self.wrongBandCountDescription)
        }
        self = curve
    }

    init?(bytes: [UInt8]) {
        guard bytes.count == Self.bandCount, bytes.allSatisfy({ $0 <= Self.maxByte }) else { return nil }
        self.init(fitting: bytes.map { Int($0) - Self.byteOffset })
    }

    var bytes: [UInt8] {
        gains.map { UInt8($0 + Self.byteOffset) }
    }

    private static func clamped(_ gain: Int) -> Int {
        min(max(gain, gainRange.lowerBound), gainRange.upperBound)
    }
}
