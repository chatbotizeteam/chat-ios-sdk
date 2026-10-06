# Zowie Chat iOS SDK

Zowie chat as an iOS component. Add `ZowieChatView` to your SwiftUI app — or
`ZowieChatViewController` to a UIKit app — give it your `baseUrl` and
`instanceId`, and it renders the full Zowie chat experience with configuration
fetching and Keychain session persistence built in.

## Requirements

- **iOS 15+**
- **Xcode 16+**
- **Swift 5.9+**
- Zero external dependencies.

### Info.plist

| Key                            | Required when                                                                                                                          |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| `NSMicrophoneUsageDescription` | Voice conversation mode is enabled. Without it iOS terminates the app when the chat asks for the microphone.                           |
| `NSCameraUsageDescription`     | File attachments are enabled for your chat instance. Without it iOS terminates the app when the user takes a photo or video to attach. |

## Installation

The SDK is distributed as a **Swift Package**. In Xcode:

```
File → Add Package Dependencies… → https://github.com/chatbotizeteam/chat-ios-sdk
```

Or reference it in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/chatbotizeteam/chat-ios-sdk", from: "1.0.0"),
]
```

Then add `ZowieChat` to your target's dependencies.

## Quick start

### SwiftUI

```swift
import ZowieChat

struct ChatScreen: View {
    var body: some View {
        ZowieChatView(
            config: ZowieChatConfig(
                baseUrl: "https://<slug>.chat.getzowie.com",
                instanceId: "<your-instance-id>"
            )
        )
    }
}
```

### UIKit

```swift
import ZowieChat

let config = ZowieChatConfig(
    baseUrl: "https://<slug>.chat.getzowie.com",
    instanceId: "<your-instance-id>"
)
let chatVC = ZowieChatViewController(config: config)
chatVC.eventHandler = self
navigationController?.pushViewController(chatVC, animated: true)
```

## Configuration

`ZowieChatConfig` is a struct with named parameters. Only `baseUrl` and
`instanceId` are required — everything else has a sensible default. The config is
read once, when the chat is created; changing it afterwards has no effect on a
chat that is already open.

```swift
let config = ZowieChatConfig(
    baseUrl: "https://<slug>.chat.getzowie.com",
    instanceId: "<your-instance-id>",
    title: "Support",
    primaryColor: "#2563EB",
    metadata: Metadata(
        firstName: "Ada",
        email: "ada@example.com",
        locale: "en-US"
    )
)
```

### Required

| Field        | Type     | Description                                                                    |
| ------------ | -------- | ------------------------------------------------------------------------------ |
| `baseUrl`    | `String` | Base origin of your Zowie deployment, e.g. `https://<slug>.chat.getzowie.com`. |
| `instanceId` | `String` | Zowie chat instance ID.                                                        |

### Session and behaviour

| Field                     | Type               | Default       | Description                                                       |
| ------------------------- | ------------------ | ------------- | ----------------------------------------------------------------- |
| `metadata`                | `Metadata?`        | `nil`         | User attributes. `metadata.locale` also selects the bot's region. |
| `externalAccessToken`     | `String?`          | `nil`         | JWT for authenticated sessions; anonymous when omitted.           |
| `context`                 | `String?`          | `nil`         | Custom context string passed to the bot.                          |
| `resetSession`            | `Bool`             | `false`       | Clear any persisted session on init.                              |
| `initialConversationMode` | `ConversationMode` | `.text`       | Mode the chat opens in (`.text` or `.voice`).                     |
| `versionType`             | `VersionType`      | `.production` | Bot version to run: `.production` or `.staging`.                  |
| `referral`                | `String`           | `"start"`     | Referral used for auto-start.                                     |
| `initialUserMessage`      | `String?`          | `nil`         | Initial user message sent with auto-start.                        |

### Branding

Values set here override the ones configured in the Zowie panel.

| Field                        | Type         | Description                                       |
| ---------------------------- | ------------ | ------------------------------------------------- |
| `title`                      | `String?`    | Header title.                                     |
| `primaryColor`               | `String?`    | Primary color, applied to both light and dark.    |
| `fontColor`                  | `FontColor?` | `.white` or `.black`, applied to both themes.     |
| `userMessageBackgroundColor` | `String?`    | User message bubble background color.             |
| `userMessageFontColor`       | `FontColor?` | User message bubble text color.                   |
| `logoUrl`                    | `String?`    | Logo shown in the chat header.                    |
| `theme`                      | `ThemeMode?` | `.system`, `.light` or `.dark`.                   |
| `headerVisible`              | `Bool`       | Whether to show the chat header. Default `false`. |
| `voiceExperienceEnabled`     | `Bool?`      | Enable voice conversation mode.                   |
| `voiceBlobColor`             | `String?`    | Color of the voice visualization.                 |

## Events

Both views expose the same three hooks -- events, link handling and download
handling -- in the shape that fits each framework.

**SwiftUI takes closures**, because a `View` is a struct and cannot be a delegate:

```swift
ZowieChatView(
    config: config,
    onEvent: { event in
        if case .chatStarted(let conversationId) = event {
            print(conversationId)
        }
    },
    onLinkPress: { url in openInAppBrowser(url); return true },
    onDownload: { download in storeEncrypted(download); return true }
)
```

**UIKit takes delegates**, set as weak properties after init:

```swift
let chatVC = ZowieChatViewController(config: config)
chatVC.eventHandler = self
chatVC.linkHandler = self
chatVC.downloadHandler = self

extension MyViewController: ZowieEventHandler {
    func onEvent(event: ZowieChatEvent) { ... }
}
```

All three properties are `weak`, so a view controller can safely be its own
handler. They can be set or changed at any point; the SDK reads them when the
event fires.

| Event             | Payload                                 | Fires when...                                                                                                                                                                                                |
| ----------------- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `loaded`          | --                                      | The chat finished loading.                                                                                                                                                                                   |
| `chatStarted`     | `conversationId: String`                | A conversation started.                                                                                                                                                                                      |
| `chatEnded`       | --                                      | The conversation ended.                                                                                                                                                                                      |
| `messageSent`     | `message: String`                       | The user sent a message.                                                                                                                                                                                     |
| `messageReceived` | `payload: String` (raw JSON)            | A message was received.                                                                                                                                                                                      |
| `sessionExpired`  | --                                      | The session expired.                                                                                                                                                                                         |
| `unreadMessages`  | `count: Int`                            | The unread message count changed.                                                                                                                                                                            |
| `minimized`       | --                                      | The user tapped the minimize control.                                                                                                                                                                        |
| `configError`     | `error: Error`                          | The chat failed to load or configure itself. Fires both when the remote configuration fetch fails (the chat still opens with the default appearance) and when the chat itself never opens (network failure). |
| `genericEvent`    | `name: String`, `params: [String: Any]` | A backend event fired (Decision Engine).                                                                                                                                                                     |
| `commandDropped`  | `command: String`                       | A command was sent before the chat was ready and was dropped.                                                                                                                                                |

## Link handling

Open links yourself with `onLinkPress` in SwiftUI, or a `ZowieLinkHandler` in
UIKit:

```swift
ZowieChatView(
    config: config,
    onLinkPress: { url in
        guard url.hasPrefix("http") else { return false }
        openInAppBrowser(url)
        return true
    }
)

// UIKit
chatVC.linkHandler = self

extension MyViewController: ZowieLinkHandler {
    func onLinkPress(url: String) -> Bool { ... }
}
```

Return `true` when your app opened the link, `false` to let the SDK open it with
`UIApplication.shared.open`. **Returning `true` without doing anything silently
drops the link.**

Links pointing at the configured `baseUrl` stay inside the chat and never reach
the handler. Everything else does, including `mailto:` and `tel:` -- guard on the
scheme if your handler can only open web pages.

## Download handling

Transcripts and attachments the user downloads are, by default, presented via
`UIActivityViewController` (the system share sheet). For URL-based downloads the
SDK opens the URL with `UIApplication.shared.open`.

To take over, use `onDownload` in SwiftUI or a `ZowieDownloadHandler` in UIKit:

```swift
ZowieChatView(
    config: config,
    onDownload: { download in
        storeEncrypted(download)
        return true
    }
)

// UIKit
chatVC.downloadHandler = self

extension MyViewController: ZowieDownloadHandler {
    func onDownload(download: ChatDownload) -> Bool { ... }
}
```

Return `true` when you handled the download, `false` to let the SDK present it.
To observe downloads without changing what happens to them, do your work and
return `false`.

## AI session notice handling

Pass an `onAiSessionNoticeMorePress` closure (SwiftUI) or set a
`ZowieAiSessionNoticeMorePressHandler` (UIKit) to take over the "more" link in
the AI Session Notice:

```swift
// SwiftUI
ZowieChatView(
    config: config,
    onAiSessionNoticeMorePress: { header, message in
        showCustomDialog(header: header, message: message)
    }
)

// UIKit
chatVC.aiSessionNoticeMorePressHandler = self

extension MyViewController: ZowieAiSessionNoticeMorePressHandler {
    func onAiSessionNoticeMorePress(header: String, message: String) {
        showCustomDialog(header: header, message: message)
    }
}
```

Without a handler the SDK opens its own modal with the full notice content. When a
handler is set the modal is not shown — the host app takes over. The `message`
parameter may contain markdown.

The SDK checks for the handler once, when the chat starts. In UIKit, set
`aiSessionNoticeMorePressHandler` before the view controller is presented and keep
the handler alive. A handler set later is ignored and the SDK modal is shown.

## Types

### `Metadata`

User attributes. All fields are optional.

| Field         | Type                | Description                                          |
| ------------- | ------------------- | ---------------------------------------------------- |
| `firstName`   | `String?`           | User's first name.                                   |
| `lastName`    | `String?`           | User's last name.                                    |
| `name`        | `String?`           | Name, sent next to `firstName` and `lastName`.       |
| `email`       | `String?`           | User's email address.                                |
| `phoneNumber` | `String?`           | User's phone number.                                 |
| `locale`      | `String?`           | Locale, e.g. `en-US`. Also selects the bot's region. |
| `timezone`    | `String?`           | IANA timezone, e.g. `Europe/Warsaw`.                 |
| `extraParams` | `[String: String]?` | Arbitrary custom attributes.                         |

### `ThemeMode`

Controls the chat's color theme.

| Value     | Description                                       |
| --------- | ------------------------------------------------- |
| `.system` | Follow the device's light/dark setting (default). |
| `.light`  | Force light theme.                                |
| `.dark`   | Force dark theme.                                 |

### `ConversationMode`

The mode a conversation opens in.

| Value    | Description                                    |
| -------- | ---------------------------------------------- |
| `.text`  | The conversation opens with a text input.      |
| `.voice` | The conversation opens with the voice feature. |

### `VersionType`

Whether the chat runs against the production or staging bot.

| Value         | Description                             |
| ------------- | --------------------------------------- |
| `.production` | The published bot (default).            |
| `.staging`    | The current staging version of the bot. |

### `FontColor`

The color of the text in the chat. Without an override the chat uses black text
in the light theme and white text in the dark theme. A value set on
`ZowieChatConfig` replaces both.

| Value    | Description                |
| -------- | -------------------------- |
| `.white` | The chat draws white text. |
| `.black` | The chat draws black text. |

### `ChatDownload`

Passed to the download hook. Exactly one of `base64` or `url` is set.

| Field      | Type      | Description                                                    |
| ---------- | --------- | -------------------------------------------------------------- |
| `filename` | `String`  | Suggested file name.                                           |
| `mimeType` | `String?` | MIME type, when known.                                         |
| `base64`   | `String?` | Base64 contents, for client-generated files (e.g. transcript). |
| `url`      | `String?` | Direct download URL.                                           |

## Controlling the chat

Drive the chat from your own UI with a chat command object. The SDK creates it --
there is no public initializer -- and hands it to you in the shape each framework
expects.

**SwiftUI** declares it with the `@ZowieCommands` property wrapper and passes it
to the view:

```swift
struct ChatScreen: View {
    @ZowieCommands private var chat

    var body: some View {
        VStack {
            Button("Say hello") { chat.sendMessage("Hello") }
            ZowieChatView(config: config, commands: chat)
        }
    }
}
```

**UIKit** reads it off the view controller:

```swift
let chatVC = ZowieChatViewController(config: config)
chatVC.commands.sendMessage("Hello")
```

Both are `ZowieChatCommands`. The SDK creates the object, so there is no
initializer to call. One object belongs to one chat: two chats on screen at once
need two `@ZowieCommands` declarations. Calls made before the chat is ready are
dropped, and reported through `commandDropped`.

`ZowieChatCommands` is `@MainActor`, so call it on the main thread. SwiftUI views
and UIKit view controllers already run there. From other code, mark the caller
`@MainActor`, or call it with `await` from async code, e.g.
`await chat.sendMessage("Hello")`. The object is `Sendable`, so it can be passed
between tasks.

| Method                | Description                                                        |
| --------------------- | ------------------------------------------------------------------ |
| `sendMessage`         | Send a message as the user.                                        |
| `sendReferral`        | Send a referral / campaign ID to the conversation.                 |
| `updateMetadata`      | Update the user attributes.                                        |
| `setVisible`          | Set whether the chat is visible.                                   |
| `showCsat`            | Show the CSAT survey. Pass `onCompleted` to be called when done.   |
| `startChat`           | Start a new conversation when none is active (no-op otherwise).    |
| `endChat`             | Clear the stored session and current conversation (use on logout). |
| `registerPushToken`   | Register a device push token for push notifications.               |
| `deregisterPushToken` | Deregister the current device token; stops push notifications.     |
| `conversationId`      | The active conversation's ID, or `nil` when none is open.          |

## Logging

The SDK's logs are **off** by default. Nothing reaches the console, and nothing
reaches the unified log on the device, until the host app turns them on:

```swift
@main
struct MyApp: App {
    init() {
        ZowieChatLogging.isEnabled = true
    }
    ...
}
```

Set the flag before you show the chat. Turn the logs on while you integrate the
SDK, and leave them off in a release build.

While the flag is `false` the SDK writes to `OSLog.disabled`, which drops the
message before it builds the text. A disabled log leaves nothing for `log show`
or Console to find.

### Categories

The SDK writes to the `ai.zowie.chat` subsystem, under three categories. In Xcode
or Console, filter on `subsystem:ai.zowie.chat` for everything, or on a single
`category:` for one area.

| Category   | Covers                                                           |
| ---------- | ---------------------------------------------------------------- |
| `Chat`     | Chat setup, remote config, messaging, and the events it reports. |
| `Session`  | The session in the Keychain.                                     |
| `Download` | The files the chat sends to the host app.                        |

Every message starts with a `[Zowie]` prefix, so the source stays visible in a
raw `log show` dump and in any tool that hides the metadata columns.

The SDK is quiet on purpose, but it reports enough that you can watch a chat come
up without wiring a single handler. At the default level it writes failures plus
five lines: the chat is loading, the chat loaded, and a conversation that started,
ended, or expired. A chat that stops halfway shows you where.

The rest -- the remote config, the session it resumed, the messages it did not
recognise -- sits at the `debug` level, which the system hides unless you ask:

```bash
xcrun simctl spawn booted log stream \
  --predicate 'subsystem == "ai.zowie.chat"' --level debug
```

### Privacy

Identifiers, status codes, counts, and error descriptions are public, because they
say nothing about the person using the chat. Everything else stays redacted, so a
device log never carries message text, metadata, or a download file name.

## Session persistence

Sessions are stored in the iOS Keychain with service name
`ai.zowie.session.<instanceId>` and `kSecAttrAccessibleAfterFirstUnlock`
protection. This means sessions survive app restarts and device reboots (after
the first unlock).

Call `ZowieCommands.clearAnonymousSession(instanceId:)` to clear a stored
session without opening the chat (e.g. on user logout). It is static because it
touches the Keychain, not a running conversation.

## Push notifications

The SDK can register a device push token with the Zowie backend so the user
receives push notifications for new messages.

Zowie sends push notifications on iOS through Firebase Cloud Messaging only. The
host app must integrate Firebase Messaging and pass the FCM registration token,
not the APNs `deviceToken` from `AppDelegate`.

```swift
Messaging.messaging().token { token, _ in
    if let token {
        chat.registerPushToken(token)
    }
}
```

Call `deregisterPushToken()` when push notifications should stop for this device
(e.g. on user logout).

```swift
chat.deregisterPushToken()
```

If the token value changes, call `registerPushToken` again with the new token.

**Behaviour notes:**

- If the chat session is not yet authenticated, `registerPushToken` queues the
  token and flushes it automatically when authentication completes.
- The token is automatically cleared when the chat ends or the session expires.
- The host app is responsible for the Firebase and APNs setup. The SDK only
  handles token registration with the Zowie backend.

## License

MIT
