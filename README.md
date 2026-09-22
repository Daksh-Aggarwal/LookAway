# LookAway

LookAway is a minimal native macOS break timer built with Swift, SwiftUI, and AppKit. It is inspired by practical digital eye-strain habits, especially the 20-20-20 rule: every 20 minutes, look about 20 feet away for at least 20 seconds.

## Running the App

```bash
swift build
swift run LookAway
```

To create and launch a local macOS app bundle:

```bash
bash Scripts/package_app.sh
open "build/LookAway.app"
```

## Features

- **Presets**: Built-in timers for 20-20-20, blink resets, focus-distance shifts, and longer hourly decompression breaks.
- **Customizable**: Set custom timer names, work durations, and break intervals.
- **Visual Reminders**: Clean overlay alerts with accept, restart, and pause/disable-for-now actions.
- **System Integration**: Native macOS menu-bar status item, native system notifications, and selectable reminder sounds.
- **Notch-adjacent HUD**: Smooth dynamic HUD appearing from the top-center notch area mirroring the active timer.

## Health Note Sources

This app is a habit helper, not medical advice. The included preset ideas are based on common digital eye-strain guidance from Mayo Clinic and the American Academy of Ophthalmology's EyeWiki: take regular breaks, use the 20-20-20 rule, blink often, reduce glare, and keep a comfortable screen setup.
