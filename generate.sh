#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./generate.sh [--macos 11.0] [--ios 14.0] [--zip] [--checksum]
#
# Flags:
#   --macos <ver>   Override MACOSX_DEPLOYMENT_TARGET (default: 11.0 via Makefile)
#   --ios <ver>     Override IPHONEOS_DEPLOYMENT_TARGET (default: 14.0 via Makefile)
#   --zip           Zip the xcframework to src/out/wg-go.xcframework.zip
#   --checksum      Print SwiftPM checksum of the zip (implies --zip)
#
# Notes:
#   - Script assumes paths relative to repo root.
#   - Makefile in src/ outputs per-platform fat libs and src/out/wg-go.xcframework

MACOS_VER=""
IOS_VER=""
DO_ZIP=0
DO_CHECKSUM=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --macos)
      MACOS_VER="$2"; shift 2;;
    --ios)
      IOS_VER="$2"; shift 2;;
    --zip)
      DO_ZIP=1; shift;;
    --checksum)
      DO_ZIP=1; DO_CHECKSUM=1; shift;;
    *)
      echo "Unknown arg: $1" >&2; exit 2;;
  esac
done

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

# Build
if [[ -n "$MACOS_VER" && -n "$IOS_VER" ]]; then
  echo "==> Building with MACOSX_DEPLOYMENT_TARGET=$MACOS_VER IPHONEOS_DEPLOYMENT_TARGET=$IOS_VER"
  make -C src clean
  MACOSX_DEPLOYMENT_TARGET="$MACOS_VER" IPHONEOS_DEPLOYMENT_TARGET="$IOS_VER" make -C src build
elif [[ -n "$MACOS_VER" ]]; then
  echo "==> Building with MACOSX_DEPLOYMENT_TARGET=$MACOS_VER"
  make -C src clean
  MACOSX_DEPLOYMENT_TARGET="$MACOS_VER" make -C src build
elif [[ -n "$IOS_VER" ]]; then
  echo "==> Building with IPHONEOS_DEPLOYMENT_TARGET=$IOS_VER"
  make -C src clean
  IPHONEOS_DEPLOYMENT_TARGET="$IOS_VER" make -C src build
else
  echo "==> Building with Makefile defaults"
  make -C src clean && make -C src build
fi

# Sanity checks
function check_file() { [[ -f "$1" ]] || { echo "Missing $1" >&2; exit 1; }; }
check_file src/out/macos/libwg-go.a
check_file src/out/ios-sim/libwg-go.a
check_file src/out/ios-device/libwg-go.a
check_file src/out/wg-go.xcframework/Info.plist

set -x
lipo -info src/out/macos/libwg-go.a
lipo -info src/out/ios-sim/libwg-go.a
file src/out/ios-device/libwg-go.a
ls -R src/out/wg-go.xcframework
set +x

# Optional packaging
ZIP_PATH="src/out/wg-go.xcframework.zip"
if [[ $DO_ZIP -eq 1 ]]; then
  echo "==> Zipping xcframework -> $ZIP_PATH"
  rm -f "$ZIP_PATH"
  (cd src/out && zip -r -y "wg-go.xcframework.zip" "wg-go.xcframework" >/dev/null)
fi

# Optional checksum
if [[ $DO_CHECKSUM -eq 1 ]]; then
  command -v swift >/dev/null 2>&1 || { echo "swift not found; cannot compute checksum" >&2; exit 1; }
  echo "==> SwiftPM checksum"
  swift package compute-checksum "$ZIP_PATH"
  echo "-- Paste this into Package.swift 'checksum' when releasing."
fi

echo "✅ Done"