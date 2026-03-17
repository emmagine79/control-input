import SwiftUI
import ServiceManagement

struct SettingsView: View {
    let audioManager: AudioDeviceManager

    @AppStorage("preferredAudioInputUID") private var preferredDeviceUID = ""
    @AppStorage("autoSwitchPreferred") private var autoSwitch = true
    @AppStorage("appTheme") private var appTheme = AppTheme.system.rawValue
    @State private var launchAtLogin = false

    var body: some View {
        Form {
            audioSection
            appearanceSection
            generalSection
        }
        .formStyle(.grouped)
        .frame(
            minWidth: 380, idealWidth: 460, maxWidth: 600,
            minHeight: 260, idealHeight: 360, maxHeight: 500
        )
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
        .onChange(of: launchAtLogin) { _, newValue in
            updateLoginItem(enabled: newValue)
        }
    }

    // MARK: - Sections

    private var audioSection: some View {
        Section {
            Picker("Preferred Input", selection: $preferredDeviceUID) {
                Text("None").tag("")
                ForEach(audioManager.inputDevices) { device in
                    Label(device.name, systemImage: device.iconName)
                        .tag(device.uid)
                }
            }

            Toggle("Auto-switch when available", isOn: $autoSwitch)

            Text("When enabled, automatically switches to your preferred input device whenever it is detected — preventing other devices from taking over.")
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
