// In RippleWindowsManager.swift
import AppKit
import Combine

final class RippleWindowsManager {
    private struct ScreenWindow {
        let screen: NSScreen
        let window: RippleOverlayWindow
    }

    private var screenWindows: [ScreenWindow] = []
    private var clickMonitor: ClickMonitor?
    private var screenObserver: NSObjectProtocol?
    private var cancellables = Set<AnyCancellable>()
    private let settings = RippleFXSettings.shared

    func start() {
        rebuildWindows()

        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.rebuildWindows()
        }

        clickMonitor = ClickMonitor { [weak self] location in
            self?.handleClick(at: location)
        }

        settings.$enabled
            .sink { [weak self] enabled in
                self?.syncMonitor(enabled: enabled)
            }
            .store(in: &cancellables)

        settings.$trackRightClicks
            .sink { [weak self] _ in
                guard let self = self, self.settings.enabled else { return }
                self.syncMonitor(enabled: true)
            }
            .store(in: &cancellables)

        syncMonitor(enabled: settings.enabled)
    }

    func stop() {
        clickMonitor?.stop()
        if let screenObserver { NotificationCenter.default.removeObserver(screenObserver) }
        screenWindows.forEach { $0.window.orderOut(nil) }
        screenWindows.removeAll()
    }

    private func syncMonitor(enabled: Bool) {
        if enabled {
            clickMonitor?.start(includeRightClick: settings.trackRightClicks)
        } else {
            clickMonitor?.stop()
        }
    }

    private func rebuildWindows() {
        let currentScreens = NSScreen.screens

        // 1. Remove windows for disconnected displays
        let currentIDs = Set(currentScreens.map(ObjectIdentifier.init))
        screenWindows.removeAll { entry in
            guard !currentIDs.contains(ObjectIdentifier(entry.screen)) else { return false }
            entry.window.orderOut(nil)
            return true
        }

        // 2. Update existing window frames if screen resolutions/positions changed
        for entry in screenWindows {
            entry.window.moveToScreen(entry.screen)
        }

        // 3. Add windows for newly connected displays
        let existingIDs = Set(screenWindows.map { ObjectIdentifier($0.screen) })
        for screen in currentScreens where !existingIDs.contains(ObjectIdentifier(screen)) {
            let window = RippleOverlayWindow(screen: screen)
            window.orderFrontRegardless()
            screenWindows.append(ScreenWindow(screen: screen, window: window))
        }
    }

    private func handleClick(at location: NSPoint) {
        guard settings.enabled else { return }
        guard let entry = screenWindows.first(where: { NSMouseInRect(location, $0.screen.frame, false) }) else { return }
        entry.window.spawnRipple(at: location, settings: settings)
    }
}
