public struct SubwooferLevel: Equatable, Sendable {
    public static let range = 1...7

    public let value: Int

    public init?(_ value: Int) {
        guard Self.range.contains(value) else { return nil }
        self.value = value
    }
}
