// swift-tools-version:5.10
import PackageDescription
import Foundation

let package = Package(
    name: "Orbit",
    // Orbit: AI-augmented browser workspace for macOS
    // Targeting macOS 14 (Sonoma) with Swift 5.10
    // Swift 6.0 strict concurrency will be adopted in Phase 1.5
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "Orbit", type: .dynamic, targets: ["Orbit"]),
        .executable(name: "Orbit_static", targets: ["Orbit_static"]),
        .executable(name: "Orbit_stub", targets: ["Orbit_stub"]),
        .executable(name: "iconify", targets: ["iconify"]),
    ],
    dependencies: [
        .package(path: "modules/Linenoise"),
        .package(path: "modules/UTIKit"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .systemLibrary(
            name: "WebKitPrivates",
            path: "modules/WebKitPrivates"
        ),
        .systemLibrary(
            name: "ViewPrivates",
            path: "modules/ViewPrivates"
        ),
        .systemLibrary(
            name: "UserNotificationPrivates",
            path: "modules/UserNotificationPrivates"
        ),
        .systemLibrary(
            name: "JavaScriptCorePrivates",
            path: "modules/JavaScriptCorePrivates"
        ),
    ]
)

if let iosvar = ProcessInfo.processInfo.environment["ORBIT_IOS"], !iosvar.isEmpty {
    // iOS build configuration
    package.platforms = [.iOS(.v13)]
    package.products = [ .executable(name: "Orbit", targets: ["Orbit"]) ]
    package.targets.append(
        .executableTarget(
            name: "Orbit",
            dependencies: [
                "WebKitPrivates",
                "JavaScriptCorePrivates",
                "ViewPrivates",
                "UserNotificationPrivates",
                "Linenoise",
                "UTIKit",
            ],
            path: "Sources/MacPinIOS"
        )
    )
} else {
    // macOS build configuration
    package.targets.append(contentsOf: [
        .executableTarget(
            name: "iconify",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Tools/iconify"
        ),
        .target(
            name: "Orbit",
            dependencies: [
                "WebKitPrivates",
                "JavaScriptCorePrivates",
                "ViewPrivates",
                "UserNotificationPrivates",
                "Linenoise",
                "UTIKit",
            ],
            path: "Sources/MacPinOSX"
        ),
        .executableTarget(
            name: "Orbit_static",
            dependencies: [
                .target(name: "Orbit")
            ],
            path: "Sources/MacPin_static"
        ),
        .executableTarget(
            name: "Orbit_stub",
            dependencies: [],
            path: "Sources/MacPin_stub",
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@loader_path:@loader_path/../Frameworks"])
            ]
        ),
        // Test target
        .testTarget(
            name: "OrbitTests",
            dependencies: [
                .target(name: "Orbit")
            ],
            path: "Tests/OrbitTests"
        ),
    ])
}
