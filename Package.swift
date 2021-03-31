// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RequestKits",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "RequestKits",
                 targets: ["RequestKits"]),
        .library(name: "RxRequestKits",
                 targets: ["RxRequestKits"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.0.0"))
    ],
    targets: [
        .target(
            name: "RequestKits",
            dependencies: ["Alamofire"]),
        .target(
            name: "RxRequestKits",
            dependencies: ["RxSwift", "RequestKits"])
    ],
    swiftLanguageVersions: [
        .v5
    ])
