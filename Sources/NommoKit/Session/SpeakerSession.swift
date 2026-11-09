import Foundation

public final class SpeakerSession: Sendable {
    enum Retry {
        static let attempts = 3
        static let delay: TimeInterval = 0.5
    }

    private let device: NommoDevice
    private let settings: SettingsStore
    private let retryDelay: TimeInterval

    public convenience init(device: NommoDevice, settings: SettingsStore) {
        self.init(device: device, settings: settings, retryDelay: Retry.delay)
    }

    init(device: NommoDevice, settings: SettingsStore, retryDelay: TimeInterval) {
        self.device = device
        self.settings = settings
        self.retryDelay = retryDelay
    }

    public func start() throws -> SpeakerState {
        let state = try readStateWithRetry()
        if case .custom(let curve) = state.equalizer {
            settings.customCurve = curve
        }
        try device.writeLighting(settings.lighting)
        return state
    }

    private func readStateWithRetry() throws -> SpeakerState {
        var attempt = 1
        while true {
            do {
                return try device.readState()
            } catch {
                if attempt >= Retry.attempts { throw error }
                attempt += 1
                Thread.sleep(forTimeInterval: retryDelay)
            }
        }
    }
}
