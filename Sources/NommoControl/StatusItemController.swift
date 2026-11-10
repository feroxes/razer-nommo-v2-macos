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
    private let colorPanel = ColorPanelController()
    private var outsideClickMonitor: Any?

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
        popover.delegate = self
        configureButton()
        trackIcon()
        trackConnection()
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
            pickColor: { [weak self] in
                self?.showColorPicker()
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

    private func showColorPicker() {
        popover.behavior = .applicationDefined
        closeOnOutsideClicks()
        colorPanel.show(
            color: model.lightingColor,
            beside: popover.contentViewController?.view.window,
            onChange: { [weak self] color in self?.model.selectColor(color) },
            onClose: { [weak self] in self?.colorPanelDidClose() }
        )
    }

    private func colorPanelDidClose() {
        popover.behavior = .transient
        if let outsideClickMonitor {
            NSEvent.removeMonitor(outsideClickMonitor)
            self.outsideClickMonitor = nil
        }
    }

    private func closeOnOutsideClicks() {
        guard outsideClickMonitor == nil else { return }
        outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in self?.popover.performClose(nil) }
        }
    }

    private func trackConnection() {
        let connection = withObservationTracking {
            model.connection
        } onChange: { [weak self] in
            Task { @MainActor in self?.trackConnection() }
        }
        if connection != .connected {
            colorPanel.close()
        }
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

extension StatusItemController: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        colorPanel.close()
        colorPanelDidClose()
    }
}
