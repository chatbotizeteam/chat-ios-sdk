# Zowie Chat iOS SDK — moved

This SDK is now the **Zowie Conversation SDK for iOS**, developed in
[zowie-ai/conversation-sdk-ios](https://github.com/zowie-ai/conversation-sdk-ios).
This repository is archived and gets no further releases.

To switch, update your SPM dependency URL:

```swift
// before
.package(url: "https://github.com/chatbotizeteam/chat-ios-sdk", from: "1.0.2")

// after
.package(url: "https://github.com/zowie-ai/conversation-sdk-ios", from: "2.0.0")
```

and change imports from `ZowieChat` to `ZowieConversationSDK`. Component
names stay the same. See the new repository for the full documentation and
changelog.

Versions 1.x stay available from this repository, so existing builds
keep working. Their documentation is at
[tag 1.0.2](https://github.com/chatbotizeteam/chat-ios-sdk/blob/1.0.2/README.md).
