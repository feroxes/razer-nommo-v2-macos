// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "Nommo",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "nommo", targets: ["NommoCLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.10.1")
    ],
    targets: [
        .target(
            name: "NommoKit",
            linkerSettings: [.linkedFramework("IOKit")]
        ),
        .executableTarget(name: "NommoCLI", dependencies: ["NommoKit"]),
        .executableTarget(
            name: "NommoControl",
            dependencies: ["NommoKit", .product(name: "Sparkle", package: "Sparkle")],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@executable_path/../Frameworks"])
            ]
        ),
        .testTarget(name: "NommoKitTests", dependencies: ["NommoKit"])
    ]
)
