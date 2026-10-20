#!/usr/bin/env bash
# Drives the release APK on an emulator: new recipe -> scan -> gallery ->
# cookbook fixture, then checks that OCR filled in the recipe fields.
set -euo pipefail

PACKAGE=dk.digiida.madplan
STEP=0

dump() { adb exec-out uiautomator dump /dev/tty > ui.xml 2>/dev/null || true; }

shot() {
  STEP=$((STEP + 1))
  adb exec-out screencap -p > "step-$STEP-$1.png"
}

tap() {
  local label=$1
  for _ in $(seq 1 10); do
    dump
    local bounds
    bounds=$(grep -oE "(text|content-desc)=\"[^\"]*${label}[^\"]*\"[^>]*bounds=\"[^\"]*\"" ui.xml \
      | grep -oE 'bounds="[^"]*"' | head -1 | grep -oE '[0-9]+' | tr '\n' ' ' || true)
    if [ -n "$bounds" ]; then
      set -- $bounds
      adb shell input tap $((($1 + $3) / 2)) $((($2 + $4) / 2))
      sleep 2
      return 0
    fi
    sleep 2
  done
  echo "Could not find '$label' on screen" >&2
  shot "missing"
  return 1
}

for _ in $(seq 1 30); do
  adb shell mkdir -p /sdcard/Pictures \
    && adb push test/fixtures/cookbook_page.png /sdcard/Pictures/cookbook_page.png \
    && break
  sleep 5
done
adb shell ls /sdcard/Pictures/cookbook_page.png
adb shell content call --method scan_volume --uri content://media --arg external_primary || true
adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE \
  -d file:///sdcard/Pictures/cookbook_page.png || true

adb install -r app-release.apk
adb logcat -c
adb shell monkey -p "$PACKAGE" -c android.intent.category.LAUNCHER 1
sleep 20
shot start

tap "Ny opskrift"
tap "Scan opskrift"
tap "Vælg fra galleri"
shot picker
tap "Photo taken" || tap "cookbook_page"
sleep 15
shot scanned

dump
adb logcat -d > logcat.txt
grep -q "Gulerodssuppe" ui.xml
grep -q "gulerødder" ui.xml
! grep -E "E flutter|FATAL EXCEPTION" logcat.txt
echo "Scan filled the recipe from the cookbook page"
