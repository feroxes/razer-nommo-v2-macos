import Foundation

public final class SettingsStore: @unchecked Sendable {
    enum Key {
        static let lighting = "lighting"
        static let customCurve = "customCurve"
        static let launchAtLoginRequested = "launchAtLoginRequested"
        static let lastLaunchedVersion = "lastLaunchedVersion"
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

    public var launchAtLoginRequested: Bool? {
        get { load(Bool.self, key: Key.launchAtLoginRequested) }
        set { save(newValue, key: Key.launchAtLoginRequested) }
    }

    public var lastLaunchedVersion: String? {
        get { load(String.self, key: Key.lastLaunchedVersion) }
        set { save(newValue, key: Key.lastLaunchedVersion) }
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
