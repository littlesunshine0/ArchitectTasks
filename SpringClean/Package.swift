// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SpringClean",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "SpringClean", targets: ["SpringClean"])
    ],
    targets: [
        .executableTarget(
            name: "SpringClean",
            path: "Sources"
        )
    ]
)
