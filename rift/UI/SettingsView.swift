import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: RippleFXSettings
    var onQuit: () -> Void = { NSApp.terminate(nil) }

    // Quick presets for convenience
    private let presetColors: [NSColor] = [
        .controlAccentColor,
        .systemRed,
        .systemOrange,
        .systemYellow,
        .systemGreen,
        .systemCyan,
        .systemBlue,
        .systemPurple,
        .white,
        .lightGray
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header & Master Toggle
            HStack {
                Label("Rift", systemImage: "drop.fill")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $settings.enabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                // Style Selector
                HStack {
                    Text("Style")
                    Spacer()
                    Picker("", selection: $settings.style) {
                        ForEach(RippleStyle.allCases) { style in
                            Text(style.title).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 140)
                }

                // Color Selection with Presets + Native ColorWell
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Color")
                        Spacer()
                        // Native NSColorWell that properly activates NSColorPanel
                        ColorWellView(color: $settings.color)
                            .frame(width: 36, height: 24)
                    }

                    // Quick Palette Swatches
                    HStack(spacing: 6) {
                        ForEach(presetColors, id: \.self) { preset in
                            Circle()
                                .fill(Color(nsColor: preset))
                                .frame(width: 18, height: 18)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                        .opacity(settings.color == preset ? 1 : 0)
                                )
                                .onTapGesture {
                                    settings.color = preset
                                }
                        }
                    }
                }

                // Size Slider
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Size")
                        Spacer()
                        Text("\(Int(settings.size * 2)) pt")
                            .foregroundColor(.secondary)
                            .font(.caption.monospacedDigit())
                    }
                    Slider(value: $settings.size, in: 4...48, step: 1)
                }

                // Duration Slider
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(String(format: "%.2f s", settings.duration))
                            .foregroundColor(.secondary)
                            .font(.caption.monospacedDigit())
                    }
                    Slider(value: $settings.duration, in: 0.15...1.0, step: 0.025)
                }

                // Opacity Slider
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Opacity")
                        Spacer()
                        Text("\(Int(settings.opacity * 100))%")
                            .foregroundColor(.secondary)
                            .font(.caption.monospacedDigit())
                    }
                    Slider(value: $settings.opacity, in: 0.05...1.0, step: 0.05)
                }

                // Ring Thickness (for ring style)
                if settings.style == .ring {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Thickness")
                            Spacer()
                            Text("\(Int(settings.thickness)) pt")
                                .foregroundColor(.secondary)
                                .font(.caption.monospacedDigit())
                        }
                        Slider(value: $settings.thickness, in: 1...10, step: 1)
                    }
                }

                // Right-Click Toggle
                Toggle("Track Right Clicks", isOn: $settings.trackRightClicks)
            }
            .disabled(!settings.enabled)

            Divider()

            // Footer
            HStack {
                Button("Reset Defaults") {
                    settings.resetToDefaults()
                }
                .buttonStyle(.borderless)
                .font(.caption)

                Spacer()

                Button("Quit Rift", role: .destructive, action: onQuit)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
        }
        .padding(16)
        .frame(width: 290)
    }
}
