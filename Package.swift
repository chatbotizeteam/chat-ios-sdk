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
            url: "https://github.com/chatbotizeteam/chat-ios-sdk/releases/download/1.0.2/ZowieChat.xcframework.zip",
            checksum: "1feb13ebe1a88b1dd68b0a07836508e5a3a56c1788c33c74732c382776faea5e"
        ),
    ]
)
