// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let filename = "wg-go.xcframework.zip"
let version = "0.0.20250903"
let checksum = "2a050c73213f3849659a80fcd10ddd121011cbb3a17d1b53bbee3d288a772d50"

let package = Package(
    name: "WGKitGo",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "WGKitGo",
            targets: ["WGKitGo"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "WGKitGo",
            url: "https://github.com/cheskapac/wg-go-apple/releases/download/\(version)/\(filename)",
            checksum: checksum
        )
/*
        // local development
       .binaryTarget(
           name: "WGKitGo",
           path: "src/out/wg-go.xcframework"
       )
*/
    ]
)