import Foundation
import CoreAudio

@Observable
@MainActor
final class AudioDeviceManager {

    // MARK: - Types

    struct AudioInputDevice: Identifiable, Hashable {
        let id: AudioDeviceID
        let name: String
        let uid: String
        let transportType: UInt32

        var iconName: String {
            switch transportType {
            case kAudioDeviceTransportTypeBuiltIn:
                return "desktopcomputer"
            case kAudioDeviceTransportTypeBluetooth,
                 kAudioDeviceTransportTypeBluetoothLE:
                return "headphones"
            case kAudioDeviceTransportTypeUSB:
                return "cable.connector"
            case kAudioDeviceTransportTypeVirtual:
                return "waveform"
            default:
                return "mic.fill"
            }
        }
    }

    // MARK: - Published State

    var inputDevices: [AudioInputDevice] = []
    var currentDefaultDeviceID: AudioDeviceID = kAudioObjectUnknown

    // MARK: - Private

    /// Suppresses auto-switch briefly after a user-initiated change
    /// to avoid fighting with the user's manual selection.
    private var suppressAutoSwitch = false

    // MARK: - Init

    init() {
        refreshDevices()
        setupListeners()
        autoSwitchIfNeeded()
    }

    // MARK: - Computed

    var currentDefaultDevice: AudioInputDevice? {
        inputDevices.first { $0.id == currentDefaultDeviceID }
    }

    // MARK: - Actions

    func refreshDevices() {
        inputDevices = Self.fetchInputDevices()
        currentDefaultDeviceID = Self.fetchDefaultInputDeviceID()
    }

    func setDefaultInputDevice(_ device: AudioInputDevice) {
        suppressAutoSwitch = true

        var deviceID = device.id
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        let status = AudioObjectSetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address, 0, nil,
            UInt32(MemoryLayout<AudioDeviceID>.size),
            &deviceID
        )
        if status == noErr {
            currentDefaultDeviceID = device.id
        }

        // Allow auto-switch again after a brief delay so the system
        // has time to settle and we don't immediately override the user.
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(2))
            self?.suppressAutoSwitch = false
        }
    }

    func autoSwitchIfNeeded() {
        guard !suppressAutoSwitch else { return }

        let autoSwitch = UserDefaults.standard.bool(forKey: "autoSwitchPreferred")
        let preferredUID = UserDefaults.standard.string(forKey: "preferredAudioInputUID") ?? ""

        guard autoSwitch, !preferredUID.isEmpty else { return }
        guard let preferred = inputDevices.first(where: { $0.uid == preferredUID }) else { return }
        guard preferred.id != currentDefaultDeviceID else { return }

        setDefaultInputDevice(preferred)
    }

    // MARK: - CoreAudio Queries

    nonisolated private static func fetchInputDevices() -> [AudioInputDevice] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var dataSize: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &address, 0, nil, &dataSize
        ) == noErr else { return [] }

        let count = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
        var deviceIDs = [AudioDeviceID](repeating: 0, count: count)
        guard AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address, 0, nil, &dataSize, &deviceIDs
        ) == noErr else { return [] }

        return deviceIDs.compactMap { deviceID in
            guard hasInputStreams(deviceID) else { return nil }
            let name = getStringProperty(deviceID, selector: kAudioObjectPropertyName)
            let uid = getStringProperty(deviceID, selector: kAudioDevicePropertyDeviceUID)
            let transport = getTransportType(deviceID)
            return AudioInputDevice(
                id: deviceID,
                name: name,
                uid: uid,
                transportType: transport
            )
        }
    }

    nonisolated private static func fetchDefaultInputDeviceID() -> AudioDeviceID {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var deviceID: AudioDeviceID = kAudioObjectUnknown
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)
        AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address, 0, nil, &size, &deviceID
        )
        return deviceID
    }

    nonisolated private static func hasInputStreams(_ deviceID: AudioDeviceID) -> Bool {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        var size: UInt32 = 0
        return AudioObjectGetPropertyDataSize(
            deviceID, &address, 0, nil, &size
        ) == noErr && size > 0
    }

    nonisolated private static func getStringProperty(
        _ deviceID: AudioDeviceID,
        selector: AudioObjectPropertySelector
    ) -> String {
        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var cfStr: Unmanaged<CFString>?
        var size = UInt32(MemoryLayout.size(ofValue: cfStr))
        let status = AudioObjectGetPropertyData(
            deviceID, &address, 0, nil, &size, &cfStr
        )
        guard status == noErr, let result = cfStr else { return "" }
        return result.takeUnretainedValue() as String
    }

    nonisolated private static func getTransportType(_ deviceID: AudioDeviceID) -> UInt32 {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyTransportType,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var transport: UInt32 = 0
        var size = UInt32(MemoryLayout<UInt32>.size)
        AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &transport)
        return transport
    }

    // MARK: - Listeners

    private func setupListeners() {
        // Device list changes (connect / disconnect)
        var devicesAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        AudioObjectAddPropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &devicesAddress,
            nil
        ) { [weak self] _, _ in
            Task { @MainActor in
                self?.refreshDevices()
                self?.autoSwitchIfNeeded()
            }
        }

        // Default input device changed (by macOS or another app)
        var defaultAddress = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        AudioObjectAddPropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &defaultAddress,
            nil
        ) { [weak self] _, _ in
            Task { @MainActor in
                guard let self else { return }
                self.currentDefaultDeviceID = Self.fetchDefaultInputDeviceID()
                self.autoSwitchIfNeeded()
            }
        }
    }
}
