Rift is a native, fun MacOS application that runs in the background. Through a single configuration menu, user's can customize a global rippling effect that triggers on each and every mouse click.

## AnimatedButtonKit

I replaced the on/off switch in the Settings header with your `AnimatedButton`. I haven't built it, so I haven't seen the animation or colors in the running app.

- **Action instead of binding.** Your kit's `AnimatedButton` doesn't take an `isOn:` binding. It takes a closure that runs on tap, so the button flips `settings.enabled` itself with `settings.enabled.toggle()`. `RippleFXSettings` then pushes that change everywhere it's used, including the `.disabled(!settings.enabled)` that greys out the controls below.
- **Styling stays in Settings.** The `label:` closure receives the icon with the animation already applied. Because it's built inside `SettingsView`, it can read `settings.enabled` directly and turn the icon accent-colored when on and grey when off. The kit doesn't need to know anything about on/off state.
- **Screen readers.** The old switch told VoiceOver whether it was on or off. A plain button doesn't, so I added `.accessibilityValue("On"/"Off")` to keep that.

Things to try: `.bounce()` or `.squish(0.3, true)` feel more like pressing a button than `.rotate` does. `.flip` only turns half a rotation per tap, so the icon's orientation would match the state.

I added a `#Preview` at the end of `rift/UI/SettingsView.swift`. I haven't opened the canvas to check that it renders.

- **Why `.shared`:** `RippleFXSettings` has a `private init()`, so the preview can't create its own copy. It uses the same `.shared` instance the app uses.
- **Why `onQuit: {}`:** the default `onQuit` calls `NSApp.terminate`, so clicking "Quit Rift" in the live preview would kill the preview process. The empty closure makes that button do nothing.
- **Fixed width:** the view already sets `.frame(width: 290)`, so the canvas shows it at the same width as the real menu-bar popover.

The red errors SourceKit showed (`Cannot find 'RippleFXSettings'…`) come from it checking the file without the rest of the Xcode project. They should go away when you build in Xcode.

Two things to know:
- **Settings may persist:** if `RippleFXSettings` saves to UserDefaults, changes you make in the preview could be saved to your real settings. I didn't check how it stores them.
- **Launch at Login is live:** that toggle registers and unregisters the real login item, so avoid flipping it in the preview.

---

On macOS the hover hook is `.onHover { isHovering in … }`. It fires `true` when the pointer enters the view and `false` when it leaves. You store that in a `@State` and drive a visual change from it. (`.hoverEffect` is mainly an iPad/visionOS feature, so it isn't the right tool for a Mac menu-bar popover.)

There are two places it can plug in.

### 1. Inside the kit (recommended)
Every `AnimatedButton` gets the hover effect automatically, and the hover state stays inside the button:

```swift
// AnimatedButtonKit.swift: add next to the other @State vars
@State private var isHovering = false

// in body, chain onto the Button
Button { … } label: { … }
  .scaleEffect(isHovering ? 1.12 : 1)
  .animation(.spring(duration: 0.2), value: isHovering)
  .onHover { isHovering = $0 }
```

`★ Insight ─────────────────────────────────────`
- **Two effects, no clash.** The tap animations (rotate, bounce, squish) are applied to the *icon* inside the label. The hover scale above is applied to the *whole button*. Because they're on different views they stack instead of fighting, so you can hover-grow and tap-spin at the same time.
- **Animation only for hover.** `.animation(_:value:)` animates only changes to `isHovering`. Your tap animations already use `withAnimation`, so they're unaffected.
`─────────────────────────────────────────────────`

### 2. At the call site in `SettingsView`
Use this if you want the hover look to depend on settings, for example glowing only while Rift is on. It needs a `@State private var powerHovered = false` in `SettingsView`:

```swift
} label: { icon in
  icon
    .font(.title3)
    .foregroundStyle(settings.enabled ? Color.accentColor : .secondary)
    .opacity(powerHovered ? 1 : 0.8)
}
.onHover { powerHovered = $0 }
```

The drawback is one extra `@State` per button in the parent view, which gets noisy if you add more animated buttons.

**Extra:** on macOS 15 and later, `.pointerStyle(.link)` shows the pointing-hand cursor over the button, which makes it read as clickable. It needs an `if #available` check if you support older macOS versions.

I haven't edited any files. Want me to add option 1 to the kit?

---

I added the pointing-hand cursor and a configurable `duration`, and the app builds cleanly. I haven't opened the popover to see them in action.

**Pointer style:** the `AnimatedButton` now shows the pointing-hand cursor on macOS 15 and later, attached after the hover code you'd already added. On older macOS it does nothing.

**Duration:** both initializers now take an optional `duration:`. Leaving it out keeps each animation's current timing: rotate 0.6 s, flip 0.4 s, and bounce, slide and squish 0.25 s. To change it on the power button:

```swift
AnimatedButton(animation: .rotate, duration: 0.3, icon: "power") {
  settings.enabled.toggle()
} label: { icon in … }
```

`★ Insight ─────────────────────────────────────`
- **Why a helper function:** `if #available` can't go directly in a modifier chain, so it lives in a small `linkPointer()` helper that returns either the styled view or the unchanged view. `pointerStyle` also doesn't exist on iOS at all, and your kit is marked as available there. That's why the helper also has `#if os(macOS)`: without it the kit wouldn't compile for iOS.
- **Why `nil` instead of a number:** each animation has its own sensible default, so no single number fits all of them as the parameter default. `nil` means "use this animation's built-in timing".
- **Bounce, slide and squish:** these spring out and then snap back. `duration` now also sets when the snap-back starts, so a longer duration still finishes the first half before returning instead of being cut off at 0.25 s.
`─────────────────────────────────────────────────`

The spring back to rest after bounce, slide and squish still uses SwiftUI's default timing, so `duration` controls only the first half. Your hover animation also still has its own fixed 0.145 s and ignores `duration`.
