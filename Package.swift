// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Chip8",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Chip8",
            targets: ["Chip8"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "Chip8GNU",
               publicHeadersPath: "include"),
        .target(name: "Chip8",
               dependencies: ["Chip8GNU"]),
        .testTarget(
            name: "Chip8Tests",
            dependencies: ["Chip8"]),
    ],
    cLanguageStandard: .gnu17
)
