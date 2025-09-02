#!/bin/bash

# Standalone (default targets & mins):
make -C src clean && make -C src build

# CI (custom targets & mins):
# make clean && make build MACOSX_DEPLOYMENT_TARGET="$1" IPHONEOS_DEPLOYMENT_TARGET="$2"

# Pin minimum OS versions
lipo -info src/out/macos/libwg-kit-go.a
lipo -info src/out/ios-sim/libwg-kit-go.a
file src/out/ios-device/libwg-kit-go.a
ls -R src/out/wg-kit-go.xcframework