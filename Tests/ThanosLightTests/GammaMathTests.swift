import Carbon.HIToolbox
import CoreGraphics
import XCTest
@testable import ThanosLight

final class GammaMathTests: XCTestCase {
    func testLaunchAtLoginUsesTheRequestedSystemAction() throws {
        var actions: [String] = []

        try LaunchAtLogin.setEnabled(
            true,
            register: { actions.append("register") },
            unregister: { actions.append("unregister") }
        )
        try LaunchAtLogin.setEnabled(
            false,
            register: { actions.append("register") },
            unregister: { actions.append("unregister") }
        )

        XCTAssertEqual(actions, ["register", "unregister"])
    }

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

    func testBrightnessPersistenceKeepsOnlyVisibleLevels() {
        let encoded = BrightnessPersistence.encode([
            "display-a": 0.4,
            "display-b": 1,
            "black": 0,
            "too-bright": 1.1
        ])

        XCTAssertEqual(
            BrightnessPersistence.decode(encoded),
            ["display-a": 0.4, "display-b": 1]
        )
        XCTAssertEqual(BrightnessPersistence.decode(Data("invalid".utf8)), [:])
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

    func testBrightnessSliderGeometryClampsMappingsAndKeepsHandleInsideTrack() {
        let width: CGFloat = 100
        let handleDiameter: CGFloat = 24
        let pixelAccuracy: CGFloat = 0.0001

        XCTAssertEqual(
            BrightnessSliderGeometry.brightness(at: -10, width: width),
            0,
            accuracy: 0.000_000_001
        )
        XCTAssertEqual(
            BrightnessSliderGeometry.brightness(at: 50, width: width),
            0.5,
            accuracy: 0.000_000_001
        )
        XCTAssertEqual(
            BrightnessSliderGeometry.brightness(at: 110, width: width),
            1,
            accuracy: 0.000_000_001
        )
        XCTAssertEqual(
            BrightnessSliderGeometry.dividerX(for: 0.5, width: width),
            50,
            accuracy: pixelAccuracy
        )
        XCTAssertEqual(
            BrightnessSliderGeometry.handleX(
                for: 0,
                width: width,
                handleDiameter: handleDiameter
            ),
            handleDiameter / 2,
            accuracy: pixelAccuracy
        )
        XCTAssertEqual(
            BrightnessSliderGeometry.handleX(
                for: 1,
                width: width,
                handleDiameter: handleDiameter
            ),
            width - handleDiameter / 2,
            accuracy: pixelAccuracy
        )
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

    func testBrightnessDisplayedAsZeroRequiresRecoveryHelper() {
        let displayID: CGDirectDisplayID = 1

        XCTAssertEqual(BrightnessLevel.normalized(0.004), 0)
        XCTAssertEqual(BrightnessLevel.normalized(0.005), 0.005)
        XCTAssertFalse(BlackoutSafety.canApply(
            brightness: 0.004,
            to: displayID,
            currentBrightness: [displayID: 1],
            recoveryReady: false
        ))
        XCTAssertTrue(BlackoutSafety.canApply(
            brightness: 0.004,
            to: displayID,
            currentBrightness: [displayID: 1],
            recoveryReady: true
        ))
    }

    func testDisplayShortcutUsesDefaultBrightnessWithoutMemory() {
        XCTAssertEqual(BrightnessLevel.shortcutTarget(for: 0, isMain: true), 1)
        XCTAssertEqual(BrightnessLevel.shortcutTarget(for: 0, isMain: false), 0.8)
        XCTAssertEqual(BrightnessLevel.shortcutTarget(for: 0.004, isMain: false), 0.8)
        XCTAssertEqual(BrightnessLevel.shortcutTarget(for: 0.34, isMain: true), 0)
        XCTAssertEqual(BrightnessLevel.shortcutTarget(for: 0.8, isMain: false), 0)
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

    func testDisplayArrangementUsesNativeScreenCoordinates() {
        let upperLeft = DisplayState(
            id: 1,
            name: "Built-in Display",
            isMain: true,
            isBuiltIn: true,
            brightness: 1,
            frame: CGRect(x: 0, y: 20, width: 100, height: 80)
        )
        let lowerRight = DisplayState(
            id: 2,
            name: "External Display",
            isMain: false,
            isBuiltIn: false,
            brightness: 1,
            frame: CGRect(x: 100, y: 0, width: 100, height: 80)
        )
        let displays = [lowerRight, upperLeft]

        XCTAssertEqual(DisplayArrangement.axis(for: displays), .horizontal)
        XCTAssertEqual(
            DisplayArrangement.ordered(displays, along: .horizontal).map(\.id),
            [upperLeft.id, lowerRight.id]
        )
        XCTAssertEqual(
            DisplayArrangement.crossAxisInset(
                for: lowerRight,
                among: displays,
                along: .horizontal,
                cardWidth: 100
            ),
            20
        )

        let verticalDisplays = [
            lowerRight,
            DisplayState(
                id: 3,
                name: "Upper Display",
                isMain: false,
                isBuiltIn: false,
                brightness: 1,
                frame: CGRect(x: 120, y: 100, width: 100, height: 80)
            )
        ]
        XCTAssertEqual(DisplayArrangement.axis(for: verticalDisplays), .vertical)
        XCTAssertEqual(
            DisplayArrangement.ordered(verticalDisplays, along: .vertical).map(\.id),
            [3, lowerRight.id]
        )
    }
}
