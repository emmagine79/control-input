import Foundation

struct AudioInputSnapshot: Equatable {
    let id: UInt32
    let uid: String
}

enum AudioSwitchPolicy {
    static func preferredDeviceToRestore(
        devices: [AudioInputSnapshot],
        currentDefaultDeviceID: UInt32,
        preferredUID: String,
        autoSwitchEnabled: Bool,
        isSuppressed: Bool
    ) -> AudioInputSnapshot? {
        guard !isSuppressed else { return nil }
        guard autoSwitchEnabled, !preferredUID.isEmpty else { return nil }
        guard let preferred = devices.first(where: { $0.uid == preferredUID }) else {
            return nil
        }
        guard preferred.id != currentDefaultDeviceID else { return nil }
        return preferred
    }
}
