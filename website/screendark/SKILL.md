---
name: screendark
description: Control ScreenDark on macOS to darken or restore built-in and external displays without intentionally locking the current session. Use when the user asks to black out a Mac display, keep a long-running task visible only when needed, restore dark displays, or recover the screen with the ScreenDark shortcut.
---

# ScreenDark

Operate ScreenDark only after the user explicitly asks to change a display. Treat darkening as a visual state, not a security lock.

## Darken a display

1. Check that ScreenDark is installed. If needed, launch it with `open -b com.liuzhuang.thanoslight`.
2. Open the `Screen Dark` menu bar item.
3. Identify the requested built-in or external display.
4. Click that display to switch it to dark.

If the user asks to darken every display, warn that Computer Use will lose visual feedback until the recovery shortcut is pressed.

## Restore displays

- Restore one display by opening ScreenDark and clicking that display.
- Restore all displays and their previous brightness with `Control-Option-Command-B`.
- Use the recovery shortcut immediately if the visible state is uncertain.

## Guardrails

- Never describe ScreenDark as locking or securing the Mac.
- Do not change macOS screen saver, automatic lock, or sleep settings unless the user separately requests it.
- Do not invent a download URL. If the app is missing, ask for the source folder and run `bash reinstall.sh` from its root.
- Report that external displays must support macOS Gamma adjustment when a display does not respond.
