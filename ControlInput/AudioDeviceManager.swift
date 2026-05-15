import Foundation
import CoreAudio
import Observation

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

    enum SwitchSource {
        case user
        case automatic
    }

    // MARK: - Published State

    var inputDevices: [AudioInputDevice] = []
    var currentDefaultDeviceID: AudioDeviceID = kAudioObjectUnknown
    var lastSwitchError: OSStatus?
    var isEnforcingPreferredInput = false

    // MARK: - Private

    /// Suppresses auto-switch briefly after a user-initiated change
    /// to avoid fighting with the user's manual selection.
    private var suppressAutoSwitch = false
    private var suppressionTask: Task<Void, Never>?
    private var enforcementTask: Task<Void, Never>?

    // MARK: - Init

    init() {
        refreshDevices()
        setupListeners()
        schedulePreferredInputEnforcement(delay: .milliseconds(250))
    }

    // MARK: - Computed

    var currentDefaultDevice: AudioInputDevice? {
        inputDevices.first { $0.id == currentDefaultDeviceID }
    }

    var preferredDevice: AudioInputDevice? {
        let preferredUID = UserDefaults.standard.string(forKey: "preferredAudioInputUID") ?? ""
        return inputDevices.first { $0.uid == preferredUID }
    }

    // MARK: - Actions

    func refreshDevices() {
        inputDevices = Self.fetchInputDevices()
        currentDefaultDeviceID = Self.fetchDefaultInputDeviceID()
    }

    @discardableResult
    func setDefaultInputDevice(
        _ device: AudioInputDevice,
        source: SwitchSource = .user
    ) -> Bool {
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
        lastSwitchError = status == noErr ? nil : status
        guard status == noErr else { return false }

        currentDefaultDeviceID = device.id

        if source == .user {
            suppressAutoSwitch = true
            releaseManualSuppressionAfterDelay()
        }

        return true
    }

    @discardableResult
    func autoSwitchIfNeeded() -> Bool {
        let autoSwitch = UserDefaults.standard.bool(forKey: "autoSwitchPreferred")
        let preferredUID = UserDefaults.standard.string(forKey: "preferredAudioInputUID") ?? ""
        let snapshots = inputDevices.map {
            AudioInputSnapshot(id: $0.id, uid: $0.uid)
        }

        guard let preferred = AudioSwitchPolicy.preferredDeviceToRestore(
            devices: snapshots,
            currentDefaultDeviceID: currentDefaultDeviceID,
            preferredUID: preferredUID,
            autoSwitchEnabled: autoSwitch,
            isSuppressed: suppressAutoSwitch
        ) else { return false }

        guard let device = inputDevices.first(where: { $0.id == preferred.id }) else {
            return false
        }

        isEnforcingPreferredInput = true
        let didSwitch = setDefaultInputDevice(device, source: .automatic)
        isEnforcingPreferredInput = false

        if didSwitch {
            schedulePreferredInputEnforcement(delay: .seconds(1), retryCount: 0)
        } else {
            schedulePreferredInputEnforcement(delay: .milliseconds(750), retryCount: 2)
        }

        return true
    }

    func schedulePreferredInputEnforcement(
        delay: Duration = .milliseconds(500),
        retryCount: Int = 1
    ) {
        enforcementTask?.cancel()
        enforcementTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled, let self else { return }

            self.refreshDevices()
            let scheduledFollowUp = self.autoSwitchIfNeeded()

            if retryCount > 0, !scheduledFollowUp {
                self.schedulePreferredInputEnforcement(
                    delay: .milliseconds(750),
                    retryCount: retryCount - 1
                )
            }
        }
    }

    private func releaseManualSuppressionAfterDelay() {
        suppressionTask?.cancel()
        suppressionTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled, let self else { return }
            self.suppressAutoSwitch = false
            self.schedulePreferredInputEnforcement(delay: .milliseconds(250))
        }
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
            mSelector: kAudioDevicePropertyStreamConfiguration,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        var size: UInt32 = 0
        guard AudioObjectGetPropertyDataSize(
            deviceID, &address, 0, nil, &size
        ) == noErr, size > 0 else { return false }

        let bufferList = UnsafeMutableRawPointer.allocate(
            byteCount: Int(size),
            alignment: MemoryLayout<AudioBufferList>.alignment
        )
        defer { bufferList.deallocate() }

        guard AudioObjectGetPropertyData(
            deviceID, &address, 0, nil, &size, bufferList
        ) == noErr else { return false }

        let audioBufferList = bufferList.assumingMemoryBound(to: AudioBufferList.self)
        let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
        return buffers.reduce(0) { $0 + Int($1.mNumberChannels) } > 0
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
                self?.schedulePreferredInputEnforcement()
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
                self.schedulePreferredInputEnforcement()
            }
        }
    }
}
