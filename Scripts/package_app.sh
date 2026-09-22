#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/build/LookAway.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

cd "$ROOT_DIR"
swift build -c release

mkdir -p "$ROOT_DIR/Resources"
swift "$ROOT_DIR/Scripts/make_icon.swift"
iconutil -c icns "$ROOT_DIR/Resources/LookAway.iconset" -o "$ROOT_DIR/Resources/LookAway.icns"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp "$ROOT_DIR/.build/release/LookAway" "$MACOS_DIR/LookAway"
if [[ -f "$ROOT_DIR/Resources/LookAway.icns" ]]; then
  cp "$ROOT_DIR/Resources/LookAway.icns" "$RESOURCES_DIR/LookAway.icns"
fi

cat > "$CONTENTS_DIR/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>LookAway</string>
    <key>CFBundleIdentifier</key>
    <string>com.daksh.lookaway</string>
    <key>CFBundleDisplayName</key>
    <string>LookAway</string>
    <key>CFBundleIconFile</key>
    <string>LookAway</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>LookAway</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 Daksh. All rights reserved.</string>
</dict>
</plist>
PLIST

echo "$APP_DIR"
