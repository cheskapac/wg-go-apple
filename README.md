# WGKitGo

![iOS 15+](https://img.shields.io/badge/iOS-15+-green.svg)
![macOS 12+](https://img.shields.io/badge/macOS-12+-green.svg)
![tvOS 17+](https://img.shields.io/badge/tvOS-17+-green.svg)
![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

A Swift Package Manager compatible distribution of WireGuard's Go implementation for Apple platforms. This package provides pre-built XCFramework binaries of the WireGuard Go backend, enabling easy integration of WireGuard VPN functionality into iOS, macOS, and tvOS applications.

## Overview

WGKitGo is a Swift package that wraps the official WireGuard Go implementation in a convenient XCFramework format. It provides the core WireGuard protocol implementation written in Go, compiled as a C-compatible library that can be used from Swift applications on Apple platforms.

## Features

- ✅ **Multi-platform support**: iOS 15+, macOS 12+, tvOS 17+
- ✅ **Universal binaries**: Supports both Intel and Apple Silicon Macs
- ✅ **iOS device and simulator**: ARM64 and x86_64 architectures
- ✅ **Swift Package Manager**: Easy integration with SPM
- ✅ **Pre-built binaries**: No need to compile Go code during app builds
- ✅ **Official WireGuard**: Based on the official WireGuard Go implementation

## Installation

### Swift Package Manager

Add WGKitGo to your project using Swift Package Manager:

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the repository URL: `https://github.com/cheskapac/wg-go-apple`
3. Select the version you want to use
4. Add the package to your target

Alternatively, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/cheskapac/wg-go-apple", from: "0.0.20250903")
]
```

## Usage

Import the framework in your Swift code:

```swift
import WGKitGo
```

The package provides C-compatible functions for WireGuard operations:

- `wgTurnOn(_:_:)` - Initialize and start a WireGuard tunnel
- `wgTurnOff(_:)` - Stop and cleanup a WireGuard tunnel
- `wgSetConfig(_:_:)` - Configure tunnel settings
- `wgGetConfig(_:)` - Retrieve current tunnel configuration
- `wgBumpSockets(_:)` - Handle network changes and socket updates
- `wgSetLogger(_:_:)` - Set up logging callbacks
- `wgVersion()` - Get WireGuard version information

## Building from Source

If you need to build the XCFramework yourself:

### Prerequisites

- Xcode 14.0 or later
- Go 1.24.0 or later
- macOS development environment

### Build Process

1. Clone the repository:
```bash
git clone https://github.com/cheskapac/wg-go-apple.git
cd wg-go-apple
```

2. Build the XCFramework:
```bash
./generate.sh
```

3. Optional: Create a zip archive with checksum:
```bash
./generate.sh --zip --checksum
```

### Build Options

The `generate.sh` script supports several options:

- `--macos <version>` - Override macOS deployment target (default: 11.0)
- `--ios <version>` - Override iOS deployment target (default: 14.0)
- `--zip` - Create a zip archive of the XCFramework
- `--checksum` - Generate SwiftPM checksum for the zip file

Example:
```bash
./generate.sh --macos 12.0 --ios 15.0 --zip --checksum
```

## Project Structure

```
wg-go-apple/
├── src/                          # Source code and build system
│   ├── api-apple.go             # Go-to-C bridge implementation
│   ├── Makefile                 # Cross-platform build configuration
│   ├── go.mod                   # Go module dependencies
│   ├── wireguard.h              # C header definitions
│   └── out/                     # Build output directory
├── Package.swift                # Swift Package Manager manifest
├── generate.sh                  # Build script
├── .version                     # Current version
└── README.md                    # This file
```

## Architecture

The package consists of several key components:

1. **Go Implementation** (`api-apple.go`): The core WireGuard protocol implementation with C-compatible exports
2. **Build System** (`Makefile`): Cross-compilation setup for all Apple platforms
3. **XCFramework**: Universal binary package containing:
   - macOS (Intel + Apple Silicon)
   - iOS Device (ARM64)
   - iOS Simulator (Intel + Apple Silicon)

## Dependencies

- **WireGuard Go**: `golang.zx2c4.com/wireguard v0.0.0-20250521234502-f333402bd9cb`
- **Go System Calls**: `golang.org/x/sys v0.32.0`
- **Go Cryptography**: `golang.org/x/crypto v0.37.0`
- **Go Networking**: `golang.org/x/net v0.39.0`

## Version Information

Current version: `0.0.20250903`

The version follows the format `MAJOR.MINOR.YYYYMMDD` where the date represents the build date.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on all supported platforms
5. Submit a pull request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Related Projects

- [WireGuard](https://www.wireguard.com/) - Official WireGuard website
- [wireguard-go](https://git.zx2c4.com/wireguard-go/) - Official WireGuard Go implementation
- [wireguard-apple](https://github.com/WireGuard/wireguard-apple) - Official WireGuard iOS app

## Support

For issues related to this Swift package, please open an issue on GitHub.
For WireGuard protocol questions, refer to the [official WireGuard documentation](https://www.wireguard.com/).