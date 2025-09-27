// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ClaudeCodeSwiftStatusline",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "claude-code-statusline",
            targets: ["ClaudeCodeSwiftStatusline"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "ClaudeCodeSwiftStatusline",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ]
)