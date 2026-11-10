import Foundation
import NommoKit
import Observation

@MainActor
@Observable
final class SpeakerModel {
    enum Connection {
        case disconnected
        case connected
    }

    private enum Initial {
        static let subwoofer = SubwooferLevel.range.lowerBound
        static let brightnessPercent = Brightness.percentRange.upperBound
    }

    private enum Queue {
        static let label = AppIdentifier.qualified("speaker")
    }

    private enum Recovery {
        static let reconnectDelay: TimeInterval = 2
    }

    private(set) var connection = Connection.disconnected
    var subwoofer = Initial.subwoofer
    private(set) var equalizer: EqualizerSelection?
    var customCurve: EqualizerCurve
    private(set) var lighting: LightingMode
    private(set) var lightingColor: LightColor
    var brightnessPercent = Initial.brightnessPercent
    private(set) var autoPowerOff: AutoPowerOff?

    private let settings: SettingsStore
    private let queue = DispatchQueue(label: Queue.label, qos: .userInitiated)
    @ObservationIgnored private var monitor: DeviceMonitor?
    @ObservationIgnored private var device: NommoDevice?
    @ObservationIgnored private var isWritingLighting = false
    @ObservationIgnored private var pendingLighting: LightingMode?
    @ObservationIgnored private var isReconnectPending = false
    @ObservationIgnored private var reconnectGeneration = 0

    init(settings: SettingsStore) {
        self.settings = settings
        customCurve = settings.customCurve
        lighting = settings.lighting
        lightingColor = settings.lighting.color ?? LightingPalette.initialStatic
    }

    func start() {
        let monitor = DeviceMonitor(
            onConnect: { [weak self] device in self?.connect(device) },
            onDisconnect: { [weak self] in self?.deviceRemoved() }
        )
        self.monitor = monitor
        monitor.start()
    }

    func refresh() {
        perform({ try $0.readState() }) { [weak self] state in
            self?.adopt(state)
        }
    }

    func commitSubwoofer() {
        guard let level = SubwooferLevel(subwoofer) else { return }
        perform({ try $0.writeSubwoofer(level) }) { [weak self] actual in
            if let actual { self?.subwoofer = actual.value }
        }
    }

    func selectPreset(_ preset: EqualizerPreset) {
        equalizer = .preset(preset)
        perform({ try $0.writeEqualizer(preset.curve) }) { [weak self] actual in
            self?.show(actual)
        }
    }

    func selectCustom() {
        writeCustomCurve(customCurve)
    }

    func commitCustomCurve() {
        settings.customCurve = customCurve
        writeCustomCurve(customCurve)
    }

    func commitBrightness() {
        let brightness = Brightness(clamping: brightnessPercent)
        brightnessPercent = brightness.percent
        perform({ try $0.writeBrightness(brightness) }) { [weak self] actual in
            if let actual { self?.brightnessPercent = actual.percent }
        }
    }

    func setPowerSaving(_ isEnabled: Bool) {
        autoPowerOff = AutoPowerOff(isEnabled: isEnabled, delay: autoPowerOff?.delay)
        perform({ try $0.writePowerSaving(isEnabled) }) { [weak self] actual in
            self?.showAutoPowerOff(actual)
        }
    }

    func selectPowerOffDelay(_ delay: PowerOffDelay) {
        guard let current = autoPowerOff else { return }
        autoPowerOff = AutoPowerOff(isEnabled: current.isEnabled, delay: delay)
        perform({ try $0.writePowerOffDelay(delay) }) { [weak self] actual in
            self?.showAutoPowerOff(actual)
        }
    }

    func setLighting(_ mode: LightingMode) {
        guard mode != lighting else { return }
        changeLighting(mode)
    }

    func selectColor(_ color: LightColor) {
        changeLighting(.staticColor(color))
    }

    private func changeLighting(_ mode: LightingMode) {
        lighting = mode
        lightingColor = mode.color ?? lightingColor
        settings.lighting = mode
        guard connection == .connected else { return }
        if isWritingLighting {
            pendingLighting = mode
        } else {
            writeLighting(mode)
        }
    }

    private func writeCustomCurve(_ curve: EqualizerCurve) {
        customCurve = curve
        equalizer = .custom(curve)
        perform({ try $0.writeEqualizer(curve) }) { [weak self] actual in
            self?.show(Self.keepingCustom(actual, written: curve))
        }
    }

    private func writeLighting(_ mode: LightingMode) {
        isWritingLighting = true
        perform({ try $0.writeLighting(mode) }) { [weak self] _ in
            self?.lightingWritten()
        }
    }

    private func lightingWritten() {
        isWritingLighting = false
        guard let next = pendingLighting else { return }
        pendingLighting = nil
        writeLighting(next)
    }

    private func connect(_ newDevice: NommoDevice) {
        cancelReconnect()
        device = newDevice
        connection = .disconnected
        resetLightingWrites()
        let session = SpeakerSession(device: newDevice, settings: settings)
        run(on: newDevice, { _ in try session.start() }) { [weak self] state in
            self?.adopt(state)
        }
    }

    private func deviceRemoved() {
        cancelReconnect()
        disconnect()
    }

    private func deviceFailed() {
        disconnect()
        scheduleReconnect()
    }

    private func disconnect() {
        device = nil
        connection = .disconnected
        resetLightingWrites()
    }

    private func scheduleReconnect() {
        guard !isReconnectPending else { return }
        isReconnectPending = true
        let generation = reconnectGeneration
        queue.asyncAfter(deadline: .now() + Recovery.reconnectDelay) {
            DispatchQueue.main.async {
                self.attemptReconnect(generation)
            }
        }
    }

    private func attemptReconnect(_ generation: Int) {
        guard isReconnectPending, generation == reconnectGeneration else { return }
        isReconnectPending = false
        guard let monitor, !monitor.reconnect() else { return }
        scheduleReconnect()
    }

    private func cancelReconnect() {
        reconnectGeneration += 1
        isReconnectPending = false
    }

    private func adopt(_ state: SpeakerState) {
        subwoofer = state.subwoofer?.value ?? subwoofer
        brightnessPercent = state.brightness?.percent ?? brightnessPercent
        show(state.equalizer)
        showAutoPowerOff(state.autoPowerOff)
        connection = .connected
    }

    private func showAutoPowerOff(_ state: AutoPowerOff?) {
        autoPowerOff = state ?? autoPowerOff
    }

    private func show(_ selection: EqualizerSelection?) {
        equalizer = selection
        if case .custom(let curve) = selection {
            customCurve = curve
        }
    }

    private func resetLightingWrites() {
        isWritingLighting = false
        pendingLighting = nil
    }

    private static func keepingCustom(_ selection: EqualizerSelection?, written curve: EqualizerCurve) -> EqualizerSelection? {
        guard case .preset(let preset) = selection, preset.curve == curve else { return selection }
        return .custom(curve)
    }

    private func perform<Value: Sendable>(_ work: @escaping @Sendable (NommoDevice) throws -> Value, then apply: @escaping @MainActor (Value) -> Void) {
        guard connection == .connected, let device else { return }
        run(on: device, work, then: apply)
    }

    private func run<Value: Sendable>(
        on device: NommoDevice,
        _ work: @escaping @Sendable (NommoDevice) throws -> Value,
        then apply: @escaping @MainActor (Value) -> Void
    ) {
        queue.async {
            let result = Result { try work(device) }
            DispatchQueue.main.async {
                self.finish(result, from: device, then: apply)
            }
        }
    }

    private func finish<Value: Sendable>(_ result: Result<Value, Error>, from source: NommoDevice, then apply: @MainActor (Value) -> Void) {
        guard source === device else { return }
        switch result {
        case .success(let value):
            apply(value)
        case .failure:
            deviceFailed()
        }
    }
}
