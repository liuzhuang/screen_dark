import Carbon.HIToolbox
import CoreGraphics
import Darwin
import Dispatch
import Foundation

@main
enum ThanosLightRecoveryMain {
    static func main() {
        guard CommandLine.arguments.count == 1 else {
            fail("usage: ThanosLightRecovery")
        }

        let hotKey = RecoveryHotKey()
        guard hotKey.install(action: {
            CGDisplayRestoreColorSyncSettings()
            FileHandle.standardOutput.write(Data("RESTORED\n".utf8))
        }) else {
            fail("unable to register exclusive recovery hotkey")
        }

        DispatchQueue.global(qos: .utility).async {
            _ = try? FileHandle.standardInput.readToEnd()
            CGDisplayRestoreColorSyncSettings()
            exit(EXIT_SUCCESS)
        }

        FileHandle.standardOutput.write(Data("READY\n".utf8))
        withExtendedLifetime(hotKey) {
            runEventLoop()
        }
    }

    private static func runEventLoop() -> Never {
        while true {
            var event: EventRef?
            let status = ReceiveNextEvent(
                0,
                nil,
                -1,
                true,
                &event
            )
            guard status == noErr, let event else {
                fail("recovery hotkey event loop stopped")
            }
            _ = SendEventToEventTarget(event, GetEventDispatcherTarget())
            ReleaseEvent(event)
        }
    }

    private static func fail(_ message: String) -> Never {
        FileHandle.standardError.write(Data("ERROR: \(message)\n".utf8))
        exit(EXIT_FAILURE)
    }
}

private final class RecoveryHotKey {
    private static let signature: OSType = 0x54484C54 // THLT
    private static let identifier: UInt32 = 1

    private var eventHandler: EventHandlerRef?
    private var hotKey: EventHotKeyRef?
    private var action: (() -> Void)?

    deinit {
        if let hotKey {
            UnregisterEventHotKey(hotKey)
        }
        if let eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }

    func install(action: @escaping () -> Void) -> Bool {
        self.action = action
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        let userData = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        let handlerStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in
                guard let event, let userData else {
                    return OSStatus(eventNotHandledErr)
                }

                var hotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                guard
                    status == noErr,
                    hotKeyID.signature == RecoveryHotKey.signature,
                    hotKeyID.id == RecoveryHotKey.identifier
                else {
                    return OSStatus(eventNotHandledErr)
                }

                let owner = Unmanaged<RecoveryHotKey>
                    .fromOpaque(userData)
                    .takeUnretainedValue()
                owner.action?()
                return noErr
            },
            1,
            &eventType,
            userData,
            &eventHandler
        )
        guard handlerStatus == noErr else {
            return false
        }

        let hotKeyID = EventHotKeyID(signature: Self.signature, id: Self.identifier)
        let modifiers = UInt32(controlKey | optionKey | cmdKey)
        return RegisterEventHotKey(
            UInt32(kVK_ANSI_B),
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            OptionBits(kEventHotKeyExclusive),
            &hotKey
        ) == noErr
    }
}
