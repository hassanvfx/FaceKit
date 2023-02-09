// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FaceKit",
    products: [
        .library(
            name: "FaceKit",
            targets: ["FaceKit"]
        ),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FaceKitObjC",
            dependencies: ["ncnn", "opencv2", "openmp"],
            path: "Sources/FaceKit/ObjC",
            resources: [
                .process("Sources/FaceKit/ObjC/assets"),
                .process("Sources/FaceKit/MLModels/prnet.mlmodelc"),
            ]
        ),
        .target(
            name: "FaceKit",
            dependencies: ["FaceKitObjC"],
            path: "Sources/FaceKit/Swift"
        ),

        .binaryTarget(
            name: "opencv2",
            path: "Sources/FaceKit/Frameworks/opencv2.xcframework"
        ),
        .binaryTarget(
            name: "ncnn",
            path: "Sources/FaceKit/Frameworks/ncnn.xcframework"
        ),
        .binaryTarget(
            name: "openmp",
            path: "Sources/FaceKit/Frameworks/openmp.xcframework"
        ),
        .testTarget(
            name: "FaceKitTests",
            dependencies: ["FaceKit"]
        ),
    ],
    cxxLanguageStandard: CXXLanguageStandard(rawValue: "c++11")
)
