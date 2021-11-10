// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "spm_mirror",
    products: [
//        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "spm_mirror",
            targets: ["spm_mirror"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(name: "spm_mirror", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            "SwiftShell",
        ]),
        .testTarget(
            name: "spm_mirrorTests",
            dependencies: ["spm_mirror"]),
    ]
)
