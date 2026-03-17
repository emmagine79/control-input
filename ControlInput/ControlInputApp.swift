import SwiftUI

@main
struct ControlInputApp: App {
    @AppStorage("appTheme") private var appTheme = AppTheme.system.rawValue
    @State private var audioManager = AudioDeviceManager()

    init() {
        UserDefaults.standard.register(defaults: [
            "autoSwitchPreferred": true,
            "appTheme": AppTheme.system.rawValue
        ])
        // NSApp is nil during init — defer theme application to onAppear.
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(audioManager: audioManager)
                .onAppear {
                    (AppTheme(rawValue: appTheme) ?? .system).apply()
                }
                .onChange(of: appTheme) { _, newValue in
                    (AppTheme(rawValue: newValue) ?? .system).apply()
                }
        } label: {
            Label("Control Input", systemImage: "mic.fill")
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(audioManager: audioManager)
        }
    }
}
