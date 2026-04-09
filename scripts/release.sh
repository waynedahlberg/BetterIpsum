#!/bin/bash
# scripts/release.sh
# Builds BetterIpsum and packages it as a signed DMG for GitHub Releases.
#
# Usage:
#   ./scripts/release.sh
#
# Output:
#   ./release/BetterIpsum-<version>.dmg

set -e

# ── Config ────────────────────────────────────────────────────────────────────
APP_NAME="BetterIpsum"
BUNDLE_ID="com.waynedahlberg.BetterIpsum"
VERSION=$(xcodebuild -project BetterIpsum.xcodeproj \
  -scheme BetterIpsum \
  -showBuildSettings 2>/dev/null \
  | grep MARKETING_VERSION \
  | awk '{print $3}')

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPTS_DIR")"
RELEASE_DIR="$ROOT_DIR/release"
DMG_NAME="$APP_NAME-$VERSION.dmg"
APP_PATH="$RELEASE_DIR/$APP_NAME.app"

echo "▶ Building $APP_NAME $VERSION..."

# ── Generate project ──────────────────────────────────────────────────────────
cd "$ROOT_DIR"
xcodegen generate --quiet

# ── Build Release .app ────────────────────────────────────────────────────────
mkdir -p "$RELEASE_DIR"

xcodebuild \
  -project "$APP_NAME.xcodeproj" \
  -scheme "$APP_NAME" \
  -configuration Release \
  -derivedDataPath "$RELEASE_DIR/DerivedData" \
  -archivePath "$RELEASE_DIR/$APP_NAME.xcarchive" \
  archive \
  CODE_SIGNING_ALLOWED=NO \
  | xcpretty 2>/dev/null || true

# Export the .app from the archive
cp -R \
  "$RELEASE_DIR/$APP_NAME.xcarchive/Products/Applications/$APP_NAME.app" \
  "$APP_PATH"

echo "✔ Built $APP_NAME.app"

# ── Create DMG ────────────────────────────────────────────────────────────────
echo "▶ Creating $DMG_NAME..."

# Remove previous DMG if it exists
rm -f "$RELEASE_DIR/$DMG_NAME"

create-dmg \
  --volname "$APP_NAME" \
  --volicon "$SCRIPTS_DIR/VolumeIcon.icns" \
  --background "$SCRIPTS_DIR/dmg-background.png" \
  --window-pos 200 120 \
  --window-size 800 500 \
  --icon-size 128 \
  --icon "$APP_NAME.app" 185 245 \
  --app-drop-link 610 245 \
  --hide-extension "$APP_NAME.app" \
  --no-internet-enable \
  "$RELEASE_DIR/$DMG_NAME" \
  "$APP_PATH"

# ── Fix DMG background (macOS 15 AppleScript workaround) ─────────────────────
# create-dmg's AppleScript silently fails to set the background on macOS 15.
# Fix: convert to read-write, apply background + positions via AppleScript,
# detach, then recompress to the final artifact.

echo "▶ Applying DMG background..."

RW_DMG="$RELEASE_DIR/$APP_NAME-rw.dmg"
MOUNT_POINT="/Volumes/${APP_NAME}RW"

# Detach any stale mounts
hdiutil detach "/Volumes/$APP_NAME" -quiet 2>/dev/null || true
hdiutil detach "$MOUNT_POINT"       -quiet 2>/dev/null || true

# Convert compressed DMG → read-write
hdiutil convert "$RELEASE_DIR/$DMG_NAME" -format UDRW -o "$RW_DMG" -quiet

# Mount read-write
hdiutil attach "$RW_DMG" -mountpoint "$MOUNT_POINT" -quiet

# Apply background image and icon positions via AppleScript
VOLUME_NAME="${APP_NAME}RW"
osascript << APPLESCRIPT
tell application "Finder"
  tell disk "$VOLUME_NAME"
    open
    delay 2
    tell container window
      set current view to icon view
      set toolbar visible to false
      set statusbar visible to false
      set bounds to {200, 120, 1000, 620}
      tell its icon view options
        set arrangement to not arranged
        set icon size to 128
        set background picture to (POSIX file "$MOUNT_POINT/.background/dmg-background.png" as alias)
      end tell
      set position of item "$APP_NAME.app" to {185, 245}
      set position of item "Applications" to {610, 245}
    end tell
    update without registering applications
    delay 5
    close
  end tell
end tell
APPLESCRIPT

# Detach read-write volume
hdiutil detach "$MOUNT_POINT" -quiet

# Recompress to final DMG
rm -f "$RELEASE_DIR/$DMG_NAME"
hdiutil convert "$RW_DMG" -format UDZO -imagekey zlib-level=9 \
  -o "$RELEASE_DIR/$DMG_NAME" -quiet

# Remove read-write copy
rm -f "$RW_DMG"

echo "✔ Background applied"

# ── Cleanup ───────────────────────────────────────────────────────────────────
rm -rf "$RELEASE_DIR/DerivedData"
rm -rf "$RELEASE_DIR/$APP_NAME.xcarchive"
rm -rf "$APP_PATH"

echo ""
echo "✔ Done: release/$DMG_NAME"
echo ""
echo "Next steps:"
echo "  1. Test the DMG — open it and drag to Applications"
echo "  2. Create a GitHub Release tagged v$VERSION"
echo "  3. Attach release/$DMG_NAME to the release"
