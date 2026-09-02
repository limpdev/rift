// In RippleOverlayWindow.swift
import AppKit
import QuartzCore

final class RippleOverlayWindow: NSWindow {
    private let rippleContainer = RippleContainerView()

    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        level = .screenSaver
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        contentView = rippleContainer
        setFrame(screen.frame, display: true)
    }

    func moveToScreen(_ screen: NSScreen) {
        setFrame(screen.frame, display: true)
    }

    func spawnRipple(at location: NSPoint, settings: RippleFXSettings) {
        let local = NSPoint(x: location.x - frame.minX, y: location.y - frame.minY)
        rippleContainer.spawnRipple(at: local, settings: settings)
    }
}

private final class RippleContainerView: NSView {
    private let maxRipples = 32

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.masksToBounds = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    func spawnRipple(at point: NSPoint, settings: RippleFXSettings) {
        guard let hostLayer = layer else { return }

        if hostLayer.sublayers?.count ?? 0 >= maxRipples {
            hostLayer.sublayers?.first?.removeFromSuperlayer()
        }

        let maxRadius = settings.size * 2
        let diameter = maxRadius * 2

        let rippleLayer = CAShapeLayer()
        rippleLayer.frame = CGRect(
            x: point.x - maxRadius,
            y: point.y - maxRadius,
            width: diameter,
            height: diameter
        )
        
        let pathBounds = CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter))
        rippleLayer.path = CGPath(ellipseIn: pathBounds, transform: nil)

        switch settings.style {
        case .filled:
            rippleLayer.fillColor = settings.color.cgColor
            rippleLayer.strokeColor = nil
            rippleLayer.lineWidth = 0
        case .ring:
            rippleLayer.fillColor = NSColor.clear.cgColor
            rippleLayer.strokeColor = settings.color.cgColor
            rippleLayer.lineWidth = settings.thickness
        }

        rippleLayer.opacity = Float(settings.opacity)
        hostLayer.addSublayer(rippleLayer)

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.1
        scaleAnimation.toValue = 1.0
        scaleAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.22, 1, 0.36, 1)

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = Float(settings.opacity)
        opacityAnimation.toValue = 0.0
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let group = CAAnimationGroup()
        group.animations = [scaleAnimation, opacityAnimation]
        group.duration = settings.duration
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            rippleLayer.removeFromSuperlayer()
        }
        rippleLayer.add(group, forKey: "ripple")
        CATransaction.commit()
    }
}
