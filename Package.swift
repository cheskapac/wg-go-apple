// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let filename = "wg-go.xcframework.zip"
let version = "0.0.20250902"
let checksum = "42200fdc5750687331f1c9a0b831e9eac90c885e6b2ebda7ff0b88d939f63656"

let package = Package(
    name: "wg-go-apple",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "wg-go-apple",
            targets: ["wg-go"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "wg-go",
            url: "https://github.com/cheskapac/wg-go-apple/releases/download/\(version)/\(filename)",
            checksum: checksum
        )

//        // local development
//        .binaryTarget(
//            name: "wg-go",
//            path: "build/wg-go.xcframework.zip"
//        )
    ]
)