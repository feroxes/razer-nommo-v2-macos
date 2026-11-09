extension LightingMode: Codable {
    private enum CodingKeys: String, CodingKey {
        case kind
        case color
    }

    private enum Kind: String, Codable {
        case spectrum
        case staticColor
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .kind) {
        case .spectrum:
            self = .spectrum
        case .staticColor:
            self = .staticColor(try container.decode(LightColor.self, forKey: .color))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .spectrum:
            try container.encode(Kind.spectrum, forKey: .kind)
        case .staticColor(let color):
            try container.encode(Kind.staticColor, forKey: .kind)
            try container.encode(color, forKey: .color)
        }
    }
}
