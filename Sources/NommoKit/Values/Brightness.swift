public struct Brightness: Equatable, Codable, Sendable {
    public static let percentRange = 0...100
    public static let off = Brightness(clamping: percentRange.lowerBound)
    public static let full = Brightness(clamping: percentRange.upperBound)
    static let maxByte = 255

    public let percent: Int

    public var isOff: Bool {
        percent == Self.percentRange.lowerBound
    }

    private enum CodingKeys: String, CodingKey {
        case percent
    }

    public init(clamping percent: Int) {
        let range = Self.percentRange
        self.percent = min(max(percent, range.lowerBound), range.upperBound)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(clamping: try container.decode(Int.self, forKey: .percent))
    }

    init(byte: UInt8) {
        let scaled = Double(Int(byte) * Self.percentRange.upperBound) / Double(Self.maxByte)
        self.init(clamping: Int(scaled.rounded()))
    }

    var byte: UInt8 {
        UInt8(percent * Self.maxByte / Self.percentRange.upperBound)
    }
}
