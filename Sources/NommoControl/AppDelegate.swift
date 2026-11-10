import AppKit
import NommoKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var updateController: UpdateController?
    private var statusItemController: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.mainMenu = EditMenu.makeMainMenu()
        let settings = SettingsStore(defaults: .standard)
        let model = SpeakerModel(settings: settings)
        model.start()
        let updateController = UpdateController()
        self.updateController = updateController
        statusItemController = StatusItemController(
            model: model,
            launchAtLogin: LaunchAtLogin(
                settings: settings,
                currentVersion: Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
            ),
            updates: updateController
        )
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
}
