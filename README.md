# Rift

A lightweight, native macOS menu bar app that visualizes mouse clicks with smooth, customizable ripple effects.

> _When you spend your time building shit like this, don't expect a fully signed Apple Developer certification... $100 is $100. Feel free to audit this code and uhhh... fix it yourself, pal._

## Features

- **Permissionless**: Uses standard `NSEvent` global monitoring instead of intrusive accessibility taps (`CGEventTap`) — no system permission prompts required.
- **Hardware-Accelerated**: Ripples are rendered using GPU-composited Core Animation layers for smooth, 60+ FPS performance without CPU overhead.
- **Multi-Monitor & Multi-Space**: Seamlessly renders ripples across all connected displays, resolutions, and macOS Spaces.
- **Customizable**:
  - **Styles**: Expanding ring shockwave or filled ripple disc.
  - **Appearance**: Custom colors, quick palette swatches, opacity, size, thickness, and duration.
  - **Inputs**: Supports left and right mouse clicks.
- **Minimalist**: Lives unobtrusively in the menu bar with zero Dock footprint.

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0+ (to build from source)

## Getting Started

### Building from Source

1. Clone the repository:

```bash
git clone https://github.com/limpdev/rift.git
cd rift
```

2. Open the project in Xcode:

```bash
open Rift.xcodeproj
```

3. Ensure the target's `Info.plist` includes:

```xml
<key>LSUIElement</key>
<true/>
```

4. Build and run (`Cmd + R`).

## Usage

1. Click the **Rift** drop icon in your macOS menu bar to open the settings popover.
2. Toggle the effect on/off, adjust size, duration, opacity, or choose between **Ring** and **Filled** styles.
3. Select your favorite accent color from the palette or open the native color panel.

## License

MIT License. Again, don't take this too seriously.
