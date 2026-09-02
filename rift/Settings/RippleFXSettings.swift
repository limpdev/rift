import AppKit
import Combine

/// Persisted configuration for the ripple effect, backed by `UserDefaults`.
final class RippleFXSettings: ObservableObject {
    static let shared = RippleFXSettings()

    private enum Keys {
        static let enabled = "rippleFX.enabled"
        static let style = "rippleFX.style"
        static let size = "rippleFX.size"
        static let duration = "rippleFX.duration"
        static let opacity = "rippleFX.opacity"
        static let thickness = "rippleFX.thickness"
        static let colorData = "rippleFX.colorData"
        static let trackRightClicks = "rippleFX.trackRightClicks"
    }

    private enum Defaults {
        static let enabled = true
        static let style: RippleStyle = .ring
        static let size: CGFloat = 16
        static let duration: TimeInterval = 0.375
        static let opacity: CGFloat = 0.45
        static let thickness: CGFloat = 3.0
        static let color = NSColor.controlAccentColor
        static let trackRightClicks = true
    }

    private let store = UserDefaults.standard

    @Published var enabled: Bool {
        didSet { store.set(enabled, forKey: Keys.enabled) }
    }

    @Published var style: RippleStyle {
        didSet { store.set(style.rawValue, forKey: Keys.style) }
    }

    @Published var size: CGFloat {
        didSet { store.set(Double(size), forKey: Keys.size) }
    }

    @Published var duration: TimeInterval {
        didSet { store.set(duration, forKey: Keys.duration) }
    }

    @Published var opacity: CGFloat {
        didSet { store.set(Double(opacity), forKey: Keys.opacity) }
    }

    @Published var thickness: CGFloat {
        didSet { store.set(Double(thickness), forKey: Keys.thickness) }
    }

    @Published var trackRightClicks: Bool {
        didSet { store.set(trackRightClicks, forKey: Keys.trackRightClicks) }
    }

    @Published var color: NSColor {
        didSet { saveColor(color) }
    }

    private init() {
        store.register(defaults: [
            Keys.enabled: Defaults.enabled,
            Keys.style: Defaults.style.rawValue,
            Keys.size: Double(Defaults.size),
            Keys.duration: Defaults.duration,
            Keys.opacity: Double(Defaults.opacity),
            Keys.thickness: Double(Defaults.thickness),
            Keys.trackRightClicks: Defaults.trackRightClicks
        ])

        self.enabled = store.bool(forKey: Keys.enabled)
        self.style = RippleStyle(rawValue: store.string(forKey: Keys.style) ?? "") ?? Defaults.style
        self.size = CGFloat(store.double(forKey: Keys.size))
        self.duration = store.double(forKey: Keys.duration)
        self.opacity = CGFloat(store.double(forKey: Keys.opacity))
        self.thickness = CGFloat(store.double(forKey: Keys.thickness))
        self.trackRightClicks = store.bool(forKey: Keys.trackRightClicks)
        self.color = Self.loadColor(from: store) ?? Defaults.color
    }

    func resetToDefaults() {
        enabled = Defaults.enabled
        style = Defaults.style
        size = Defaults.size
        duration = Defaults.duration
        opacity = Defaults.opacity
        thickness = Defaults.thickness
        trackRightClicks = Defaults.trackRightClicks
        color = Defaults.color
    }

    private func saveColor(_ color: NSColor) {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true) else { return }
        store.set(data, forKey: Keys.colorData)
    }

    private static func loadColor(from store: UserDefaults) -> NSColor? {
        guard let data = store.data(forKey: Keys.colorData) else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data)
    }
}
