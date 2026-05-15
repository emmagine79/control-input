import SwiftUI
import ServiceManagement

struct SettingsView: View {
    let audioManager: AudioDeviceManager

    @AppStorage("preferredAudioInputUID") private var preferredDeviceUID = ""
    @AppStorage("autoSwitchPreferred") private var autoSwitch = true
    @AppStorage("appTheme") private var appTheme = AppTheme.system.rawValue
    @State private var launchAtLogin = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            settingsHeader

            Form {
                audioSection
                appearanceSection
                generalSection
            }
            .formStyle(.grouped)
        }
        .frame(
            minWidth: 420, idealWidth: 500, maxWidth: .infinity,
            minHeight: 420, idealHeight: 520, maxHeight: .infinity
        )
        .padding(.top, 18)
        .background(SettingsWindowAccessor())
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
        .onChange(of: preferredDeviceUID) {
            // Immediately switch when user picks a new preferred device.
            if let device = audioManager.inputDevices.first(where: {
                $0.uid == preferredDeviceUID
            }) {
                audioManager.setDefaultInputDevice(device)
            }
        }
        .onChange(of: appTheme) { _, newValue in
            (AppTheme(rawValue: newValue) ?? .system).apply()
        }
        .onChange(of: autoSwitch) { _, enabled in
            if enabled {
                audioManager.refreshDevices()
                audioManager.schedulePreferredInputEnforcement(delay: .milliseconds(150))
            }
        }
        .onChange(of: launchAtLogin) { _, newValue in
            updateLoginItem(enabled: newValue)
        }
    }

    // MARK: - Sections

    private var settingsHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.14))
                Image(systemName: "mic.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 3) {
                Text("Keep the right mic in charge")
                    .font(.title3.weight(.semibold))
                Text(settingsStatusText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var audioSection: some View {
        Section {
            LabeledContent("Current Input") {
                Text(audioManager.currentDefaultDevice?.name ?? "None")
                    .foregroundStyle(.secondary)
            }

            Picker("Preferred Input", selection: $preferredDeviceUID) {
                Text("None").tag("")
                ForEach(audioManager.inputDevices) { device in
                    Label(device.name, systemImage: device.iconName)
                        .tag(device.uid)
                }
            }

            Toggle("Auto-switch when available", isOn: $autoSwitch)
                .accessibilityIdentifier("auto-switch-toggle")

            Text("When enabled, Control Input waits for devices to settle, then restores your preferred microphone if macOS switches away.")
                .font(.caption)
                .foregroundStyle(.secondary)
        } header: {
            Label("Audio", systemImage: "mic.fill")
        }
    }

    private var appearanceSection: some View {
        Section {
            Picker("Theme", selection: $appTheme) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.displayName).tag(theme.rawValue)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Label("Appearance", systemImage: "paintbrush")
        }
    }

    private var generalSection: some View {
        Section {
            Toggle("Launch at Login", isOn: $launchAtLogin)

            Text("Start Control Input automatically when you log in to your Mac.")
                .font(.caption)
                .foregroundStyle(.secondary)
        } header: {
            Label("General", systemImage: "gear")
        }
    }

    // MARK: - Helpers

    private var settingsStatusText: String {
        guard autoSwitch else { return "Auto-switch is paused." }
        guard !preferredDeviceUID.isEmpty else { return "Choose a preferred input to enable the lock." }
        guard let preferred = audioManager.preferredDevice else {
            return "Your preferred input is saved, but not connected."
        }
        if audioManager.currentDefaultDevice?.uid == preferred.uid {
            return "\(preferred.name) is protected."
        }
        return "Control Input will restore \(preferred.name)."
    }

    private func updateLoginItem(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // Revert on failure.
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}

private struct SettingsWindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        configureWindow(for: view)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        configureWindow(for: nsView)
    }

    private func configureWindow(for view: NSView) {
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            SettingsWindowPresenter.configure(window)
        }
    }
}
