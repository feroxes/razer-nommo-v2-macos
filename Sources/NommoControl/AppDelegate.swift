import AppKit
import NommoKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItemController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let model = SpeakerModel(settings: SettingsStore(defaults: .standard))
        model.start()
        statusItemController = StatusItemController(model: model, launchAtLogin: LaunchAtLogin())
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
}
