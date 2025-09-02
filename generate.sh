#!/bin/bash

# Standalone (default targets & mins):
make -C src clean && make -C src build

# CI (custom targets & mins):
# make clean && make build MACOSX_DEPLOYMENT_TARGET="$1" IPHONEOS_DEPLOYMENT_TARGET="$2"

# Pin minimum OS versions
lipo -info out/macos/libwg-go.a
lipo -info out/ios-sim/libwg-go.a
file out/ios-device/libwg-go.a
ls -R out/wg-kit-go.xcframework
