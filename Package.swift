// swift-tools-version:5.9

import PackageDescription

// Google's prebuilt TensorFlow Lite 2.17.0 and MediaPipe Tasks Vision 0.10.14 iOS binaries for SPM, as
// shipped by their CocoaPods (TensorFlowLiteC, MediaPipeTasksCommon, MediaPipeTasksVision); binaries are
// byte-identical, only re-zipped because SPM cannot download the pods' .tar.gz archives.
//
// MediaPipe's graph registrations live in a static library that must be force-loaded. SPM does not allow
// linker flags in remote packages, so consumers of MediaPipeTasksVision add:
//   OTHER_LDFLAGS = $(inherited) -ObjC -force_load "$(BUILT_PRODUCTS_DIR)/libMediaPipeTasksGraph.a"
let release = "https://github.com/thanhtv-ios/everfit-ml-spm/releases/download/1.0.1"

let package = Package(
    name: "everfit-ml-spm",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "TensorFlowLite", targets: ["TensorFlowLite"]),
        .library(name: "MediaPipeTasksVision", targets: ["MediaPipeTasksVisionLinkage"]),
    ],
    targets: [
        // TensorFlowLiteSwift 2.17.0 sources, unchanged.
        .target(
            name: "TensorFlowLite",
            dependencies: ["TensorFlowLiteC"],
            resources: [.copy("PrivacyInfo.xcprivacy")],
            linkerSettings: [.linkedLibrary("c++")]
        ),
        .binaryTarget(
            name: "TensorFlowLiteC",
            url: "\(release)/TensorFlowLiteC.xcframework.zip",
            checksum: "6137ed092dae2e5ed9c5eef8dbe3f428cdea462be582f2b0f3184d6e03b2cd19"
        ),
        // Carries MediaPipe's system-library requirements (binary targets cannot declare them).
        .target(
            name: "MediaPipeTasksVisionLinkage",
            dependencies: ["MediaPipeTasksVision", "MediaPipeTasksCommon", "MediaPipeTasksGraph"],
            linkerSettings: [
                .linkedLibrary("c++"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("Accelerate"),
                .linkedFramework("AssetsLibrary"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CoreImage"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("QuartzCore"),
            ]
        ),
        .binaryTarget(
            name: "MediaPipeTasksVision",
            url: "\(release)/MediaPipeTasksVision.xcframework.zip",
            checksum: "483a77e881d5c5fb50406f9557dc1b75b08cb0b5ca6ed7901f71d4ebe8c05520"
        ),
        .binaryTarget(
            name: "MediaPipeTasksCommon",
            url: "\(release)/MediaPipeTasksCommon.xcframework.zip",
            checksum: "c780b71b00907b6e0c59d7b7b1ee6302b388c47db5a65f7c60ce2d5afb35f51d"
        ),
        // libMediaPipeTasksCommon_{device,simulator}_graph.a, bytes unchanged, renamed to one library name.
        .binaryTarget(
            name: "MediaPipeTasksGraph",
            url: "\(release)/MediaPipeTasksGraph.xcframework.zip",
            checksum: "f3a151e452ad633fe9bf7004c126d13cb284de6d6349b57672b12feefd894aea"
        ),
    ]
)
