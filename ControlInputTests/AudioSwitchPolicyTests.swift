import XCTest

final class AudioSwitchPolicyTests: XCTestCase {
    func testDoesNotSwitchWhileSuppressed() {
        let devices = [
            AudioInputSnapshot(id: 1, uid: "preferred"),
            AudioInputSnapshot(id: 2, uid: "airpods")
        ]

        let decision = AudioSwitchPolicy.preferredDeviceToRestore(
            devices: devices,
            currentDefaultDeviceID: 2,
            preferredUID: "preferred",
            autoSwitchEnabled: true,
            isSuppressed: true
        )

        XCTAssertNil(decision)
    }

    func testDoesNotSwitchWhenAutoSwitchDisabled() {
        let devices = [
            AudioInputSnapshot(id: 1, uid: "preferred"),
            AudioInputSnapshot(id: 2, uid: "airpods")
        ]

        let decision = AudioSwitchPolicy.preferredDeviceToRestore(
            devices: devices,
            currentDefaultDeviceID: 2,
            preferredUID: "preferred",
            autoSwitchEnabled: false,
            isSuppressed: false
        )

        XCTAssertNil(decision)
    }

    func testDoesNotSwitchWhenPreferredUIDIsEmpty() {
        let devices = [
            AudioInputSnapshot(id: 1, uid: "preferred"),
            AudioInputSnapshot(id: 2, uid: "airpods")
        ]

        let decision = AudioSwitchPolicy.preferredDeviceToRestore(
            devices: devices,
            currentDefaultDeviceID: 2,
            preferredUID: "",
            autoSwitchEnabled: true,
            isSuppressed: false
        )

        XCTAssertNil(decision)
    }

    func testDoesNotSwitchWhenPreferredDeviceIsUnavailable() {
        let devices = [
            AudioInputSnapshot(id: 2, uid: "airpods")
        ]

        let decision = AudioSwitchPolicy.preferredDeviceToRestore(
            devices: devices,
            currentDefaultDeviceID: 2,
            preferredUID: "preferred",
            autoSwitchEnabled: true,
            isSuppressed: false
        )

        XCTAssertNil(decision)
    }

    func testDoesNotSwitchWhenPreferredDeviceIsAlreadyDefault() {
        let devices = [
            AudioInputSnapshot(id: 1, uid: "preferred")
        ]

        let decision = AudioSwitchPolicy.preferredDeviceToRestore(
            devices: devices,
            currentDefaultDeviceID: 1,
            preferredUID: "preferred",
            autoSwitchEnabled: true,
            isSuppressed: false
        )

        XCTAssertNil(decision)
    }

    func testReturnsPreferredDeviceWhenAvailableAndDifferentFromDefault() {
        let devices = [
            AudioInputSnapshot(id: 1, uid: "preferred"),
            AudioInputSnapshot(id: 2, uid: "airpods")
        ]

        let decision = AudioSwitchPolicy.preferredDeviceToRestore(
            devices: devices,
            currentDefaultDeviceID: 2,
            preferredUID: "preferred",
            autoSwitchEnabled: true,
            isSuppressed: false
        )

        XCTAssertEqual(decision?.id, 1)
        XCTAssertEqual(decision?.uid, "preferred")
    }
}
