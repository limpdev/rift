import AppKit

final class ClickMonitor {
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private let onClick: (NSPoint) -> Void

    init(onClick: @escaping (NSPoint) -> Void) {
        self.onClick = onClick
    }

    func start(includeRightClick: Bool = true) {
        stop()

        var mask: NSEvent.EventTypeMask = [.leftMouseDown]
        if includeRightClick {
            mask.insert(.rightMouseDown)
        }

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] _ in
            self?.onClick(NSEvent.mouseLocation)
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
            self?.onClick(NSEvent.mouseLocation)
            return event
        }
    }

    func stop() {
        if let globalMonitor { NSEvent.removeMonitor(globalMonitor) }
        if let localMonitor { NSEvent.removeMonitor(localMonitor) }
        globalMonitor = nil
        localMonitor = nil
    }

    deinit { stop() }
}
