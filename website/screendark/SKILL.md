---
name: screendark
description: Control ScreenDark on macOS to adjust, darken, or restore built-in and external displays without intentionally locking the current session. Use when the user asks to change a Mac display's visual brightness, set one or all displays to black, restore dark displays, or recover the screen with the ScreenDark shortcut.
---

# ScreenDark

Operate ScreenDark only after the user explicitly asks to change a display. Treat darkening as a visual Gamma state, not a security lock or physical power state.

## Adjust or darken a display

1. Check that ScreenDark is installed. If needed, launch it with `open -b com.liuzhuang.thanoslight`.
2. Open the `ScreenDark` menu bar item.
3. Identify the requested built-in or external display.
4. Click or drag across that display's device preview to set the requested brightness. Set it to `0%` only when the user asks for a black screen.

If the user asks to darken every display, confirm the fixed recovery shortcut before setting the last visible display to `0%`.

ScreenDark requests `.idleSystemSleepDisabled` only while at least one display is at `0%`. Brightness values from `1%` to `99%` do not trigger that request. ScreenDark does not actively lock the Mac, but macOS automatic lock, the screen saver, app state, permissions, and capture paths still determine whether other work continues.

## Restore displays

- Restore one display by opening ScreenDark and moving that display above `0%`, or use its configured shortcut.
- Restore all system Gamma and set every ScreenDark display state to `100%` with `Control-Option-Command-B`.
- Use the recovery shortcut immediately if the visible state is uncertain.

## Guardrails

- Never describe ScreenDark as locking or securing the Mac.
- Never describe `0%` as powering off the display or backlight.
- Never promise that ScreenDark keeps every task, browser action, or remote session running.
- Do not change macOS screen saver, automatic lock, or sleep settings unless the user separately requests it.
- Do not invent a download URL. If the app is missing, ask for the source folder and run `bash reinstall.sh` from its root.
- Report that external displays must support macOS Gamma adjustment when a display does not respond.
