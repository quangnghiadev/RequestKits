// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RequestKits",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "RequestKits",
                 targets: ["RequestKits"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.1.0")),
        .package(url: "https://github.com/quangnghiadev/AsyncOperation.git", .branch("main"))
    ],
    targets: [
        .target(
            name: "RequestKits",
            dependencies: ["RxSwift", "Alamofire", "AsyncOperation"])
    ],
    swiftLanguageVersions: [
        .v5
    ])
