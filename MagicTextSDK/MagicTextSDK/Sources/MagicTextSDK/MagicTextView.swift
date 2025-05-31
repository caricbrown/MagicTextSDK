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
        // Create a configuration with our userContentController
        let webConfig = WKWebViewConfiguration()
        webConfig.userContentController = context.coordinator.userContentController

        let webView = WKWebView(frame: .zero, configuration: webConfig)

        // Apply backgroundColor if provided:
        if let bgColor = config.backgroundColor {
            webView.backgroundColor = UIColor(bgColor)
            webView.scrollView.backgroundColor = UIColor(bgColor)
        }

        webView.navigationDelegate = context.coordinator
        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        // Only run injection + load once:
        guard !context.coordinator.didLoadOnce else { return }
        context.coordinator.didLoadOnce = true

        let userController = context.coordinator.userContentController

        // 1) Inject custom CSS at document start
        if let css = config.customCSS {
            // Escape backslashes/newlines/quotes in CSS so it can live inside a JS string literal
            let escapedCSS = css
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\"", with: "\\\"")

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

        // 2) Inject custom JS at document end
        if let js = config.customJS {
            let jsScript = WKUserScript(
                source: js,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )

            userController.addUserScript(jsScript)
        }

        // 3) Load the page
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
