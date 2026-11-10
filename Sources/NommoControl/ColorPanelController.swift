import AppKit
import NommoKit

@MainActor
final class ColorPanelController: NSObject {
    private enum Layout {
        static let gap: CGFloat = 8
    }

    private var onChange: ((LightColor) -> Void)?
    private var onClose: (() -> Void)?

    var isOpen: Bool { onClose != nil }

    func show(
        color: LightColor,
        beside window: NSWindow?,
        onChange: @escaping (LightColor) -> Void,
        onClose: @escaping () -> Void
    ) {
        let panel = NSColorPanel.shared
        self.onChange = nil
        panel.showsAlpha = false
        panel.isContinuous = true
        panel.color = NSColor(color)
        panel.setTarget(self)
        panel.setAction(#selector(colorChanged(_:)))
        self.onChange = onChange
        self.onClose = onClose
        observeClose(of: panel)
        if !panel.isVisible, let window {
            place(panel, beside: window)
        }
        panel.makeKeyAndOrderFront(nil)
    }

    func close() {
        guard isOpen else { return }
        finish()
        NSColorPanel.shared.close()
    }

    @objc private func colorChanged(_ sender: NSColorPanel) {
        guard let color = LightColor(sender.color) else { return }
        onChange?(color)
    }

    @objc private func panelWillClose(_ notification: Notification) {
        finish()
    }

    private func finish() {
        guard let onClose else { return }
        let panel = NSColorPanel.shared
        NotificationCenter.default.removeObserver(self, name: NSWindow.willCloseNotification, object: panel)
        panel.setTarget(nil)
        panel.setAction(nil)
        onChange = nil
        self.onClose = nil
        onClose()
    }

    private func observeClose(of panel: NSColorPanel) {
        let center = NotificationCenter.default
        center.removeObserver(self, name: NSWindow.willCloseNotification, object: panel)
        center.addObserver(self, selector: #selector(panelWillClose(_:)), name: NSWindow.willCloseNotification, object: panel)
    }

    private func place(_ panel: NSPanel, beside window: NSWindow) {
        let anchor = window.frame
        let size = panel.frame.size
        var origin = NSPoint(x: anchor.minX - Layout.gap - size.width, y: anchor.maxY - size.height)
        if let visible = window.screen?.visibleFrame {
            if origin.x < visible.minX {
                origin.x = min(anchor.maxX + Layout.gap, visible.maxX - size.width)
            }
            origin.y = min(max(origin.y, visible.minY), visible.maxY - size.height)
        }
        panel.setFrameOrigin(origin)
    }
}
