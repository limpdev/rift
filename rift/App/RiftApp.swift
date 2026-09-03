import SwiftUI

@main
struct RiftApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings = RippleFXSettings.shared
    private let menuBarController = MenuBarController.shared
    private let windowsManager = RippleWindowsManager()
    private let loginItem = LoginItemController.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        windowsManager.start()
        menuBarController.start(settings: settings, windowsManager: windowsManager)

        // Register as a login item on first launch (one-shot; a user who
        // deliberately turns it off — here or in System Settings — stays off).
        if !UserDefaults.standard.bool(forKey: "rift.didInitialLoginRegistration") {
            UserDefaults.standard.set(true, forKey: "rift.didInitialLoginRegistration")
            if !LoginItemController.shared.isRegistered {
                LoginItemController.shared.setLaunchAtLogin(true)
            }
        }
        loginItem.refreshStatus()
    }

    func applicationWillTerminate(_ notification: Notification) {
        windowsManager.stop()
        menuBarController.stop()
    }
}
