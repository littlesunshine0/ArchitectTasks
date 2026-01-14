// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SpringClean",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "SpringClean", targets: ["SpringClean"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "509.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "SpringClean",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ],
            path: "Sources"
        )
    ]
)
