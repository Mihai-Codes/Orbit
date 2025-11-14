// swift-tools-version:5.10
import PackageDescription
import Foundation
let package = Package(
    name: "MacPin",
    // Updated for WebKitForge modernization - targeting macOS 14 (Sonoma) for modern APIs
    // Using Swift 5.10 for stability - Swift 6.0 strict concurrency will be adopted in Phase 1.5
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "MacPin", type: .dynamic, targets: ["MacPin"]),
        .executable(name: "MacPin_static", targets: ["MacPin_static"]),
        .executable(name: "MacPin_stub", targets: ["MacPin_stub"]),
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
if let iosvar = ProcessInfo.processInfo.environment["MACPIN_IOS"], !iosvar.isEmpty {
    package.platforms = [.iOS(.v13)]
    package.products = [ .executable(name: "MacPin", targets: ["MacPin"]) ]
    package.targets.append(
        .executableTarget(
            name: "MacPin",
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
    package.targets.append(contentsOf: [
        .executableTarget(
            name: "iconify",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Tools/iconify"
        ),
        .target(name: "MacPin",
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
            name: "MacPin_static",
            dependencies: [
                .target(name: "MacPin")
            ]
        ),
        .executableTarget(
            name: "MacPin_stub",
            dependencies: [],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@loader_path:@loader_path/../Frameworks"])
            ]
        )
    ])
}
