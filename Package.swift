// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MKDevice",
    platforms: [
      .macOS(.v12), .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MKDevice",
            targets: ["MKDevice"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
//         .package(url: "https://github.com/nzhddemian/MKDevice",   "0.0.2"..<"3.3.8" )
        .package(url: "https://github.com/nzhddemian/MKDevice", Version(0,0,2)..<Version(3,3,8))
    ],
    targets: [

        .binaryTarget(
            name: "MKDevice",
            path: "./Sources/MKDevice.xcframework")
    ]
)
//let package = Package(
//    name: “App”,
//    dependencies: [
//      .Package(url: “../Foo”, versions:
//               Version(0,1,0)..<Version(2,0,0)),
//      .Package(url: “../Foo”, majorVersion: 0),
//      .Package(url: “../Foo”, majorVersion: 0, minor: 1),
//      .Package(url: “../Foo”, Version(0, 1, 0)),
//      .Package(url: “../Foo”, “0.1.0”),
//    ]
//)
