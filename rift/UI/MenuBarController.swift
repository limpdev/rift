import AppKit
import SwiftUI

final class MenuBarController: NSObject {
    static let shared = MenuBarController()

    private var statusItem: NSStatusItem?
    private let popover = NSPopover()

    func start(settings: RippleFXSettings, windowsManager: RippleWindowsManager) {
        // Prevent duplicate status items
        guard statusItem == nil else { return }

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "drop.circle", accessibilityDescription: "Rift")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
        self.statusItem = item

        // .semitransient keeps the popover open when opening the color panel
        popover.behavior = .semitransient
        popover.contentViewController = NSHostingController(
            rootView: SettingsView(settings: settings, onQuit: {
                NSApp.terminate(nil)
            })
        )
    }

    func stop() {
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
        }
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            // Activate the app so NSColorPanel and sub-windows receive focus
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
            popover.contentViewController?.view.window?.becomeKey()
        }
    }

    deinit {
        stop()
    }
}
