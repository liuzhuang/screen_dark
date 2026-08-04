# Thanos Light Design QA

## Evidence

- User reference: `/var/folders/1l/0857hfhn1h52mq0x1b5gtq800000gn/T/codex-clipboard-eef252d1-617a-49c6-801e-7d1dea1fb52a.png`
- Reported large-color-block implementation: `/var/folders/1l/0857hfhn1h52mq0x1b5gtq800000gn/T/codex-clipboard-e4bbf368-e100-48b2-b13d-5315630fa127.png`
- Same-state live runtime evidence before the final image cleanup: `/private/tmp/thanos-light-image-ui-final-dark-crop.png`
- Full-view reference/runtime comparison: `/private/tmp/thanos-light-image-qa-comparison.png`
- Final bright-laptop/dark-monitor asset stage: `/private/tmp/thanos-light-final-device-stage.png`
- Final same-state focused comparison, reference left and implementation assets right: `/private/tmp/thanos-light-final-device-comparison.png`
- Final four-state asset inspection: `/private/tmp/thanos-light-final-assets-transparent.png`

## Viewport and state

- Reference raster: 1234 x 1274 px.
- Runtime capture: 3456 x 2234 px at 2x; menu width 600 pt.
- Focused comparison: both sides are 1234 x 500 px. The implementation stage uses the same 520 x 430 px source slots that render as approximately 260 x 215 pt at 2x.
- Matched state: light appearance, built-in laptop bright, external monitor dark.

## Iteration history

### Pass 1 — failed

- [P1] The implementation represented displays with large blue cards and outline symbols, while the reference used recognizable laptop and monitor hardware.
  - Fix: replaced both cards with four dedicated raster states: laptop bright/dark and monitor bright/dark.

### Pass 2 — failed

- [P2] SwiftUI's package image lookup rendered the raw PNG resources blank in the debug executable.
  - Fix: load and cache each packaged PNG as `NSImage`, with the installed resource bundle preferred and SwiftPM's module bundle as fallback.

### Pass 3 — failed

- [P2] Early source crops retained baked action labels, causing duplicate controls when SwiftUI added the live action button.
- [P2] Laptop and monitor files used different opaque background tones, making their rectangular image bounds visible.
  - Fix: rebuilt all screens without baked labels, kept one live `Text` action overlay, and removed only the connected image background to transparent while preserving hardware edges and shadows.

### Pass 4 — passed

- Final focused comparison: `/private/tmp/thanos-light-final-device-comparison.png`.
- The hardware silhouettes, bright/dark screen states, proportions, and spacing now match the reference closely without large colored containers or visible image rectangles.
- No actionable P0, P1, or P2 visual findings remain.

## Required fidelity surfaces

- Device imagery: the built-in display is a photoreal laptop and the external display is a photoreal monitor; no SF Symbol substitutes remain.
- Background treatment: every device asset has a transparent exterior, so it inherits the native white menu surface instead of introducing a card-sized color block.
- State treatment: bright and dark are separate screen images, not a tint over one generic card.
- Interaction: the entire 214 pt device stage remains one button; the centered `暗屏` or `点亮` label is drawn dynamically and is not baked into the image.
- Layout: both devices retain equal grid tracks, aligned metadata, percentage, slider, footer status, recovery action, and exit action.
- Accessibility: the whole device button retains its label, hint, tooltip, and disabled safety state.

## Interaction and build evidence

- In the live two-display run, clicking `27D1QL` changed it from `100% / 暗屏` to `0% / 点亮`; clicking again restored it to `100% / 暗屏`.
- The recovery helper reported `安全守护已就绪` during the run.
- `swift test`: 4 tests passed, including all four image resources loading as valid `NSImage` instances.
- `swift build -c release`: passed; the release resource bundle contains all four PNG files.
- `bash -n reinstall.sh` and both plist lint checks passed.

## Evidence limitation

- The macOS session locked before the final transparent-asset runtime recapture. The final same-state QA therefore combines the already-verified live layout and interaction capture with a focused render of the exact packaged assets. No install was performed.

## Implementation checklist

- [x] Main display renders as a laptop; external display renders as a monitor.
- [x] Clicking the device toggles bright and dark states.
- [x] No large display-card color blocks remain.
- [x] Device image backgrounds are consistent and transparent.
- [x] Action copy uses `暗屏`, `点亮`, and `点亮全部`.
- [x] Four resources are packaged, loadable, and included in Release.
- [x] Tests and Release build pass.

final result: passed
