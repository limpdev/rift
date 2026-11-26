import AppKit
import Combine

final class RippleWindowsManager {
  private var windows: [CGDirectDisplayID: RippleOverlayWindow] = [:]
  private var clickMonitor: ClickMonitor?
  private var screenObserver: NSObjectProtocol?
  private var monitorSubscription: AnyCancellable?
  private let settings = RippleFXSettings.shared

  func start() {
    guard clickMonitor == nil else { return }

    screenObserver = NotificationCenter.default.addObserver(
      forName: NSApplication.didChangeScreenParametersNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.updateWindows()
    }

    clickMonitor = ClickMonitor { [weak self] location in
      self?.handleClick(at: location)
    }

    // nil means monitoring is paused. Use the published values because
    // @Published delivers changes before updating the stored properties.
    monitorSubscription = settings.$enabled
      .combineLatest(settings.$trackRightClicks)
      .map { enabled, rightClicks in enabled ? rightClicks : nil }
      .removeDuplicates()
      .sink { [weak self] rightClicks in
        if let rightClicks {
          self?.clickMonitor?.start(includeRightClick: rightClicks)
        } else {
          self?.clickMonitor?.stop()
          self?.clearWindows()
        }
      }
  }

  func stop() {
    monitorSubscription = nil
    clickMonitor?.stop()
    clickMonitor = nil
    if let screenObserver {
      NotificationCenter.default.removeObserver(screenObserver)
    }
    screenObserver = nil
    clearWindows()
  }

  private func clearWindows() {
    windows.values.forEach { $0.orderOut(nil) }
    windows.removeAll()
  }

  private func updateWindows() {
    guard !windows.isEmpty else { return }
    let screens = NSScreen.screens
    for (id, window) in windows {
      if let screen = screens.first(where: { $0.riftDisplayID == id }) {
        if window.frame != screen.frame {
          window.moveToScreen(screen)
        }
      } else {
        window.orderOut(nil)
        windows.removeValue(forKey: id)
      }
    }
  }

  private func handleClick(at location: NSPoint) {
    guard settings.enabled else { return }
    if let window = windows.values.first(where: {
      NSMouseInRect(location, $0.frame, false)
    }) {
      window.spawnRipple(at: location, settings: settings)
      return
    }

    guard
      let screen = NSScreen.screens.first(where: {
        NSMouseInRect(location, $0.frame, false)
      }),
      let id = screen.riftDisplayID
    else { return }
    let window = RippleOverlayWindow(screen: screen)
    windows[id] = window
    window.orderFrontRegardless()
    window.spawnRipple(at: location, settings: settings)
  }
}

extension NSScreen {
  fileprivate var riftDisplayID: CGDirectDisplayID? {
    (deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?
      .uint32Value
  }
}
