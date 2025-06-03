//
//  MagicTextView.swift
//  MagicTextSDK
//
//  Created by Aric on 5/31/25.
//

import SwiftUI
import WebKit

public struct MagicTextView: UIViewRepresentable {
    public typealias UIViewType = WKWebView

    private let config: MagicTextConfig
    public var onLoad: (() -> Void)?
    public var onError: ((Error) -> Void)?

    public init(
        config: MagicTextConfig,
        onLoad: (() -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        self.config = config
        self.onLoad = onLoad
        self.onError = onError
    }

    public func makeUIView(context: Context) -> WKWebView {
        // 1) Create configuration and assign the coordinator’s userContentController
        let webConfig = WKWebViewConfiguration()
        webConfig.userContentController = context.coordinator.userContentController

        // 2) Instantiate WKWebView with that configuration
        let webView = WKWebView(frame: .zero, configuration: webConfig)

        // 3) Apply backgroundColor if provided
        if let bgColor = config.backgroundColor {
            webView.backgroundColor = UIColor(bgColor)
            webView.scrollView.backgroundColor = webView.backgroundColor
        }

        // 4) Set navigationDelegate to receive callbacks
        webView.navigationDelegate = context.coordinator
        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        // Ensure we only inject once
        guard !context.coordinator.didLoadOnce else { return }
        context.coordinator.didLoadOnce = true

        let userController = context.coordinator.userContentController

        // 1) Inject custom CSS at document start, if provided
        if let css = config.customCSS {
            // Escape backslashes, newlines, and quotes so the CSS can be embedded in JS
            let escapedCSS = css
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\"", with: "\\\"")

            // Build a JS snippet that creates a <style> tag containing the CSS
            let cssInjectionJS = """
            var style = document.createElement('style');
            style.innerText = \"\"\"
            \(escapedCSS)
            \"\"\";
            document.head.appendChild(style);
            """

            let cssScript = WKUserScript(
                source: cssInjectionJS,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true
            )
            userController.addUserScript(cssScript)
        }

        // 2) Inject custom JS at document end, if provided
        if let js = config.customJS {
            let jsScript = WKUserScript(
                source: js,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
            userController.addUserScript(jsScript)
        }

        // 3) Finally, load the web URL
        let request = URLRequest(url: config.webURL)
        webView.load(request)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public class Coordinator: NSObject, WKNavigationDelegate {
        let parent: MagicTextView
        let userContentController = WKUserContentController()
        var didLoadOnce = false

        init(parent: MagicTextView) {
            self.parent = parent
        }

        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.onLoad?()
        }

        public func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            parent.onError?(error)
        }

        public func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            parent.onError?(error)
        }
    }
}
