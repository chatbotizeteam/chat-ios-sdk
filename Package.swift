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
            url: "https://github.com/chatbotizeteam/chat-ios-sdk/releases/download/1.0.1/ZowieChat.xcframework.zip",
            checksum: "f006543ff769a7de832c0d678856ef2dae9061f743a761d17249e35fef6731c6"
        ),
    ]
)
