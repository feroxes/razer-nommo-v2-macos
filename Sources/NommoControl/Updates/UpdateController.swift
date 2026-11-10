import AppKit
import Observation
import Sparkle

@MainActor
@Observable
final class UpdateController: NSObject {
    private(set) var canCheckForUpdates = false
    private(set) var availableVersion: String?

    var checksAutomatically = false {
        didSet {
            guard checksAutomatically != updater.automaticallyChecksForUpdates else { return }
            updater.automaticallyChecksForUpdates = checksAutomatically
        }
    }

    @ObservationIgnored private var controller: SPUStandardUpdaterController!
    @ObservationIgnored private var observations: [NSKeyValueObservation] = []

    private var updater: SPUUpdater { controller.updater }

    override init() {
        super.init()
        controller = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: self)
        observations = [
            updater.observe(\.canCheckForUpdates, options: [.initial, .new]) { [weak self] updater, _ in
                MainActor.assumeIsolated { self?.canCheckForUpdates = updater.canCheckForUpdates }
            },
            updater.observe(\.automaticallyChecksForUpdates, options: [.initial, .new]) { [weak self] updater, _ in
                MainActor.assumeIsolated { self?.checksAutomatically = updater.automaticallyChecksForUpdates }
            }
        ]
    }

    func setAvailableVersion(_ version: String?) {
        availableVersion = version
    }

    func checkForUpdates() {
        NSApp.activate()
        controller.checkForUpdates(nil)
    }
}
