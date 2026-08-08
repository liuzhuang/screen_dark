import AppKit
import Carbon.HIToolbox
import CoreGraphics
import ServiceManagement
import SwiftUI

@main
struct ThanosLightApp: App {
    @StateObject private var displayStore = DisplayStore()

    var body: some Scene {
        MenuBarExtra(content: {
            DisplayMenu(store: displayStore)
        }, label: {
            Image(systemName: "display")
                .font(.system(size: 20, weight: .medium))
                .accessibilityLabel("ScreenDark")
        })
        .menuBarExtraStyle(.window)
    }
}

enum DisplayArtwork {
    private static let installedBundleName = "ThanosLight_ThanosLight.bundle"
    private static let names = [
        "display-laptop-bright",
        "display-laptop-dark",
        "display-monitor-bright",
        "display-monitor-dark"
    ]

    static let bundle = Bundle.main.resourceURL
        .flatMap { Bundle(url: $0.appendingPathComponent(installedBundleName)) }
        ?? .module

    private static let images: [String: NSImage] = Dictionary(
        uniqueKeysWithValues: names.compactMap { name -> (String, NSImage)? in
            guard
                let url = bundle.url(forResource: name, withExtension: "png"),
                let image = NSImage(contentsOf: url)
            else {
                return nil
            }
            return (name, image)
        }
    )

    static func image(named name: String) -> NSImage {
        images[name] ?? NSImage()
    }
}

struct DisplayShortcut: Codable, Hashable {
    private static let modifierMask = UInt32(controlKey | optionKey | shiftKey | cmdKey)
    private static let requiredModifierMask = UInt32(controlKey | optionKey | cmdKey)

    let keyCode: UInt32
    let modifiers: UInt32
    let keyLabel: String

    init(keyCode: UInt32, modifiers: UInt32, keyLabel: String) {
        self.keyCode = keyCode
        self.modifiers = modifiers & Self.modifierMask
        self.keyLabel = String(
            keyLabel.trimmingCharacters(in: .whitespacesAndNewlines).uppercased().prefix(8)
        )
    }

    init?(event: NSEvent) {
        guard let keyLabel = Self.keyLabel(for: event) else {
            return nil
        }
        self.init(
            keyCode: UInt32(event.keyCode),
            modifiers: Self.carbonModifiers(for: event.modifierFlags),
            keyLabel: keyLabel
        )
    }

    static let recovery = DisplayShortcut(
        keyCode: UInt32(kVK_ANSI_B),
        modifiers: UInt32(controlKey | optionKey | cmdKey),
        keyLabel: "B"
    )

    var hasRequiredModifier: Bool {
        modifiers & Self.requiredModifierMask != 0
    }

    var displayText: String {
        var text = ""
        if modifiers & UInt32(controlKey) != 0 { text += "⌃" }
        if modifiers & UInt32(optionKey) != 0 { text += "⌥" }
        if modifiers & UInt32(shiftKey) != 0 { text += "⇧" }
        if modifiers & UInt32(cmdKey) != 0 { text += "⌘" }
        return text + keyLabel
    }

    static func == (lhs: DisplayShortcut, rhs: DisplayShortcut) -> Bool {
        lhs.keyCode == rhs.keyCode && lhs.modifiers == rhs.modifiers
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(keyCode)
        hasher.combine(modifiers)
    }

    private enum CodingKeys: String, CodingKey {
        case keyCode
        case modifiers
        case keyLabel
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            keyCode: try values.decode(UInt32.self, forKey: .keyCode),
            modifiers: try values.decode(UInt32.self, forKey: .modifiers),
            keyLabel: try values.decode(String.self, forKey: .keyLabel)
        )
    }

    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(keyCode, forKey: .keyCode)
        try values.encode(modifiers, forKey: .modifiers)
        try values.encode(keyLabel, forKey: .keyLabel)
    }

    private static func carbonModifiers(for flags: NSEvent.ModifierFlags) -> UInt32 {
        var modifiers: UInt32 = 0
        if flags.contains(.control) { modifiers |= UInt32(controlKey) }
        if flags.contains(.option) { modifiers |= UInt32(optionKey) }
        if flags.contains(.shift) { modifiers |= UInt32(shiftKey) }
        if flags.contains(.command) { modifiers |= UInt32(cmdKey) }
        return modifiers
    }

    private static func keyLabel(for event: NSEvent) -> String? {
        switch Int(event.keyCode) {
        case kVK_Space: return "Space"
        case kVK_Return: return "↩"
        case kVK_Tab: return "⇥"
        case kVK_Home: return "↖"
        case kVK_End: return "↘"
        case kVK_PageUp: return "⇞"
        case kVK_PageDown: return "⇟"
        case kVK_LeftArrow: return "←"
        case kVK_RightArrow: return "→"
        case kVK_UpArrow: return "↑"
        case kVK_DownArrow: return "↓"
        case kVK_F1: return "F1"
        case kVK_F2: return "F2"
        case kVK_F3: return "F3"
        case kVK_F4: return "F4"
        case kVK_F5: return "F5"
        case kVK_F6: return "F6"
        case kVK_F7: return "F7"
        case kVK_F8: return "F8"
        case kVK_F9: return "F9"
        case kVK_F10: return "F10"
        case kVK_F11: return "F11"
        case kVK_F12: return "F12"
        case kVK_F13: return "F13"
        case kVK_F14: return "F14"
        case kVK_F15: return "F15"
        case kVK_F16: return "F16"
        case kVK_F17: return "F17"
        case kVK_F18: return "F18"
        case kVK_F19: return "F19"
        case kVK_F20: return "F20"
        default:
            break
        }

        guard let characters = event.charactersIgnoringModifiers, !characters.isEmpty else {
            return nil
        }
        let shiftedBaseLabels = [
            "!": "1", "@": "2", "#": "3", "$": "4", "%": "5",
            "^": "6", "&": "7", "*": "8", "(": "9", ")": "0",
            "_": "-", "+": "=", "{": "[", "}": "]", "|": "\\",
            ":": ";", "\"": "'", "<": ",", ">": ".", "?": "/", "~": "`"
        ]
        return shiftedBaseLabels[characters] ?? characters
    }
}

enum DisplayShortcutValidation {
    enum Issue: Equatable {
        case missingRequiredModifier
        case reservedForRecovery
        case usedByAnotherDisplay
    }

    static func issue(
        for shortcut: DisplayShortcut,
        targetPersistentID: String,
        assignments: [String: DisplayShortcut]
    ) -> Issue? {
        guard shortcut.hasRequiredModifier else {
            return .missingRequiredModifier
        }
        guard shortcut != .recovery else {
            return .reservedForRecovery
        }
        if assignments.contains(where: { persistentID, assigned in
            persistentID != targetPersistentID && assigned == shortcut
        }) {
            return .usedByAnotherDisplay
        }
        return nil
    }
}

enum DisplayShortcutPersistence {
    static func encode(_ assignments: [String: DisplayShortcut]) -> Data? {
        try? JSONEncoder().encode(assignments)
    }

    static func decode(_ data: Data?) -> [String: DisplayShortcut] {
        guard
            let data,
            let decoded = try? JSONDecoder().decode([String: DisplayShortcut].self, from: data)
        else {
            return [:]
        }

        var assignments: [String: DisplayShortcut] = [:]
        for persistentID in decoded.keys.sorted() {
            guard
                let shortcut = decoded[persistentID],
                DisplayShortcutValidation.issue(
                    for: shortcut,
                    targetPersistentID: persistentID,
                    assignments: assignments
                ) == nil
            else {
                continue
            }
            assignments[persistentID] = shortcut
        }
        return assignments
    }
}

enum LaunchAtLogin {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func setEnabled(
        _ enabled: Bool,
        register: () throws -> Void = { try SMAppService.mainApp.register() },
        unregister: () throws -> Void = { try SMAppService.mainApp.unregister() }
    ) throws {
        try (enabled ? register : unregister)()
    }
}

enum DisplayArrangement {
    enum Axis {
        case horizontal
        case vertical
    }

    static func axis(for displays: [DisplayState]) -> Axis {
        let centers = displays.map(\.frame).map { CGPoint(x: $0.midX, y: $0.midY) }
        guard
            let minX = centers.map(\.x).min(),
            let maxX = centers.map(\.x).max(),
            let minY = centers.map(\.y).min(),
            let maxY = centers.map(\.y).max()
        else {
            return .horizontal
        }
        return maxX - minX >= maxY - minY ? .horizontal : .vertical
    }

    static func ordered(_ displays: [DisplayState], along axis: Axis) -> [DisplayState] {
        displays.sorted {
            switch axis {
            case .horizontal:
                return ($0.frame.minX, -$0.frame.maxY) < ($1.frame.minX, -$1.frame.maxY)
            case .vertical:
                return (-$0.frame.maxY, $0.frame.minX) < (-$1.frame.maxY, $1.frame.minX)
            }
        }
    }

    static func crossAxisInset(
        for display: DisplayState,
        among displays: [DisplayState],
        along axis: Axis,
        cardWidth: CGFloat = 259
    ) -> CGFloat {
        let frames = displays.map(\.frame)
        guard
            let firstFrame = frames.first,
            let widestDisplay = frames.map(\.width).max(),
            widestDisplay > 0
        else {
            return 0
        }
        let union = frames.dropFirst().reduce(firstFrame) { $0.union($1) }
        let scale = cardWidth / widestDisplay
        switch axis {
        case .horizontal:
            return max(0, union.maxY - display.frame.maxY) * scale
        case .vertical:
            return max(0, display.frame.minX - union.minX) * scale
        }
    }
}

enum BrightnessSliderGeometry {
    static func brightness(at x: CGFloat, width: CGFloat) -> Double {
        guard x.isFinite, width.isFinite, width > 0 else {
            return 0
        }
        return Double(min(max(x / width, 0), 1))
    }

    static func dividerX(for brightness: Double, width: CGFloat) -> CGFloat {
        guard brightness.isFinite, width.isFinite, width > 0 else {
            return 0
        }
        return CGFloat(min(max(brightness, 0), 1)) * width
    }

    static func handleX(
        for brightness: Double,
        width: CGFloat,
        handleDiameter: CGFloat
    ) -> CGFloat {
        guard width.isFinite, width > 0 else {
            return 0
        }
        let diameter = handleDiameter.isFinite ? max(handleDiameter, 0) : 0
        let radius = min(diameter / 2, width / 2)
        return min(
            max(dividerX(for: brightness, width: width), radius),
            width - radius
        )
    }
}

private struct DisplayMenu: View {
    @ObservedObject var store: DisplayStore

    private var displayColumns: [GridItem] {
        if store.displays.count == 1 {
            return [GridItem(.flexible())]
        }
        return [
            GridItem(.flexible(), spacing: 14),
            GridItem(.flexible())
        ]
    }

    private var arrangementAxis: DisplayArrangement.Axis {
        DisplayArrangement.axis(for: store.displays)
    }

    private var arrangedDisplays: [DisplayState] {
        DisplayArrangement.ordered(store.displays, along: arrangementAxis)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("ScreenDark")
                        .font(.headline)
                    if !store.displays.isEmpty {
                        Text("拖动设备屏幕调整亮度")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Button {
                    store.reloadDisplays()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
                .help("重新识别显示器并点亮全部")
            }

            if store.displays.isEmpty {
                Text("没有检测到可控制的显示器")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 160)
            } else {
                displayControls
            }

            Divider()

            HStack(spacing: 24) {
                Label("Fn+F1/F2 由 macOS 调节", systemImage: "keyboard")
                    .foregroundStyle(.secondary)
                    .help("调整系统亮度会自动点亮已变暗的显示器")
                Spacer(minLength: 12)
                Label(
                    store.recoveryHelperReady ? "安全保护开启" : "安全保护未开启",
                    systemImage: store.recoveryHelperReady
                        ? "checkmark.shield"
                        : "exclamationmark.shield"
                )
                .foregroundStyle(store.recoveryHelperReady ? Color.secondary : Color.orange)
            }
            .font(.caption)

            if let statusMessage = store.statusMessage {
                Label(statusMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let shortcutStatusMessage = store.shortcutStatusMessage {
                Label(shortcutStatusMessage, systemImage: "keyboard")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let launchAtLoginMessage = store.launchAtLoginMessage {
                Label(launchAtLoginMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            HStack(spacing: 18) {
                Toggle(
                    "登录时启动",
                    isOn: Binding(
                        get: { store.launchesAtLogin },
                        set: { store.setLaunchAtLogin($0) }
                    )
                )
                .toggleStyle(.checkbox)
                .controlSize(.small)
                .help("登录 macOS 后自动启动 ScreenDark")

                Spacer()

                HStack(spacing: 4) {
                    Text("点亮全部")
                    Text("⌃⌥⌘B")
                        .monospaced()
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                Button("退出 ScreenDark") {
                    store.restoreSystemGammaAll()
                    NSApplication.shared.terminate(nil)
                }
                .controlSize(.small)
            }
        }
        .padding(16)
        .frame(width: 540)
        .onAppear {
            store.refreshLaunchAtLoginStatus()
        }
        .onDisappear {
            store.cancelShortcutRecording()
        }
    }

    @ViewBuilder
    private var displayControls: some View {
        if store.displays.count == 2, arrangementAxis == .horizontal {
            HStack(alignment: .top, spacing: 14) {
                ForEach(arrangedDisplays) { display in
                    DisplayControlCard(
                        display: display,
                        store: store,
                        previewOffset: CGSize(
                            width: 0,
                            height: min(
                                DisplayArrangement.crossAxisInset(
                                    for: display,
                                    among: store.displays,
                                    along: arrangementAxis,
                                    cardWidth: 220
                                ),
                                12
                            )
                        )
                    )
                    .frame(width: 247)
                }
            }
            .frame(maxWidth: .infinity)
        } else if store.displays.count == 2, arrangementAxis == .vertical {
            VStack(alignment: .center, spacing: 14) {
                ForEach(arrangedDisplays) { display in
                    DisplayControlCard(
                        display: display,
                        store: store,
                        previewOffset: CGSize(
                            width: min(
                                DisplayArrangement.crossAxisInset(
                                    for: display,
                                    among: store.displays,
                                    along: arrangementAxis,
                                    cardWidth: 220
                                ),
                                12
                            ),
                            height: 0
                        )
                    )
                    .frame(width: 247)
                }
            }
            .frame(maxWidth: .infinity)
        } else {
            LazyVGrid(columns: displayColumns, alignment: .center, spacing: 14) {
                ForEach(store.displays) { display in
                    DisplayControlCard(display: display, store: store)
                }
            }
        }
    }
}

private struct DisplayControlCard: View {
    let display: DisplayState
    @ObservedObject var store: DisplayStore
    var previewOffset: CGSize = .zero

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                BrightnessImageSlider(display: display, store: store)
                    .offset(previewOffset)
            }
            .frame(width: 232, height: 162)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(display.isBuiltIn ? "内建显示器" : "外接显示器")
                        .font(.subheadline.weight(.semibold))
                    Text(display.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                Text("\(Int((display.brightness * 100).rounded()))%")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                    .monospacedDigit()
            }

            HStack(spacing: 8) {
                if display.isMain {
                    Label("主显示器", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                DisplayShortcutButton(display: display, store: store)
            }
        }
        .frame(maxWidth: 247)
    }
}

private struct BrightnessImageSlider: View {
    let display: DisplayState
    @ObservedObject var store: DisplayStore
    @FocusState private var isFocused: Bool
    @GestureState private var isDragging = false
    @State private var isHovering = false

    var body: some View {
        GeometryReader { geometry in
            let screen = screenRect(in: geometry.size)
            let dividerX = screen.minX + BrightnessSliderGeometry.dividerX(
                for: display.brightness,
                width: screen.width
            )
            let handleDiameter: CGFloat = 24
            let handleX = screen.minX + BrightnessSliderGeometry.handleX(
                for: display.brightness,
                width: screen.width,
                handleDiameter: handleDiameter
            )
            let isActive = isHovering || isDragging || isFocused

            ZStack {
                deviceBase(screen: screen)

                screenContent(screen: screen)

                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    .frame(width: screen.width, height: screen.height)
                    .position(x: screen.midX, y: screen.midY)

                Rectangle()
                    .fill(Color.white.opacity(0.88))
                    .frame(width: 1.5, height: screen.height - 4)
                    .shadow(color: .black.opacity(0.3), radius: 1)
                    .position(x: dividerX, y: screen.midY)

                Image(systemName: "arrow.left.and.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(isActive ? Color.white : Color.primary)
                    .frame(width: handleDiameter, height: handleDiameter)
                    .background(
                        isActive ? Color.accentColor : Color(nsColor: .controlBackgroundColor),
                        in: Circle()
                    )
                    .overlay {
                        Circle().strokeBorder(
                            isActive ? Color.accentColor : Color.primary.opacity(0.22),
                            lineWidth: isActive ? 2 : 1
                        )
                    }
                    .shadow(color: .black.opacity(0.22), radius: 2, y: 1)
                    .position(x: handleX, y: screen.midY)

                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Color.clear)
                    .frame(width: screen.width, height: screen.height)
                    .position(x: screen.midX, y: screen.midY)
                    .focusable()
                    .focused($isFocused)
                    .onMoveCommand { direction in
                        switch direction {
                        case .left, .down:
                            adjustBrightness(by: -0.05)
                        case .right, .up:
                            adjustBrightness(by: 0.05)
                        default:
                            break
                        }
                    }
            }
            .contentShape(Rectangle())
            .onHover { isHovering = $0 }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        store.setBrightness(
                            BrightnessSliderGeometry.brightness(
                                at: value.location.x - screen.minX,
                                width: screen.width
                            ),
                            for: display.id
                        )
                    }
            )
        }
        .frame(width: 220, height: 150)
        .help("点击或左右拖动，调整\(display.name)亮度")
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(display.name)亮度")
        .accessibilityValue("\(Int((display.brightness * 100).rounded()))%")
        .accessibilityHint("点击或左右拖动；聚焦后可用方向键调整")
        .accessibilityAdjustableAction { direction in
            adjustBrightness(by: direction == .increment ? 0.05 : -0.05)
        }
    }

    private func screenRect(in size: CGSize) -> CGRect {
        CGRect(x: 25, y: 14, width: max(0, size.width - 50), height: 100)
    }

    @ViewBuilder
    private func deviceBase(screen: CGRect) -> some View {
        if display.isBuiltIn {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
                .overlay {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                }
                .frame(width: screen.width + 34, height: 14)
                .position(x: screen.midX, y: screen.maxY + 10)

            Capsule()
                .fill(Color.primary.opacity(0.22))
                .frame(width: 38, height: 2)
                .position(x: screen.midX, y: screen.maxY + 7)
        } else {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
                .overlay {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.18), lineWidth: 1)
                }
                .frame(width: 14, height: 24)
                .position(x: screen.midX, y: screen.maxY + 15)

            Capsule()
                .fill(Color(nsColor: .controlBackgroundColor))
                .overlay {
                    Capsule().strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                }
                .frame(width: 64, height: 7)
                .position(x: screen.midX, y: screen.maxY + 29)
        }

        RoundedRectangle(cornerRadius: 9, style: .continuous)
            .fill(Color.black.opacity(0.86))
            .frame(width: screen.width + 10, height: screen.height + 10)
            .position(x: screen.midX, y: screen.midY)

        Circle()
            .fill(Color.white.opacity(0.28))
            .frame(width: 3, height: 3)
            .position(x: screen.midX, y: screen.minY - 2.5)
    }

    private func screenContent(screen: CGRect) -> some View {
        let brightWidth = BrightnessSliderGeometry.dividerX(
            for: display.brightness,
            width: screen.width
        )

        return ZStack(alignment: .leading) {
            LinearGradient(
                colors: [Color.black.opacity(0.98), Color.black.opacity(0.78)],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.42, blue: 0.96),
                    Color(red: 0.20, green: 0.78, blue: 0.88),
                    Color(red: 0.48, green: 0.88, blue: 0.74)
                ],
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            .frame(width: brightWidth, height: screen.height)
        }
        .frame(width: screen.width, height: screen.height, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        .position(x: screen.midX, y: screen.midY)
    }

    private func adjustBrightness(by amount: Double) {
        store.setBrightness(display.brightness + amount, for: display.id)
    }
}

private struct DisplayShortcutButton: View {
    let display: DisplayState
    @ObservedObject var store: DisplayStore

    private var shortcut: DisplayShortcut? {
        store.shortcut(for: display)
    }

    private var isRecording: Bool {
        store.recordingShortcutFor == display.persistentID
    }

    private var title: String {
        if isRecording {
            return store.shortcutStatusMessage == nil ? "请按组合键…" : "请重试…"
        }
        return shortcut?.displayText ?? "设置快捷键"
    }

    var body: some View {
        Button {
            store.beginShortcutRecording(for: display)
        } label: {
            HStack(spacing: 3) {
                if shortcut == nil && !isRecording {
                    Image(systemName: "keyboard")
                }
                Text(title)
                    .monospaced()
            }
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .foregroundStyle(
                isRecording && store.shortcutStatusMessage != nil
                    ? Color.orange
                    : isRecording ? Color.accentColor : Color.primary
            )
            .background(
                isRecording ? Color.accentColor.opacity(0.14) : Color.primary.opacity(0.06),
                in: Capsule()
            )
            .overlay {
                Capsule()
                    .strokeBorder(
                        isRecording ? Color.accentColor.opacity(0.6) : Color.clear,
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            if shortcut != nil {
                Button("清除快捷键") {
                    store.clearShortcut(for: display)
                }
            }
        }
        .help(
            isRecording
                ? "按组合键完成设置；Esc 取消，Delete 清除"
                : "点击设置\(display.name)的变黑/点亮快捷键"
        )
        .accessibilityLabel("\(display.name)快捷键")
        .accessibilityValue(isRecording ? "正在录入" : shortcut?.displayText ?? "未设置")
        .accessibilityHint("点击后按组合键；Esc 取消，Delete 清除")
    }
}

struct DisplayState: Identifiable, Equatable {
    let id: CGDirectDisplayID
    let persistentID: String
    let name: String
    let isMain: Bool
    let isBuiltIn: Bool
    let frame: CGRect
    var brightness: Double
    private(set) var brightnessBeforeBlackout: Double

    init(
        id: CGDirectDisplayID,
        persistentID: String? = nil,
        name: String,
        isMain: Bool,
        isBuiltIn: Bool,
        brightness: Double,
        frame: CGRect = .zero
    ) {
        self.id = id
        self.persistentID = persistentID ?? "runtime-\(id)"
        self.name = name
        self.isMain = isMain
        self.isBuiltIn = isBuiltIn
        self.frame = frame
        self.brightness = brightness
        brightnessBeforeBlackout = brightness > 0 ? brightness : 1
    }

    mutating func recordBrightness(_ brightness: Double) {
        self.brightness = brightness
        if brightness > 0 {
            brightnessBeforeBlackout = brightness
        }
    }

    var brightnessToRestore: Double {
        brightness == 0 ? brightnessBeforeBlackout : brightness
    }
}

enum BrightnessPersistence {
    static func encode(_ brightnessByDisplay: [String: Double]) -> Data? {
        try? JSONEncoder().encode(brightnessByDisplay)
    }

    static func decode(_ data: Data?) -> [String: Double] {
        guard
            let data,
            let decoded = try? JSONDecoder().decode([String: Double].self, from: data)
        else {
            return [:]
        }
        return decoded.filter { $0.value.isFinite && $0.value > 0 && $0.value <= 1 }
    }
}

private final class DisplayStore: ObservableObject {
    private static let gammaRecoveryKey = "gammaTablesNeedRecovery"
    private static let shortcutAssignmentsKey = "displayShortcuts"
    private static let savedBrightnessKey = "displayBrightness"

    @Published private(set) var displays: [DisplayState] = []
    @Published private(set) var recoveryHelperReady = false
    @Published private(set) var displayShortcuts: [String: DisplayShortcut]
    @Published private(set) var recordingShortcutFor: String?
    @Published private(set) var shortcutStatusMessage: String?
    @Published private(set) var launchesAtLogin = LaunchAtLogin.isEnabled
    @Published private(set) var launchAtLoginMessage: String?
    @Published var statusMessage: String?

    private let gammaController = GammaController()
    private let recoveryHelper = RecoveryHelperProcess()
    private let shortcutRegistry = GlobalHotKeyRegistry()
    private lazy var nativeBrightnessMonitor = NativeBrightnessMonitor(
        readBrightness: { SystemDisplayBrightness.value(for: $0) },
        restoreBlackDisplay: { [weak self] displayID in
            self?.restoreAfterNativeBrightnessChange(displayID)
        }
    )
    private var observers: [NSObjectProtocol] = []
    private var workspaceObserver: NSObjectProtocol?
    private var idleSleepActivity: NSObjectProtocol?
    private var nativeBrightnessTimer: Timer?
    private var shortcutEventMonitor: Any?
    private var savedBrightness: [String: Double]

    init() {
        displayShortcuts = DisplayShortcutPersistence.decode(
            UserDefaults.standard.data(forKey: Self.shortcutAssignmentsKey)
        )
        savedBrightness = BrightnessPersistence.decode(
            UserDefaults.standard.data(forKey: Self.savedBrightnessKey)
        )
        recoverGammaAfterUncleanExitIfNeeded()
        reloadDisplayList()
        observeLifecycle()
        startRecoveryHelper()
    }

    deinit {
        if let shortcutEventMonitor {
            NSEvent.removeMonitor(shortcutEventMonitor)
        }
        nativeBrightnessTimer?.invalidate()
        observers.forEach(NotificationCenter.default.removeObserver)
        if let workspaceObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(workspaceObserver)
        }
        if let idleSleepActivity {
            ProcessInfo.processInfo.endActivity(idleSleepActivity)
        }
        gammaController.restoreAll()
    }

    @discardableResult
    func setBrightness(_ brightness: Double, for displayID: CGDirectDisplayID) -> Bool {
        let clamped = BrightnessLevel.normalized(brightness)
        let current = Dictionary(uniqueKeysWithValues: displays.map { ($0.id, $0.brightness) })
        let helperReady = recoveryHelperReady && recoveryHelper.isReady
        guard BlackoutSafety.canApply(
            brightness: clamped,
            to: displayID,
            currentBrightness: current,
            recoveryReady: helperReady
        ) else {
            statusMessage = "安全守护未就绪，已阻止最后一块亮屏变暗"
            return false
        }
        let currentBrightness = displays.first(where: { $0.id == displayID })?.brightness ?? 1
        let wasBlack = currentBrightness == 0
        let monitorsNativeBrightness = clamped == 0
            && nativeBrightnessMonitor.beginMonitoring(displayID)
        if clamped < 1 || currentBrightness < 1 {
            markGammaForRecovery()
        }
        do {
            if clamped == 1 {
                try gammaController.restore(displayID)
            } else {
                try gammaController.setBrightness(clamped, for: displayID)
            }
            update(displayID) { $0.recordBrightness(clamped) }
            if let display = displays.first(where: { $0.id == displayID }) {
                savedBrightness[display.persistentID] = display.brightnessToRestore
                UserDefaults.standard.set(
                    BrightnessPersistence.encode(savedBrightness),
                    forKey: Self.savedBrightnessKey
                )
            }
            if clamped > 0 {
                nativeBrightnessMonitor.stopMonitoring(displayID)
            }
            updateNativeBrightnessTimer()
            updateIdleSleepActivity()
            statusMessage = clamped == 0 && !monitorsNativeBrightness
                ? "该显示器不支持系统亮度检测；请使用 ⌃⌥⌘B 点亮全部"
                : nil
            clearGammaRecoveryMarkerIfFullyRestored()
            return true
        } catch {
            if !wasBlack {
                nativeBrightnessMonitor.stopMonitoring(displayID)
            }
            updateNativeBrightnessTimer()
            statusMessage = error.localizedDescription
            return false
        }
    }

    func toggle(_ displayID: CGDirectDisplayID) {
        guard let display = displays.first(where: { $0.id == displayID }) else {
            return
        }
        setBrightness(
            BrightnessLevel.shortcutTarget(for: display.brightness, isMain: display.isMain),
            for: displayID
        )
    }

    @discardableResult
    func restoreSystemGammaAll() -> Bool {
        let failedDisplayIDs = gammaController.restoreAll()
        for index in displays.indices where !failedDisplayIDs.contains(displays[index].id) {
            nativeBrightnessMonitor.stopMonitoring(displays[index].id)
            displays[index].recordBrightness(1)
        }
        updateNativeBrightnessTimer()
        updateIdleSleepActivity()
        if failedDisplayIDs.isEmpty {
            clearGammaRecoveryMarker()
            statusMessage = nil
        } else {
            statusMessage = "部分屏幕点亮失败，已保留原始 Gamma 并调用 ColorSync；可再次点亮全部"
        }
        return failedDisplayIDs.isEmpty
    }

    func canBlackout(_ displayID: CGDirectDisplayID) -> Bool {
        let current = Dictionary(uniqueKeysWithValues: displays.map { ($0.id, $0.brightness) })
        return BlackoutSafety.canApply(
            brightness: 0,
            to: displayID,
            currentBrightness: current,
            recoveryReady: recoveryHelperReady && recoveryHelper.isReady
        )
    }

    func shortcut(for display: DisplayState) -> DisplayShortcut? {
        displayShortcuts[display.persistentID]
    }

    func beginShortcutRecording(for display: DisplayState) {
        guard displays.contains(where: { $0.persistentID == display.persistentID }) else {
            return
        }
        if recordingShortcutFor == display.persistentID {
            cancelShortcutRecording()
            return
        }
        stopShortcutEventMonitor()
        shortcutRegistry.removeAll()
        recordingShortcutFor = display.persistentID
        shortcutStatusMessage = nil
        shortcutEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            [weak self] event in
            self?.recordShortcut(from: event, for: display.persistentID) ?? event
        }
    }

    func cancelShortcutRecording() {
        guard recordingShortcutFor != nil || shortcutEventMonitor != nil else {
            return
        }
        stopShortcutEventMonitor()
        recordingShortcutFor = nil
        shortcutStatusMessage = nil
        reconcileShortcutRegistrations()
    }

    func shortcutValidationMessage(
        for shortcut: DisplayShortcut,
        to display: DisplayState
    ) -> String? {
        guard recordingShortcutFor == display.persistentID else {
            return "快捷键录入已取消"
        }
        if let issue = DisplayShortcutValidation.issue(
            for: shortcut,
            targetPersistentID: display.persistentID,
            assignments: displayShortcuts
        ) {
            switch issue {
            case .missingRequiredModifier:
                return "请按一个包含 ⌃、⌥ 或 ⌘ 的组合键"
            case .reservedForRecovery:
                return "⌃⌥⌘B 用于安全点亮全部，请选择其他组合键"
            case .usedByAnotherDisplay:
                return "\(shortcut.displayText) 已用于其他显示器"
            }
        }
        guard shortcutRegistry.isAvailable(shortcut) else {
            return "\(shortcut.displayText) 已被系统或其他应用占用"
        }
        return nil
    }

    func assignShortcut(_ shortcut: DisplayShortcut, to display: DisplayState) {
        guard recordingShortcutFor == display.persistentID else {
            return
        }
        if let message = shortcutValidationMessage(for: shortcut, to: display) {
            shortcutStatusMessage = message
            NSSound.beep()
            return
        }

        displayShortcuts[display.persistentID] = shortcut
        persistShortcuts()
        stopShortcutEventMonitor()
        recordingShortcutFor = nil
        shortcutStatusMessage = nil
        reconcileShortcutRegistrations()
    }

    func clearShortcut(for display: DisplayState) {
        displayShortcuts.removeValue(forKey: display.persistentID)
        persistShortcuts()
        stopShortcutEventMonitor()
        recordingShortcutFor = nil
        shortcutStatusMessage = nil
        reconcileShortcutRegistrations()
    }

    func reloadDisplays() {
        restoreSystemGammaAll()
        reloadDisplayList()
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            try LaunchAtLogin.setEnabled(enabled)
            refreshLaunchAtLoginStatus()
            launchAtLoginMessage = enabled && !launchesAtLogin
                ? "请在系统设置的登录项中允许 ScreenDark 自动启动"
                : nil
        } catch {
            refreshLaunchAtLoginStatus()
            launchAtLoginMessage = "自动启动设置失败：\(error.localizedDescription)"
        }
    }

    func refreshLaunchAtLoginStatus() {
        launchesAtLogin = LaunchAtLogin.isEnabled
        if launchesAtLogin {
            launchAtLoginMessage = nil
        }
    }

    private func reloadDisplayList() {
        displays = DisplayDiscovery.activeDisplays().map {
            DisplayState(
                id: $0.id,
                persistentID: $0.persistentID,
                name: $0.name,
                isMain: $0.isMain,
                isBuiltIn: $0.isBuiltIn,
                brightness: 1,
                frame: $0.frame
            )
        }
        let savedTargets = displays.compactMap { display in
            savedBrightness[display.persistentID].map { (display.id, $0) }
        }
        for (displayID, brightness) in savedTargets {
            setBrightness(brightness, for: displayID)
        }
        reconcileShortcutRegistrations()
    }

    private func persistShortcuts() {
        UserDefaults.standard.set(
            DisplayShortcutPersistence.encode(displayShortcuts),
            forKey: Self.shortcutAssignmentsKey
        )
    }

    private func recordShortcut(
        from event: NSEvent,
        for persistentID: String
    ) -> NSEvent? {
        guard
            recordingShortcutFor == persistentID,
            let display = displays.first(where: { $0.persistentID == persistentID })
        else {
            cancelShortcutRecording()
            return event
        }
        guard !event.isARepeat else {
            return nil
        }

        switch Int(event.keyCode) {
        case kVK_Escape:
            cancelShortcutRecording()
        case kVK_Delete, kVK_ForwardDelete:
            clearShortcut(for: display)
        default:
            guard let shortcut = DisplayShortcut(event: event) else {
                shortcutStatusMessage = "请按一个包含 ⌃、⌥ 或 ⌘ 的组合键"
                NSSound.beep()
                return nil
            }
            assignShortcut(shortcut, to: display)
        }
        return nil
    }

    private func stopShortcutEventMonitor() {
        guard let shortcutEventMonitor else {
            return
        }
        NSEvent.removeMonitor(shortcutEventMonitor)
        self.shortcutEventMonitor = nil
    }

    private func reconcileShortcutRegistrations() {
        shortcutRegistry.removeAll()
        guard recordingShortcutFor == nil else {
            return
        }

        var failures: [String] = []
        var registeredDisplays = Set<String>()
        for display in displays {
            guard
                registeredDisplays.insert(display.persistentID).inserted,
                let shortcut = displayShortcuts[display.persistentID]
            else {
                continue
            }
            let persistentID = display.persistentID
            if !shortcutRegistry.register(
                shortcut,
                owner: persistentID,
                action: { [weak self] in self?.toggleDisplay(persistentID) }
            ) {
                failures.append("\(display.name) \(shortcut.displayText)")
            }
        }
        shortcutStatusMessage = failures.isEmpty
            ? nil
            : "快捷键被系统或其他应用占用：\(failures.joined(separator: "、"))"
    }

    private func toggleDisplay(_ persistentID: String) {
        guard let displayID = displays.first(where: { $0.persistentID == persistentID })?.id else {
            return
        }
        toggle(displayID)
    }

    private func update(_ displayID: CGDirectDisplayID, change: (inout DisplayState) -> Void) {
        guard let index = displays.firstIndex(where: { $0.id == displayID }) else {
            return
        }
        change(&displays[index])
    }

    private func observeLifecycle() {
        let center = NotificationCenter.default

        observers.append(center.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reloadDisplays()
        })

        observers.append(center.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.restoreSystemGammaAll()
        })

        workspaceObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.willSleepNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.restoreSystemGammaAll()
        }

    }

    private func startRecoveryHelper() {
        statusMessage = "正在启动安全守护…"
        let started = recoveryHelper.start(
            onReady: { [weak self] in
                self?.recoveryHelperReady = true
                self?.statusMessage = nil
            },
            onRestore: { [weak self] in
                self?.restoreSystemGammaAll()
            },
            onUnexpectedExit: { [weak self] in
                self?.handleRecoveryHelperExit()
            }
        )
        if !started {
            statusMessage = "无法启动安全守护；不会允许全部屏幕变暗"
        }
    }

    private func handleRecoveryHelperExit() {
        recoveryHelperReady = false
        let hadAdjustedDisplay = displays.contains(where: { $0.brightness < 1 })
        if hadAdjustedDisplay {
            if restoreSystemGammaAll() {
                statusMessage = "安全守护意外停止，已自动点亮屏幕；重启应用后可再次变暗"
            }
        } else {
            statusMessage = "安全守护意外停止；重启应用后可再次变暗"
        }
    }

    private func markGammaForRecovery() {
        UserDefaults.standard.set(true, forKey: Self.gammaRecoveryKey)
        UserDefaults.standard.synchronize()
    }

    private func clearGammaRecoveryMarkerIfFullyRestored() {
        if displays.allSatisfy({ $0.brightness == 1 }) {
            clearGammaRecoveryMarker()
        }
    }

    private func clearGammaRecoveryMarker() {
        UserDefaults.standard.removeObject(forKey: Self.gammaRecoveryKey)
        UserDefaults.standard.synchronize()
    }

    private func recoverGammaAfterUncleanExitIfNeeded() {
        guard UserDefaults.standard.bool(forKey: Self.gammaRecoveryKey) else {
            return
        }
        CGDisplayRestoreColorSyncSettings()
        clearGammaRecoveryMarker()
    }

    private func updateIdleSleepActivity() {
        let needsActivity = displays.contains(where: { $0.brightness == 0 })
        if needsActivity, idleSleepActivity == nil {
            idleSleepActivity = ProcessInfo.processInfo.beginActivity(
                options: .idleSystemSleepDisabled,
                reason: "Keep background work running while a display is black"
            )
        } else if !needsActivity, let idleSleepActivity {
            ProcessInfo.processInfo.endActivity(idleSleepActivity)
            self.idleSleepActivity = nil
        }
    }

    private func restoreAfterNativeBrightnessChange(_ displayID: CGDirectDisplayID) {
        guard displays.first(where: { $0.id == displayID })?.brightness == 0 else {
            return
        }
        setBrightness(1, for: displayID)
        if displays.first(where: { $0.id == displayID })?.brightness == 1 {
            statusMessage = "已响应系统亮度调节并点亮屏幕"
        }
    }

    private func updateNativeBrightnessTimer() {
        guard nativeBrightnessMonitor.hasMonitoredDisplays else {
            nativeBrightnessTimer?.invalidate()
            nativeBrightnessTimer = nil
            return
        }
        guard nativeBrightnessTimer == nil else {
            return
        }

        let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else {
                return
            }
            let blackDisplayIDs = Set(
                displays.lazy.filter { $0.brightness == 0 }.map(\.id)
            )
            nativeBrightnessMonitor.poll(blackDisplayIDs: blackDisplayIDs)
            updateNativeBrightnessTimer()
        }
        RunLoop.main.add(timer, forMode: .common)
        nativeBrightnessTimer = timer
    }
}

private final class GlobalHotKeyRegistry {
    private static let signature: OSType = 0x5344524B // SDRK

    private struct Registration {
        let identifier: UInt32
        let reference: EventHotKeyRef
        let shortcut: DisplayShortcut
    }

    private var eventHandler: EventHandlerRef?
    private var nextIdentifier: UInt32 = 1
    private var registrations: [String: Registration] = [:]
    private var actions: [UInt32: () -> Void] = [:]

    init() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        let userData = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in
                guard let event, let userData else {
                    return OSStatus(eventNotHandledErr)
                }
                let registry = Unmanaged<GlobalHotKeyRegistry>
                    .fromOpaque(userData)
                    .takeUnretainedValue()
                return registry.handle(event)
            },
            1,
            &eventType,
            userData,
            &eventHandler
        )
    }

    deinit {
        removeAll()
        if let eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }

    func isAvailable(_ shortcut: DisplayShortcut) -> Bool {
        guard eventHandler != nil else {
            return false
        }
        var hotKey: EventHotKeyRef?
        let status = RegisterEventHotKey(
            shortcut.keyCode,
            shortcut.modifiers,
            hotKeyID(),
            GetApplicationEventTarget(),
            OptionBits(kEventHotKeyExclusive),
            &hotKey
        )
        guard status == noErr, let hotKey else {
            return false
        }
        UnregisterEventHotKey(hotKey)
        return true
    }

    func register(
        _ shortcut: DisplayShortcut,
        owner: String,
        action: @escaping () -> Void
    ) -> Bool {
        guard eventHandler != nil else {
            return false
        }
        if let registration = registrations[owner], registration.shortcut == shortcut {
            actions[registration.identifier] = action
            return true
        }

        let hotKeyID = hotKeyID()
        var hotKey: EventHotKeyRef?
        let status = RegisterEventHotKey(
            shortcut.keyCode,
            shortcut.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            OptionBits(kEventHotKeyExclusive),
            &hotKey
        )
        guard status == noErr, let hotKey else {
            return false
        }

        unregister(owner)
        registrations[owner] = Registration(
            identifier: hotKeyID.id,
            reference: hotKey,
            shortcut: shortcut
        )
        actions[hotKeyID.id] = action
        return true
    }

    func removeAll() {
        registrations.values.forEach { UnregisterEventHotKey($0.reference) }
        registrations.removeAll()
        actions.removeAll()
    }

    private func unregister(_ owner: String) {
        guard let registration = registrations.removeValue(forKey: owner) else {
            return
        }
        UnregisterEventHotKey(registration.reference)
        actions.removeValue(forKey: registration.identifier)
    }

    private func hotKeyID() -> EventHotKeyID {
        let identifier = nextIdentifier
        nextIdentifier &+= 1
        return EventHotKeyID(signature: Self.signature, id: identifier)
    }

    private func handle(_ event: EventRef) -> OSStatus {
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
            hotKeyID.signature == Self.signature,
            let action = actions[hotKeyID.id]
        else {
            return OSStatus(eventNotHandledErr)
        }
        action()
        return noErr
    }
}

private final class RecoveryHelperProcess {
    private var process: Process?
    private var inputPipe: Pipe?
    private var outputPipe: Pipe?
    private var outputBuffer = ""
    private var ready = false
    private var onReady: (() -> Void)?
    private var onRestore: (() -> Void)?
    private var onUnexpectedExit: (() -> Void)?

    var isReady: Bool {
        ready && process?.isRunning == true
    }

    @discardableResult
    func start(
        onReady: @escaping () -> Void,
        onRestore: @escaping () -> Void,
        onUnexpectedExit: @escaping () -> Void
    ) -> Bool {
        guard process == nil else {
            return isReady
        }
        guard let executableDirectory = Bundle.main.executableURL?.deletingLastPathComponent() else {
            return false
        }

        let bundledHelperURL = Bundle.main.bundleURL.appendingPathComponent(
            "Contents/Helpers/ThanosLightRecovery.app/Contents/MacOS/ThanosLightRecovery"
        )
        let adjacentHelperURL = executableDirectory.appendingPathComponent("ThanosLightRecovery")
        let helperURL = FileManager.default.isExecutableFile(atPath: bundledHelperURL.path)
            ? bundledHelperURL
            : adjacentHelperURL
        guard FileManager.default.isExecutableFile(atPath: helperURL.path) else {
            return false
        }

        let process = Process()
        let inputPipe = Pipe()
        let outputPipe = Pipe()
        process.executableURL = helperURL
        process.standardInput = inputPipe
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        var environment = ProcessInfo.processInfo.environment
        environment.removeValue(forKey: "__CFBundleIdentifier")
        environment.removeValue(forKey: "XPC_SERVICE_NAME")
        environment.removeValue(forKey: "XPC_FLAGS")
        process.environment = environment
        self.process = process
        self.inputPipe = inputPipe
        self.outputPipe = outputPipe
        self.onReady = onReady
        self.onRestore = onRestore
        self.onUnexpectedExit = onUnexpectedExit

        outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            DispatchQueue.main.async {
                self?.consumeOutput(data)
            }
        }
        process.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.didTerminate()
            }
        }

        do {
            try process.run()
            inputPipe.fileHandleForReading.closeFile()
            return true
        } catch {
            outputPipe.fileHandleForReading.readabilityHandler = nil
            inputPipe.fileHandleForReading.closeFile()
            inputPipe.fileHandleForWriting.closeFile()
            self.process = nil
            self.inputPipe = nil
            self.outputPipe = nil
            return false
        }
    }

    private func consumeOutput(_ data: Data) {
        guard !data.isEmpty else {
            outputPipe?.fileHandleForReading.readabilityHandler = nil
            return
        }
        outputBuffer.append(String(decoding: data, as: UTF8.self))
        while let newline = outputBuffer.firstIndex(of: "\n") {
            let line = String(outputBuffer[..<newline])
            outputBuffer.removeSubrange(...newline)
            switch line {
            case "READY" where !ready && process?.isRunning == true:
                ready = true
                onReady?()
            case "RESTORED":
                onRestore?()
            default:
                break
            }
        }
    }

    private func didTerminate() {
        outputPipe?.fileHandleForReading.readabilityHandler = nil
        ready = false
        process = nil
        inputPipe = nil
        outputPipe = nil
        onUnexpectedExit?()
    }
}
