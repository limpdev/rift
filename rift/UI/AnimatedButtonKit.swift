//  Rift
//  AnimatedButtonKit
//  Created by Limp Cheney
// https://docs.swift.org/swift-book

import SwiftUI

public enum ButtonAnimation {
  case rotate
  case flip
  case bounce(_ amount: CGFloat = -5)
  case slide(_ amount: CGFloat = 5)
  case squish(_ amount: CGFloat = 0.2, _ makeWider: Bool = true)
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
public struct AnimatedButton<Label: View>: View {

  private let action: () -> Void
  private let animation: ButtonAnimation
  private let duration: Double?
  private let icon: String?
  private let image: Image?
  private let label: (AnyView) -> Label

  /// `duration` overrides the animation's built-in timing; `nil` keeps the default.
  public init(
    animation: ButtonAnimation,
    duration: Double? = nil,
    icon: String,
    action: @escaping () -> Void,
    @ViewBuilder label: @escaping (AnyView) -> Label
  ) {
    self.action = action
    self.animation = animation
    self.duration = duration
    self.icon = icon
    self.image = nil
    self.label = label
  }

  public init(
    animation: ButtonAnimation,
    duration: Double? = nil,
    image: Image,
    action: @escaping () -> Void,
    @ViewBuilder label: @escaping (AnyView) -> Label
  ) {
    self.action = action
    self.animation = animation
    self.duration = duration
    self.icon = nil
    self.image = image
    self.label = label
  }

  @State private var rotationCount: Double = 0
  @State private var offsetY: Double = 0
  @State private var offsetX: Double = 0
  @State private var scaleY: Double = 1
  @State private var scaleX: Double = 1

  @State private var isHovering = false

  private func handleAnimation() {

    switch animation {
    case .rotate:
      withAnimation(.easeInOut(duration: duration ?? 0.6)) {
        rotationCount += 1
      }
    case .flip:
      withAnimation(.easeInOut(duration: duration ?? 0.4)) {
        rotationCount += 0.5
      }
    case .bounce(let amount):
      let d = duration ?? 0.25
      withAnimation(.spring(duration: d)) {
        offsetY = amount
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + d) {
        withAnimation(.spring()) {
          offsetY = 0
        }
      }
    case .slide(let amount):
      let d = duration ?? 0.25
      withAnimation(.spring(duration: d)) {
        offsetX = amount
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + d) {
        withAnimation(.spring()) {
          offsetX = 0
        }
      }
    case .squish(let amount, let makeWider):
      let d = duration ?? 0.25
      withAnimation(.spring(duration: d)) {
        scaleY = 1 - amount
        if makeWider {
          scaleX = 1 + (amount * 0.5)
        }
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + d) {
        withAnimation(.spring()) {
          scaleY = 1
          if makeWider {
            scaleX = 1
          }
        }
      }
    }
  }

  public var body: some View {
    Button {
      action()
      handleAnimation()
    } label: {
      if let image {
        label(
          AnyView(
            image
              .rotationEffect(.degrees(360 * rotationCount))
              .offset(x: offsetX, y: offsetY)
              .scaleEffect(x: scaleX, y: scaleY, anchor: .center)
          )
        )
      } else {
        label(
          AnyView(
            Image(systemName: icon ?? "questionmark.circle")
              .rotationEffect(.degrees(360 * rotationCount))
              .offset(x: offsetX, y: offsetY)
              .scaleEffect(x: scaleX, y: scaleY, anchor: .center)
          )
        )
      }
    }
    .background(isHovering ? Color.white.opacity(0.1) : Color.white.opacity(0))
    .scaleEffect(isHovering ? 1.2 : 1)
    .animation(.spring(duration: 0.145), value: isHovering)
    .onHover { isHovering = $0 }
    .linkPointer()
  }
}

extension View {
  /// Pointing-hand cursor on macOS 15+; no-op elsewhere.
  @ViewBuilder
  fileprivate func linkPointer() -> some View {
    #if os(macOS)
      if #available(macOS 15.0, *) {
        self.pointerStyle(.link)
      } else {
        self
      }
    #else
      self
    #endif
  }
}
