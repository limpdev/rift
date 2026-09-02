import AppKit
import SwiftUI

/// Wraps AppKit's `NSColorWell` to ensure `NSColorPanel` opens reliably
/// in menu bar apps and popovers without being dismissed.
struct ColorWellView: NSViewRepresentable {
    @Binding var color: NSColor

    func makeNSView(context: Context) -> NSColorWell {
        let colorWell = NSColorWell()
        colorWell.color = color
        colorWell.target = context.coordinator
        colorWell.action = #selector(Coordinator.colorDidChange(_:))

        if #available(macOS 13.0, *) {
            colorWell.colorWellStyle = .expanded
        }

        return colorWell
    }

    func updateNSView(_ nsView: NSColorWell, context: Context) {
        if nsView.color != color {
            nsView.color = color
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject {
        var parent: ColorWellView

        init(_ parent: ColorWellView) {
            self.parent = parent
        }

        @objc func colorDidChange(_ sender: NSColorWell) {
            // Ensure app is active so the panel stays frontmost
            NSApp.activate(ignoringOtherApps: true)
            NSColorPanel.shared.level = .floating
            parent.color = sender.color
        }
    }
}
