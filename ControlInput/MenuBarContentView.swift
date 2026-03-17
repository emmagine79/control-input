import SwiftUI

struct MenuBarContentView: View {
    let audioManager: AudioDeviceManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader

            if audioManager.inputDevices.isEmpty {
                emptyState
            } else {
                deviceList
            }

            Divider()
                .padding(.vertical, 4)

            settingsButton
            quitButton

            Spacer()
                .frame(height: 6)
        }
        .frame(width: 280)
    }

    // MARK: - Subviews

    private var sectionHeader: some View {
        Text("Input Devices")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 6)
    }

    private var deviceList: some View {
        VStack(spacing: 2) {
            ForEach(audioManager.inputDevices) { device in
                DeviceRow(
                    device: device,
                    isSelected: device.id == audioManager.currentDefaultDeviceID
                ) {
                    audioManager.setDefaultInputDevice(device)
                }
            }
        }
        .padding(.horizontal, 6)
    }

    private var emptyState: some View {
        HStack {
            Image(systemName: "mic.slash")
                .foregroundStyle(.tertiary)
            Text("No input devices found")
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var settingsButton: some View {
        SettingsLink {
            HStack(spacing: 10) {
                Image(systemName: "gear")
                    .font(.system(size: 13))
                    .frame(width: 18)
                    .foregroundStyle(.secondary)

                Text("Settings\u{2026}")
                    .font(.body)

                Spacer()

                Text("\u{2318},")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .contentShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 6)
    }

    private var quitButton: some View {
        MenuBarButton(
            icon: "power",
            label: "Quit Control Input",
            shortcut: "\u{2318}Q"
        ) {
            NSApplication.shared.terminate(nil)
        }
    }
}

// MARK: - Device Row

private struct DeviceRow: View {
    let device: AudioDeviceManager.AudioInputDevice
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: device.iconName)
                    .font(.system(size: 13))
                    .frame(width: 18)
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)

                Text(device.name)
                    .font(.body)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .contentShape(RoundedRectangle(cornerRadius: 6))
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color.primary.opacity(0.08) : .clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Menu Bar Button

private struct MenuBarButton: View {
    let icon: String
    let label: String
    let shortcut: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .frame(width: 18)
                    .foregroundStyle(.secondary)

                Text(label)
                    .font(.body)

                Spacer()

                Text(shortcut)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .contentShape(RoundedRectangle(cornerRadius: 6))
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color.primary.opacity(0.08) : .clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .padding(.horizontal, 6)
    }
}
