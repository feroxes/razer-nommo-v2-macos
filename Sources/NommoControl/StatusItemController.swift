import AppKit
import Observation
import SwiftUI

@MainActor
final class StatusItemController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let popover = NSPopover()
    private let model: SpeakerModel
    private let launchAtLogin: LaunchAtLogin
    private let updates: UpdateController

    init(model: SpeakerModel, launchAtLogin: LaunchAtLogin, updates: UpdateController) {
        self.model = model
        self.launchAtLogin = launchAtLogin
        self.updates = updates
        super.init()
        let content = NSHostingController(rootView: PanelView(
            model: model,
            launchAtLogin: launchAtLogin,
            updates: updates,
            actions: makeActions(updates: updates)
        ))
        content.sizingOptions = [.preferredContentSize]
        popover.contentViewController = content
        popover.behavior = .transient
        configureButton()
        trackIcon()
        closeWhenDeactivated()
    }

    private func makeActions(updates: UpdateController) -> PanelActions {
        PanelActions(
            showAbout: { [weak self] in
                self?.popover.performClose(nil)
                AboutPanel.show()
            },
            checkForUpdates: { [weak self] in
                self?.popover.performClose(nil)
                updates.checkForUpdates()
            },
            donate: { [weak self] in
                self?.popover.performClose(nil)
                guard let url = ProjectLinks.donation else { return }
                NSWorkspace.shared.open(url)
            },
            quit: { [weak self] in
                self?.popover.performClose(nil)
                NSApp.terminate(nil)
            }
        )
    }

    private func configureButton() {
        guard let button = statusItem.button else { return }
        button.target = self
        button.action = #selector(togglePopover)
    }

    private var icon: NSImage {
        updates.availableVersion == nil ? SpeakerGlyph.image : SpeakerGlyph.badgedImage
    }

    private func trackIcon() {
        let image = withObservationTracking {
            icon
        } onChange: { [weak self] in
            Task { @MainActor in self?.trackIcon() }
        }
        statusItem.button?.image = image
    }

    private func closeWhenDeactivated() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidResignActive),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
    }

    @objc private func applicationDidResignActive() {
        popover.performClose(nil)
    }

    @objc private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let button = statusItem.button else { return }
        launchAtLogin.refresh()
        model.refresh()
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }
}
