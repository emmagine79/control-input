import SwiftUI

@MainActor
enum SettingsWindowPresenter {
    static func open(_ openSettings: OpenSettingsAction) {
        openSettings()
        bringSettingsToFront()

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(150))
            bringSettingsToFront()
        }
    }

    static func configure(_ window: NSWindow) {
        window.collectionBehavior.insert(.canJoinAllSpaces)
        window.collectionBehavior.insert(.fullScreenAuxiliary)
        window.minSize = NSSize(width: 420, height: 420)

        if window.frame.height < 520 {
            window.setContentSize(NSSize(
                width: max(window.frame.width, 500),
                height: 520
            ))
        }
    }

    private static func bringSettingsToFront() {
        NSApp.activate(ignoringOtherApps: true)

        for window in NSApp.windows where window.title.localizedCaseInsensitiveContains("settings") {
            configure(window)
            window.collectionBehavior.insert(.moveToActiveSpace)
            window.orderFrontRegardless()
            window.makeKeyAndOrderFront(nil)
        }
    }
}

struct MenuBarContentView: View {
    let audioManager: AudioDeviceManager
    @Environment(\.openSettings) private var openSettings
    @AppStorage("preferredAudioInputUID") private var preferredDeviceUID = ""
    @AppStorage("autoSwitchPreferred") private var autoSwitch = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            lockStatus

            if audioManager.inputDevices.isEmpty {
                emptyState
            } else {
                sectionHeader
                deviceList
            }

            Divider()
                .padding(.horizontal, 14)
                .padding(.top, 2)

            settingsButton
            quitButton

            Spacer()
                .frame(height: 4)
        }
        .padding(.top, 12)
        .frame(width: 312)
    }

    // MARK: - Subviews

    private var header: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.14))
                Image(systemName: "mic.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
            .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 1) {
                Text("Control Input")
                    .font(.headline.weight(.semibold))
                Text(audioManager.currentDefaultDevice?.name ?? "No active input")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 14)
    }

    private var lockStatus: some View {
        HStack(spacing: 10) {
            Image(systemName: statusIcon)
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 20)
                .foregroundStyle(statusColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle)
                    .font(.subheadline.weight(.semibold))
                Text(statusSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(statusColor.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(statusColor.opacity(0.22), lineWidth: 1)
        )
        .padding(.horizontal, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(statusTitle). \(statusSubtitle)")
    }

    private var sectionHeader: some View {
        Text("Input Devices")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 2)
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

    private var statusIcon: String {
        if !autoSwitch { return "lock.open.fill" }
        if preferredDeviceUID.isEmpty { return "pin.slash.fill" }
        if audioManager.preferredDevice == nil { return "exclamationmark.triangle.fill" }
        if audioManager.currentDefaultDevice?.uid == preferredDeviceUID { return "lock.fill" }
        return "arrow.triangle.2.circlepath"
    }

    private var statusTitle: String {
        if !autoSwitch { return "Lock paused" }
        if preferredDeviceUID.isEmpty { return "No preferred input" }
        if audioManager.preferredDevice == nil { return "Preferred input missing" }
        if audioManager.currentDefaultDevice?.uid == preferredDeviceUID { return "Locked to preferred input" }
        return "Restoring preferred input"
    }

    private var statusSubtitle: String {
        if !autoSwitch { return "Auto-switch is off" }
        if preferredDeviceUID.isEmpty { return "Pick a device in Settings" }
        if let preferred = audioManager.preferredDevice {
            return preferred.name
        }
        return "Reconnect the saved device"
    }

    private var statusColor: Color {
        if !autoSwitch || preferredDeviceUID.isEmpty { return .secondary }
        if audioManager.preferredDevice == nil || audioManager.lastSwitchError != nil { return .orange }
        if audioManager.currentDefaultDevice?.uid == preferredDeviceUID { return .green }
        return .accentColor
    }

    private var settingsButton: some View {
        Button {
            SettingsWindowPresenter.open(openSettings)
        } label: {
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
        .accessibilityLabel("Open Settings")
        .accessibilityIdentifier("settings-button")
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
        .accessibilityLabel("\(device.name)\(isSelected ? ", current input" : "")")
        .accessibilityIdentifier("device-\(device.uid)")
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
        .accessibilityLabel(label)
        .accessibilityIdentifier(label.lowercased().replacingOccurrences(of: " ", with: "-"))
    }
}
