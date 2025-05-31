# MagicTextSDK (Minimal)

A bare-bones iOS 16+ SDK that wraps a `WKWebView` inside a SwiftUI view. It exposes only two public types—`MagicTextConfig` and `MagicTextView`—and two callbacks (`onLoad` and `onError`).

---

## Features

- **SwiftUI integration** via `UIViewRepresentable`
- **iOS 16.0+** only
- Two public types:
  - `MagicTextConfig` – holds the remote `URL` to load
  - `MagicTextView` – SwiftUI wrapper around `WKWebView`
- Two callbacks:
  - `onLoad: () → Void` – fired when the page finishes loading
  - `onError: (Error) → Void` – fired if loading fails

---

## Requirements

- **Xcode 14** (or later)
- **Swift 5.7** (or later)
- **iOS 16.0+** (both the SDK and any consuming app must target 16.0 or higher)

---

## Installation

The SDK is distributed as a prebuilt **XCFramework**.

### 1. Obtain `MagicTextSDK.xcframework`

- see “Building the XCFramework” below

### 2. Embed into Your App

1. **Open your iOS app project** in Xcode.
2. In Finder, locate `MagicTextSDK.xcframework`.
3. **Drag** the entire `MagicTextSDK.xcframework` folder into your Xcode project’s Project Navigator (for example, under a “Frameworks” or “Vendor” group).
   - In the “Add Files” dialog, check **Copy items if needed**.
   - Under **Add to targets**, make sure your app target is checked.
   - Click **Finish**.

4. **Embed & Link**
   - Select your **App target** (blue target icon) in Xcode.
   - Go to the **General** tab.
   - Scroll down to **Frameworks, Libraries, and Embedded Content**.
   - Ensure you see **MagicTextSDK.xcframework** listed, and set its **Embed** option to **Embed & Sign**.
     - If it’s not listed, click the “+” button, choose **Add Other… → Add Files…**, navigate to `MagicTextSDK.xcframework`, select it, and set **Embed & Sign**.

---

## Usage

Below is an example of how to use `MagicTextView` in a SwiftUI view. Replace the URL with whatever page or web-bundle you need.

```swift
import SwiftUI
import MagicTextSDK

struct ContentView: View {
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            Text("Magic 8-Ball Demo")
                .font(.largeTitle)
                .padding(.top, 40)
                .padding(.bottom, 10)

            MagicTextView(
                config: .init(
                    webURL: URL(string: "https://emej3lexpx.appflowapp.com/chat")!
                ),
                onLoad: {
                    // Called when the web page finishes loading
                    print("✅ Web content finished loading.")
                },
                onError: { error in
                    // Called if loading fails
                    errorMessage = error.localizedDescription
                    showError = true
                }
            )
            .edgesIgnoringSafeArea(.bottom)

            if showError {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}

@main
struct DemoAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### API Reference

#### `MagicTextConfig`

```swift
public struct MagicTextConfig {
    /// The remote URL to load in the WebView.
    public let webURL: URL

    public init(webURL: URL)
}
```

- **`webURL`**: URL of the HTML page or web bundle (e.g., your Magic 8-Ball endpoint).

#### `MagicTextView`

```swift
public struct MagicTextView: UIViewRepresentable {
    public typealias UIViewType = WKWebView

    public init(
        config: MagicTextConfig,
        onLoad: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    )

    public func makeUIView(context: Context) -> WKWebView
    public func updateUIView(_ webView: WKWebView, context: Context)
    public func makeCoordinator() -> Coordinator

    public class Coordinator: NSObject, WKNavigationDelegate {
        /// Fired when the page finishes loading.
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)

        /// Fired if navigation fails after it started.
        public func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        )

        /// Fired if navigation fails before it begins (bad URL, etc.).
        public func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        )
    }
}
```

- **`config`**: A `MagicTextConfig` instance containing the `webURL` to load.
- **`onLoad`**: Called when the page finishes loading successfully.
- **`onError`**: Called if loading or navigation fails, with an `Error` describing the problem.

---

## Building the XCFramework

To generate the `MagicTextSDK.xcframework` follow these steps:

1. **Clean Derived Data** (optional):
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/MagicTextSDK-*
   ```
2. **Archive for Device** (arm64):
   ```bash
   cd /path/to/MagicTextSDK
   xcodebuild archive      -scheme MagicTextSDK      -configuration Release      -destination "generic/platform=iOS"      -archivePath "./build/Device/MagicTextSDK.xcarchive"      SKIP_INSTALL=NO      BUILD_LIBRARY_FOR_DISTRIBUTION=YES
   ```
3. **Archive for Simulator** (x86_64 + arm64):
   ```bash
   xcodebuild archive      -scheme MagicTextSDK      -configuration Release      -destination "generic/platform=iOS Simulator"      -archivePath "./build/Simulator/MagicTextSDK.xcarchive"      SKIP_INSTALL=NO      BUILD_LIBRARY_FOR_DISTRIBUTION=YES
   ```
4. **Create the XCFramework**:
   ```bash
   xcodebuild -create-xcframework      -framework ./build/Device/MagicTextSDK.xcarchive/Products/Library/Frameworks/MagicTextSDK.framework      -framework ./build/Simulator/MagicTextSDK.xcarchive/Products/Library/Frameworks/MagicTextSDK.framework      -output ./build/MagicTextSDK.xcframework
   ```
5. You will now have `build/MagicTextSDK.xcframework` which you can embed in any iOS 16+ app.

---

## License

This project is licensed under the MIT License. See `LICENSE` for details.
