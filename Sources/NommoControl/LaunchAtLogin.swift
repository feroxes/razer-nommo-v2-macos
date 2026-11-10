import NommoKit
import Observation
import OSLog
import ServiceManagement

@MainActor
@Observable
final class LaunchAtLogin {
    private enum Log {
        static let subsystem = AppIdentifier.bundle
        static let category = "LaunchAtLogin"
    }

    private static let translocationMarker = "/AppTranslocation/"

    private(set) var isEnabled = false

    private let service = SMAppService.mainApp
    private let settings: SettingsStore
    private let logger = Logger(subsystem: Log.subsystem, category: Log.category)

    init(settings: SettingsStore, currentVersion: String?) {
        self.settings = settings
        let isRequested = settings.launchAtLoginRequested ?? (service.status == .enabled)
        settings.launchAtLoginRequested = isRequested
        if let currentVersion, !Self.isTranslocated {
            renewIfNeeded(currentVersion: currentVersion, isRequested: isRequested)
            settings.lastLaunchedVersion = currentVersion
        }
        refresh()
    }

    func refresh() {
        let enabled = service.status == .enabled
        isEnabled = enabled
        settings.launchAtLoginRequested = enabled
    }

    func setEnabled(_ enabled: Bool) {
        settings.launchAtLoginRequested = enabled
        do {
            if enabled {
                try service.register()
            } else {
                try service.unregister()
            }
        } catch {
            logger.error("\(error.localizedDescription, privacy: .public)")
        }
        refresh()
        if enabled, service.status == .requiresApproval {
            SMAppService.openSystemSettingsLoginItems()
        }
    }

    private static var isTranslocated: Bool {
        Bundle.main.bundlePath.contains(translocationMarker)
    }

    private func renewIfNeeded(currentVersion: String, isRequested: Bool) {
        let previousVersion = settings.lastLaunchedVersion
        guard LaunchAtLoginRenewal.isNeeded(previousVersion: previousVersion, currentVersion: currentVersion, isRequested: isRequested) else { return }
        renew()
    }

    private func renew() {
        try? service.unregister()
        do {
            try service.register()
        } catch {
            logger.error("\(error.localizedDescription, privacy: .public)")
        }
    }
}
