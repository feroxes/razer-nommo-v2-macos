// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "Nommo",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "nommo", targets: ["NommoCLI"])
    ],
    targets: [
        .target(
            name: "NommoKit",
            linkerSettings: [.linkedFramework("IOKit")]
        ),
        .executableTarget(name: "NommoCLI", dependencies: ["NommoKit"]),
        .executableTarget(name: "NommoControl", dependencies: ["NommoKit"]),
        .testTarget(name: "NommoKitTests", dependencies: ["NommoKit"])
    ]
)
