import Carbon.HIToolbox
import CoreGraphics
import XCTest
@testable import ThanosLight

final class GammaMathTests: XCTestCase {
    func testBlackoutRestoresTheLastVisibleBrightness() {
        var display = DisplayState(
            id: 1,
            name: "Built-in Display",
            isMain: true,
            isBuiltIn: true,
            brightness: 1
        )

        display.recordBrightness(0.4)
        display.recordBrightness(0)

        XCTAssertEqual(display.brightnessToRestore, 0.4)
    }

    func testRecoveryShortcutRestoresEachDisplayToItsPreviousBrightness() {
        let visibleDisplay = DisplayState(
            id: 1,
            name: "Built-in Display",
            isMain: true,
            isBuiltIn: true,
            brightness: 0.35
        )
        var blackDisplay = DisplayState(
            id: 2,
            name: "External Display",
            isMain: false,
            isBuiltIn: false,
            brightness: 0.6
        )
        blackDisplay.recordBrightness(0)

        XCTAssertEqual(visibleDisplay.brightnessToRestore, 0.35)
        XCTAssertEqual(
            BrightnessRestoration.recoveryTargets(for: [visibleDisplay, blackDisplay]),
            [visibleDisplay.id: 0.35, blackDisplay.id: 0.6]
        )
    }

    func testDisplayArtworkResourcesAreBundled() {
        let names = [
            "display-laptop-bright",
            "display-laptop-dark",
            "display-monitor-bright",
            "display-monitor-dark"
        ]

        for name in names {
            XCTAssertNotNil(
                DisplayArtwork.bundle.url(forResource: name, withExtension: "png"),
                "Missing display artwork: \(name)"
            )
            XCTAssertTrue(DisplayArtwork.image(named: name).isValid)
        }
    }

    func testScalingAlwaysUsesTheBaselineTable() {
        let baseline: [CGGammaValue] = [0, 0.25, 0.5, 1]

        XCTAssertEqual(GammaMath.scaled(baseline, brightness: 0), [0, 0, 0, 0])
        XCTAssertEqual(GammaMath.scaled(baseline, brightness: 0.5), [0, 0.125, 0.25, 0.5])
        XCTAssertEqual(GammaMath.scaled(baseline, brightness: 1), baseline)
        XCTAssertEqual(GammaMath.scaled(baseline, brightness: -1), [0, 0, 0, 0])
        XCTAssertEqual(GammaMath.scaled(baseline, brightness: 2), baseline)
    }

    func testLastVisibleDisplayRequiresRecoveryHelper() {
        let internalID: CGDirectDisplayID = 1
        let externalID: CGDirectDisplayID = 2

        XCTAssertTrue(BlackoutSafety.canApply(
            brightness: 0,
            to: internalID,
            currentBrightness: [internalID: 1, externalID: 1],
            recoveryReady: false
        ))
        XCTAssertFalse(BlackoutSafety.canApply(
            brightness: 0,
            to: externalID,
            currentBrightness: [internalID: 0, externalID: 1],
            recoveryReady: false
        ))
        XCTAssertTrue(BlackoutSafety.canApply(
            brightness: 0,
            to: externalID,
            currentBrightness: [internalID: 0, externalID: 1],
            recoveryReady: true
        ))
    }

    func testNativeBrightnessChangeRestoresOnlyMonitoredBlackDisplay() {
        let displayID: CGDirectDisplayID = 1
        var nativeBrightness = 0.4
        var restoredDisplayIDs: [CGDirectDisplayID] = []
        let monitor = NativeBrightnessMonitor(
            readBrightness: { _ in nativeBrightness },
            restoreBlackDisplay: { restoredDisplayIDs.append($0) }
        )

        XCTAssertTrue(monitor.beginMonitoring(displayID))
        monitor.poll(blackDisplayIDs: [displayID])
        XCTAssertTrue(restoredDisplayIDs.isEmpty)

        nativeBrightness = 0.5
        monitor.poll(blackDisplayIDs: [displayID])
        XCTAssertEqual(restoredDisplayIDs, [displayID])

        nativeBrightness = 0.6
        monitor.poll(blackDisplayIDs: [displayID])
        XCTAssertEqual(restoredDisplayIDs, [displayID, displayID])

        nativeBrightness = 0.7
        monitor.poll(blackDisplayIDs: [])
        XCTAssertEqual(restoredDisplayIDs, [displayID, displayID])
    }

    func testDisplayShortcutNormalizesAndFormatsModifiers() {
        let shortcut = DisplayShortcut(
            keyCode: UInt32(kVK_ANSI_D),
            modifiers: UInt32(controlKey | optionKey | alphaLock),
            keyLabel: "d"
        )

        XCTAssertEqual(shortcut.modifiers, UInt32(controlKey | optionKey))
        XCTAssertEqual(shortcut.displayText, "⌃⌥D")
        XCTAssertEqual(
            shortcut,
            DisplayShortcut(
                keyCode: UInt32(kVK_ANSI_D),
                modifiers: UInt32(controlKey | optionKey),
                keyLabel: "D"
            )
        )
    }

    func testDisplayShortcutValidationRejectsUnsafeReservedAndDuplicateBindings() {
        let plain = DisplayShortcut(
            keyCode: UInt32(kVK_ANSI_D),
            modifiers: 0,
            keyLabel: "D"
        )
        let shiftOnly = DisplayShortcut(
            keyCode: UInt32(kVK_ANSI_D),
            modifiers: UInt32(shiftKey),
            keyLabel: "D"
        )
        let assigned = DisplayShortcut(
            keyCode: UInt32(kVK_ANSI_D),
            modifiers: UInt32(controlKey | optionKey),
            keyLabel: "D"
        )

        XCTAssertEqual(
            DisplayShortcutValidation.issue(
                for: plain,
                targetPersistentID: "display-a",
                assignments: [:]
            ),
            .missingRequiredModifier
        )
        XCTAssertEqual(
            DisplayShortcutValidation.issue(
                for: shiftOnly,
                targetPersistentID: "display-a",
                assignments: [:]
            ),
            .missingRequiredModifier
        )
        XCTAssertEqual(
            DisplayShortcutValidation.issue(
                for: .recovery,
                targetPersistentID: "display-a",
                assignments: [:]
            ),
            .reservedForRecovery
        )
        XCTAssertEqual(
            DisplayShortcutValidation.issue(
                for: assigned,
                targetPersistentID: "display-b",
                assignments: ["display-a": assigned]
            ),
            .usedByAnotherDisplay
        )
        XCTAssertNil(
            DisplayShortcutValidation.issue(
                for: assigned,
                targetPersistentID: "display-a",
                assignments: ["display-a": assigned]
            )
        )
    }

    func testDisplayShortcutPersistenceRoundTripsAndRejectsCorruptData() {
        let assignments = [
            "display-a": DisplayShortcut(
                keyCode: UInt32(kVK_ANSI_1),
                modifiers: UInt32(controlKey | optionKey),
                keyLabel: "1"
            )
        ]

        let encoded = DisplayShortcutPersistence.encode(assignments)

        XCTAssertEqual(DisplayShortcutPersistence.decode(encoded), assignments)
        XCTAssertEqual(DisplayShortcutPersistence.decode(Data("invalid".utf8)), [:])
    }

    func testDisplayHardwareIdentityUsesSerialOrFallsBackToUnit() {
        XCTAssertEqual(
            DisplayIdentity.persistentID(
                isBuiltIn: false,
                vendor: 10,
                model: 20,
                serial: 30,
                unit: 1
            ),
            DisplayIdentity.persistentID(
                isBuiltIn: false,
                vendor: 10,
                model: 20,
                serial: 30,
                unit: 2
            )
        )
        XCTAssertNotEqual(
            DisplayIdentity.persistentID(
                isBuiltIn: false,
                vendor: 10,
                model: 20,
                serial: 0,
                unit: 1
            ),
            DisplayIdentity.persistentID(
                isBuiltIn: false,
                vendor: 10,
                model: 20,
                serial: 0,
                unit: 2
            )
        )
    }
}
