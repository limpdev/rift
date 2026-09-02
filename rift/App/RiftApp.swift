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

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        windowsManager.start()
        menuBarController.start(settings: settings, windowsManager: windowsManager)
    }

    func applicationWillTerminate(_ notification: Notification) {
        windowsManager.stop()
        menuBarController.stop()
    }
}
