// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ArchitectTasks",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ArchitectTasks",
            targets: ["ArchitectTasks"]
        )
    ],
    dependencies: [
        // Add dependencies here
    ],
    targets: [
        .target(
            name: "ArchitectTasks",
            dependencies: []
        ),
        .testTarget(
            name: "ArchitectTasksTests",
            dependencies: ["ArchitectTasks"]
        )
    ]
)
