import Foundation

public final class SettingsStore: @unchecked Sendable {
    enum Key {
        static let lighting = "lighting"
        static let customCurve = "customCurve"
    }

    let defaults: UserDefaults

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    public var lighting: LightingMode {
        get { load(LightingMode.self, key: Key.lighting) ?? .spectrum }
        set { save(newValue, key: Key.lighting) }
    }

    public var customCurve: EqualizerCurve {
        get { load(EqualizerCurve.self, key: Key.customCurve) ?? .flat }
        set { save(newValue, key: Key.customCurve) }
    }

    private func load<Value: Decodable>(_ type: Value.Type, key: String) -> Value? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func save<Value: Encodable>(_ value: Value, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }
}
