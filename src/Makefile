# SPDX-License-Identifier: MIT
#
# Copyright (C) 2018-2019 Jason A. Donenfeld <Jason@zx2c4.com>. All Rights Reserved.

# Use bash so [[ .. ]] works consistently.
SHELL := /bin/bash

# These are generally passed by Xcode; provide working defaults for standalone builds too.
PLATFORM_NAME ?= macosx
SDKROOT ?= $(shell xcrun --sdk $(PLATFORM_NAME) --show-sdk-path)
CONFIGURATION_BUILD_DIR ?= $(CURDIR)/out
CONFIGURATION_TEMP_DIR ?= $(CURDIR)/.tmp

# Deployment targets (override from env or Xcode as needed)
MACOSX_DEPLOYMENT_TARGET ?= 11.0
IPHONEOS_DEPLOYMENT_TARGET ?= 14.0

# Derive Catalyst flag if Xcode sets EFFECTIVE_PLATFORM_NAME (we don't package Catalyst by default).
IS_CATALYST ?= $(shell if [[ "$(EFFECTIVE_PLATFORM_NAME)" == *"maccatalyst"* ]]; then echo 1; fi)

export PATH := $(PATH):/usr/local/bin:/opt/homebrew/bin
export CC ?= clang
LIPO ?= lipo
XCBUILD ?= xcodebuild
DESTDIR ?= $(CONFIGURATION_BUILD_DIR)
BUILDDIR ?= $(CONFIGURATION_TEMP_DIR)/wireguard-go-bridge
INCLUDEDIR := $(BUILDDIR)/include

CFLAGS_PREFIX := -isysroot "$(SDKROOT)"

# GOOS mapping
GOOS_macosx := $(if $(IS_CATALYST),ios,darwin)
GOOS_iphoneos := ios
GOOS_iphonesimulator := ios

# Default per-platform target triples for a complete XCFramework.
MACOS_TARGETS ?= \
  arm64-apple-macosx$(MACOSX_DEPLOYMENT_TARGET) \
  x86_64-apple-macosx$(MACOSX_DEPLOYMENT_TARGET)

IOS_DEVICE_TARGETS ?= \
  arm64-apple-ios$(IPHONEOS_DEPLOYMENT_TARGET)

IOS_SIM_TARGETS ?= \
  arm64-apple-ios$(IPHONEOS_DEPLOYMENT_TARGET)-simulator \
  x86_64-apple-ios$(IPHONEOS_DEPLOYMENT_TARGET)-simulator

build: $(DESTDIR)/wg-kit-go.xcframework
version-header: $(DESTDIR)/wireguard-go-version.h

# --- Go toolchain staging (for applying your goruntime-* patches) ---
REAL_GOROOT := $(shell go env GOROOT 2>/dev/null)
export GOROOT := $(BUILDDIR)/goroot
$(GOROOT)/.prepared:
	[ -n "$(REAL_GOROOT)" ]
	mkdir -p "$(GOROOT)"
	rsync -a --delete --exclude=pkg/obj/go-build "$(REAL_GOROOT)/" "$(GOROOT)/"
	# Apply local runtime patches if present
	test -z "$$(ls -1 goruntime-*.diff 2>/dev/null)" || cat goruntime-*.diff | patch -p1 -f -N -r- -d "$(GOROOT)"
	mkdir -p "$(INCLUDEDIR)"
	touch "$@"

# --- Pattern: build a c-archive for a single target triple ---
# Produces: $(BUILDDIR)/libwg-kit-go-<triple>.a and header next to it; also sync a canonical header to $(INCLUDEDIR)/wg-kit-go.h
define libwg-kit-go-a
$(BUILDDIR)/libwg-kit-go-$(1).a: export CGO_ENABLED := 1
$(BUILDDIR)/libwg-kit-go-$(1).a: export CGO_CFLAGS := $(CFLAGS_PREFIX) -target $(1)
$(BUILDDIR)/libwg-kit-go-$(1).a: export CGO_LDFLAGS := $(CFLAGS_PREFIX) -target $(1)
$(BUILDDIR)/libwg-kit-go-$(1).a: export GOOS := $(if $(findstring macosx,$(1)),$(GOOS_macosx),$(GOOS_iphoneos))
$(BUILDDIR)/libwg-kit-go-$(1).a: export GOARCH := $(subst x86_64,amd64,$(word 1,$(subst -, ,$(1))))
$(BUILDDIR)/libwg-kit-go-$(1).a: $(GOROOT)/.prepared go.mod
	go build -ldflags=-w -trimpath -v -o "$(BUILDDIR)/libwg-kit-go-$(1).a" -buildmode c-archive
	# Keep the generated header; copy first one we see to canonical include path
	@if [ ! -f "$(INCLUDEDIR)/wg-kit-go.h" ]; then \
	  h="$$(dirname "$@")/$$(basename "$@" .a).h"; \
	  [ -f "$$h" ] && cp -f "$$h" "$(INCLUDEDIR)/wg-kit-go.h"; \
	fi
endef

# Emit rules for all required triples
$(foreach T,$(MACOS_TARGETS),$(eval $(call libwg-kit-go-a,$(T))))
$(foreach T,$(IOS_DEVICE_TARGETS),$(eval $(call libwg-kit-go-a,$(T))))
$(foreach T,$(IOS_SIM_TARGETS),$(eval $(call libwg-kit-go-a,$(T))))

# --- Per-platform lipos ---
$(DESTDIR)/macos/libwg-kit-go.a: $(foreach T,$(MACOS_TARGETS),$(BUILDDIR)/libwg-kit-go-$(T).a)
	@mkdir -p "$(dir $@)"
	$(LIPO) -create -output "$@" $^

$(DESTDIR)/ios-device/libwg-kit-go.a: $(foreach T,$(IOS_DEVICE_TARGETS),$(BUILDDIR)/libwg-kit-go-$(T).a)
	@mkdir -p "$(dir $@)"
	# Usually only one slice (arm64), but lipo keeps rule uniform
	$(LIPO) -create -output "$@" $^

$(DESTDIR)/ios-sim/libwg-kit-go.a: $(foreach T,$(IOS_SIM_TARGETS),$(BUILDDIR)/libwg-kit-go-$(T).a)
	@mkdir -p "$(dir $@)"
	$(LIPO) -create -output "$@" $^

# Optional: version header derived from go.mod
$(DESTDIR)/wireguard-go-version.h: go.mod $(GOROOT)/.prepared
	@mkdir -p "$(DESTDIR)"
	sed -E -n 's/.*golang\.zx2c4\.com\/wireguard +v[0-9.]+-[0-9]+-([0-9a-f]{8})[0-9a-f]{4}.*/#define WIREGUARD_GO_VERSION "\1"/p' "$<" > "$@"

# --- XCFramework packaging (final artifact) ---
$(DESTDIR)/wg-kit-go.xcframework: $(DESTDIR)/macos/libwg-kit-go.a $(DESTDIR)/ios-device/libwg-kit-go.a $(DESTDIR)/ios-sim/libwg-kit-go.a $(INCLUDEDIR)/wg-kit-go.h
	$(XCBUILD) -create-xcframework \
	  -library "$(DESTDIR)/macos/libwg-kit-go.a"      -headers "$(INCLUDEDIR)" \
	  -library "$(DESTDIR)/ios-device/libwg-kit-go.a" -headers "$(INCLUDEDIR)" \
	  -library "$(DESTDIR)/ios-sim/libwg-kit-go.a"    -headers "$(INCLUDEDIR)" \
	  -output "$@"

# Convenience aggregate (kept for compatibility with older callers)
fat-macos: $(DESTDIR)/macos/libwg-kit-go.a
fat-ios-sim: $(DESTDIR)/ios-sim/libwg-kit-go.a
fat-ios-device: $(DESTDIR)/ios-device/libwg-kit-go.a

clean:
	rm -rf "$(BUILDDIR)" \
	  "$(DESTDIR)/macos" "$(DESTDIR)/ios-sim" "$(DESTDIR)/ios-device" \
	  "$(DESTDIR)/wg-kit-go.xcframework" \
	  "$(DESTDIR)/wireguard-go-version.h"

install: build

.PHONY: clean build install version-header fat-macos fat-ios-sim fat-ios-device