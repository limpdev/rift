import AppKit
import ServiceManagement
import Combine

/// Manages launch-at-login registration via `SMAppService` (the modern,
/// sandbox-compatible API — no helper process or LaunchAgent required).
final class LoginItemController: ObservableObject {
    static let shared = LoginItemController()

    @Published private(set) var isRegistered: Bool = SMAppService.mainApp.status == .enabled

    private init() {
        refreshStatus()
    }

    /// Enables or disables launch at login.
    ///
    /// - Returns: `nil` on success, or an error description on failure
    ///   (e.g. the user turned the item off in System Settings, which
    ///   must be re-enabled there rather than from within the app).
    @discardableResult
    func setLaunchAtLogin(_ enabled: Bool) -> String? {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            refreshStatus()
            return nil
        } catch {
            refreshStatus()
            return error.localizedDescription
        }
    }

    /// Re-syncs published state with the system's actual registration,
    /// so external changes (System Settings > General > Login Items)
    /// are reflected if the user re-opens settings.
    func refreshStatus() {
        isRegistered = SMAppService.mainApp.status == .enabled
    }
}
