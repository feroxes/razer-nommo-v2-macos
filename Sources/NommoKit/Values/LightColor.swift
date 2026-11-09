public struct LightColor: Equatable, Codable, Sendable {
    private enum Channel: Int, CaseIterable {
        case red
        case green
        case blue
    }

    private static let hexPrefix: Character = "#"
    private static let hexRadix = 16
    private static let digitsPerChannel = 2
    private static let hexDigitCount = Channel.allCases.count * digitsPerChannel

    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8

    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public init?(hex: String) {
        let digits = hex.first == Self.hexPrefix ? String(hex.dropFirst()) : hex
        guard digits.count == Self.hexDigitCount,
              let red = Self.channel(.red, in: digits),
              let green = Self.channel(.green, in: digits),
              let blue = Self.channel(.blue, in: digits)
        else { return nil }
        self.init(red: red, green: green, blue: blue)
    }

    private static func channel(_ channel: Channel, in digits: String) -> UInt8? {
        let from = digits.index(digits.startIndex, offsetBy: channel.rawValue * digitsPerChannel)
        let to = digits.index(from, offsetBy: digitsPerChannel)
        let pair = digits[from..<to]
        guard pair.allSatisfy({ $0.isHexDigit }) else { return nil }
        return UInt8(pair, radix: hexRadix)
    }
}
