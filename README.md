# LookAway

LookAway is a minimal native macOS break timer built with Swift, SwiftUI, and AppKit. It is inspired by practical digital eye-strain habits, especially the 20-20-20 rule: every 20 minutes, look about 20 feet away for at least 20 seconds.

---

## Installation

### Option 1: Download Pre-built Release (Recommended)

1. Go to the [**Latest Release**](https://github.com/Daksh-Aggarwal/LookAway/releases/latest).
2. Download `LookAway.zip` from the **Assets** section.
3. Unzip the file and drag **`LookAway.app`** into your **`Applications`** folder.

> [!NOTE]  
> **macOS Gatekeeper Warning on First Launch:**  
> Because LookAway is an open-source project and not notarized through a paid Apple Developer certificate ($99/year), macOS may display a warning: *"LookAway cannot be opened because Apple cannot check it for malicious software"* or *"LookAway is damaged and can't be opened."*
>
> **How to open:**
> - **Method A (GUI):** In Finder, open `/Applications`, **Right-Click** (or `Control-Click`) `LookAway.app`, select **Open**, then click **Open** in the dialog. Alternatively, go to **System Settings → Privacy & Security**, scroll down to the security section, and click **Open Anyway**.
> - **Method B (Terminal):** Run the following command to remove the quarantine flag:
>   ```bash
>   xattr -cr /Applications/LookAway.app
>   ```

---

### Option 2: Build from Source

#### Requirements
- macOS 14.0 (Sonoma) or newer
- Xcode 15+ or Swift 6 command line tools

#### Run directly:
```bash
swift build
swift run LookAway
```

#### Package into a standalone macOS `.app` bundle:
```bash
bash Scripts/package_app.sh
open "build/LookAway.app"
```

To install it system-wide:
```bash
cp -R "build/LookAway.app" /Applications/
```

---

## Features

- **Presets**: Built-in timers for 20-20-20, blink resets, focus-distance shifts, and longer hourly decompression breaks.
- **Customizable**: Set custom timer names, work durations, and break intervals.
- **Visual Reminders**: Clean overlay alerts with accept, restart, and pause/disable-for-now actions.
- **System Integration**: Native macOS menu-bar status item, native system notifications, and selectable reminder sounds.
- **Notch-adjacent HUD**: Smooth dynamic HUD appearing from the top-center notch area mirroring the active timer.

---

## For Maintainers: Publishing a Release

### Automated via Git Tag (GitHub Actions)

Creating and pushing a version tag automatically triggers GitHub Actions to build `LookAway.app`, archive it into `LookAway.zip`, and publish a new GitHub Release:

```bash
git tag v0.1.0
git push origin v0.1.0
```

### Manual Release via GitHub Web UI

1. Run the packaging script locally:
   ```bash
   bash Scripts/package_app.sh
   ```
   This generates `build/LookAway.zip`.
2. Go to your repository on GitHub: `https://github.com/Daksh-Aggarwal/LookAway/releases`
3. Click **Draft a new release**.
4. Create a new tag (e.g., `v0.1.0`), enter a release title and changelog notes.
5. Drag and drop `build/LookAway.zip` into the **Attach binaries** dropzone.
6. Click **Publish release**.

---

## Health Note Sources

This app is a habit helper, not medical advice. The included preset ideas are based on common digital eye-strain guidance from Mayo Clinic and the American Academy of Ophthalmology's EyeWiki: take regular breaks, use the 20-20-20 rule, blink often, reduce glare, and keep a comfortable screen setup.
