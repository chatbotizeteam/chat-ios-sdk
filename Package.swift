// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ZowieChat",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "ZowieChat", targets: ["ZowieChat"]),
    ],
    targets: [
        .binaryTarget(
            name: "ZowieChat",
            url: "https://github.com/chatbotizeteam/chat-ios-sdk/releases/download/1.0.0/ZowieChat.xcframework.zip",
            checksum: "528b19555eb6a4f142eca225472479d010d86380931cb8fe365bf88ca7694f78"
        ),
    ]
)
