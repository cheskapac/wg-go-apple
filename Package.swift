// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let filename = "wg-kit-go.xcframework.zip"
let version = "0.0.20250901"
let checksum = "820a01401e11807a748dd26b0cd48caf9503fbba4339baa25ebf76fced5ac7cf"

let package = Package(
    name: "wg-kit-go",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "wg-kit-go",
            targets: ["wg-kit-go-binary"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "wg-kit-go-binary",
            url: "https://github.com/cheskapac/wg-kit-go-binary/releases/download/\(version)/\(filename)",
            checksum: checksum
        )

//        // local development
//        .binaryTarget(
//            name: "wg-kit-go-binary",
//            path: "build/wg-kit-go.xcframework.zip"
//        )
    ]
)