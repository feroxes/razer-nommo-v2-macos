import AppKit
import SwiftUI

@MainActor
final class StatusItemController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let popover = NSPopover()
    private let model: SpeakerModel
    private let launchAtLogin: LaunchAtLogin

    init(model: SpeakerModel, launchAtLogin: LaunchAtLogin) {
        self.model = model
        self.launchAtLogin = launchAtLogin
        super.init()
        let content = NSHostingController(rootView: PanelView(model: model, launchAtLogin: launchAtLogin))
        content.sizingOptions = [.preferredContentSize]
        popover.contentViewController = content
        popover.behavior = .transient
        configureButton()
    }

    private func configureButton() {
        guard let button = statusItem.button else { return }
        button.image = SpeakerGlyph.image
        button.target = self
        button.action = #selector(togglePopover)
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
        NSApp.activate()
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }
}
