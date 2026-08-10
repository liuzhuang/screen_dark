import AppKit
import CoreGraphics

struct DisplayDescriptor: Identifiable, Equatable {
    let id: CGDirectDisplayID
    let persistentID: String
    let name: String
    let isMain: Bool
    let isBuiltIn: Bool
    let frame: CGRect
}

enum DisplayIdentity {
    static func persistentID(for displayID: CGDirectDisplayID, isBuiltIn: Bool) -> String {
        persistentID(
            isBuiltIn: isBuiltIn,
            vendor: CGDisplayVendorNumber(displayID),
            model: CGDisplayModelNumber(displayID),
            serial: CGDisplaySerialNumber(displayID),
            unit: CGDisplayUnitNumber(displayID)
        )
    }

    static func persistentID(
        isBuiltIn: Bool,
        vendor: UInt32,
        model: UInt32,
        serial: UInt32,
        unit: UInt32
    ) -> String {
        let kind = isBuiltIn ? "builtin" : "external"
        let discriminator = serial == 0 || serial == UInt32.max
            ? "unit-\(unit)"
            : "serial-\(serial)"
        return "\(kind)-\(vendor)-\(model)-\(discriminator)"
    }
}

enum DisplayDiscovery {
    private static let screenNumberKey = NSDeviceDescriptionKey("NSScreenNumber")

    static func activeDisplays() -> [DisplayDescriptor] {
        let mainDisplayID = CGMainDisplayID()
        var seen = Set<CGDirectDisplayID>()

        return NSScreen.screens.compactMap { screen in
            guard
                let number = screen.deviceDescription[screenNumberKey] as? NSNumber
            else {
                return nil
            }

            let displayID = CGDirectDisplayID(number.uint32Value)
            guard seen.insert(displayID).inserted else {
                return nil
            }
            let isBuiltIn = CGDisplayIsBuiltin(displayID) != 0

            return DisplayDescriptor(
                id: displayID,
                persistentID: DisplayIdentity.persistentID(
                    for: displayID,
                    isBuiltIn: isBuiltIn
                ),
                name: screen.localizedName,
                isMain: displayID == mainDisplayID,
                isBuiltIn: isBuiltIn,
                frame: screen.frame
            )
        }
        .sorted {
            if $0.isMain != $1.isMain {
                return $0.isMain
            }
            return $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }

}

enum BrightnessLevel {
    static func normalized(_ brightness: Double) -> Double {
        let clamped = min(max(brightness, 0), 1)
        return clamped < 0.005 ? 0 : clamped
    }

    static func shortcutTarget(for brightness: Double, isMain: Bool) -> Double {
        normalized(brightness) == 0 ? (isMain ? 1 : 0.8) : 0
    }
}

enum GammaMath {
    static func scaled(_ table: [CGGammaValue], brightness: Double) -> [CGGammaValue] {
        let factor = CGGammaValue(BrightnessLevel.normalized(brightness))
        return table.map { $0 * factor }
    }
}

enum BlackoutSafety {
    static func canApply(
        brightness: Double,
        to targetID: CGDirectDisplayID,
        currentBrightness: [CGDirectDisplayID: Double],
        recoveryReady: Bool
    ) -> Bool {
        guard currentBrightness[targetID] != nil else {
            return false
        }
        let targetBrightness = BrightnessLevel.normalized(brightness)
        guard targetBrightness == 0 else {
            return true
        }

        let hasVisibleDisplay = currentBrightness.contains { displayID, current in
            let candidate = displayID == targetID ? targetBrightness : current
            return BrightnessLevel.normalized(candidate) > 0
        }
        return hasVisibleDisplay || recoveryReady
    }
}

enum GammaControllerError: LocalizedError {
    case unavailable(CGDirectDisplayID)
    case readFailed(CGDirectDisplayID, CGError)
    case writeFailed(CGDirectDisplayID, CGError)

    var errorDescription: String? {
        switch self {
        case let .unavailable(displayID):
            return "显示器 \(displayID) 不支持 Gamma Table"
        case let .readFailed(displayID, error):
            return "读取显示器 \(displayID) 的 Gamma Table 失败（\(error.rawValue)）"
        case let .writeFailed(displayID, error):
            return "写入显示器 \(displayID) 的 Gamma Table 失败（\(error.rawValue)）"
        }
    }
}

private struct GammaTable {
    let red: [CGGammaValue]
    let green: [CGGammaValue]
    let blue: [CGGammaValue]
    let sampleCount: UInt32
}

final class GammaController {
    private var originalTables: [CGDirectDisplayID: GammaTable] = [:]

    func setBrightness(_ brightness: Double, for displayID: CGDirectDisplayID) throws {
        let original = try originalTable(for: displayID)
        let red = GammaMath.scaled(original.red, brightness: brightness)
        let green = GammaMath.scaled(original.green, brightness: brightness)
        let blue = GammaMath.scaled(original.blue, brightness: brightness)

        let error = CGSetDisplayTransferByTable(
            displayID,
            original.sampleCount,
            red,
            green,
            blue
        )
        guard error == .success else {
            throw GammaControllerError.writeFailed(displayID, error)
        }
    }

    func restore(_ displayID: CGDirectDisplayID) throws {
        guard let original = originalTables[displayID] else {
            return
        }

        let error = CGSetDisplayTransferByTable(
            displayID,
            original.sampleCount,
            original.red,
            original.green,
            original.blue
        )
        guard error == .success else {
            throw GammaControllerError.writeFailed(displayID, error)
        }
        originalTables.removeValue(forKey: displayID)
    }

    @discardableResult
    func restoreAll() -> Set<CGDirectDisplayID> {
        var failedDisplayIDs = Set<CGDirectDisplayID>()
        let tablesToRestore = originalTables
        for (displayID, original) in tablesToRestore {
            let error = CGSetDisplayTransferByTable(
                displayID,
                original.sampleCount,
                original.red,
                original.green,
                original.blue
            )
            if error == .success {
                originalTables.removeValue(forKey: displayID)
            } else {
                failedDisplayIDs.insert(displayID)
            }
        }
        if !failedDisplayIDs.isEmpty {
            CGDisplayRestoreColorSyncSettings()
        }
        return failedDisplayIDs
    }

    private func originalTable(for displayID: CGDirectDisplayID) throws -> GammaTable {
        if let original = originalTables[displayID] {
            return original
        }

        let capacity = CGDisplayGammaTableCapacity(displayID)
        guard capacity > 0 else {
            throw GammaControllerError.unavailable(displayID)
        }

        var red = [CGGammaValue](repeating: 0, count: Int(capacity))
        var green = [CGGammaValue](repeating: 0, count: Int(capacity))
        var blue = [CGGammaValue](repeating: 0, count: Int(capacity))
        var sampleCount: UInt32 = 0

        let error = CGGetDisplayTransferByTable(
            displayID,
            capacity,
            &red,
            &green,
            &blue,
            &sampleCount
        )
        guard error == .success else {
            throw GammaControllerError.readFailed(displayID, error)
        }
        guard sampleCount > 0 else {
            throw GammaControllerError.unavailable(displayID)
        }

        let count = Int(sampleCount)
        let original = GammaTable(
            red: Array(red.prefix(count)),
            green: Array(green.prefix(count)),
            blue: Array(blue.prefix(count)),
            sampleCount: sampleCount
        )
        originalTables[displayID] = original
        return original
    }
}
