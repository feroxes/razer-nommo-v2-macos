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

    private(set) var isEnabled = false

    private let service = SMAppService.mainApp
    private let logger = Logger(subsystem: Log.subsystem, category: Log.category)

    init() {
        refresh()
    }

    func refresh() {
        isEnabled = service.status == .enabled
    }

    func setEnabled(_ enabled: Bool) {
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
}
