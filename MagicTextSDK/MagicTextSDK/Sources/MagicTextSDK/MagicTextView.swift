//
//  MagicTextView.swift
//  MagicTextSDK
//
//  Created by Aric on 5/31/25.
//

import Foundation
import SwiftUI
import WebKit

/// A bare-bones SwiftUI view that wraps WKWebView and loads a single URL.
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
        let webConfig = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfig)
        webView.navigationDelegate = context.coordinator
        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {
        // Only load once:
        guard !context.coordinator.didLoadOnce else { return }
        context.coordinator.didLoadOnce = true

        let request = URLRequest(url: config.webURL)
        webView.load(request)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public class Coordinator: NSObject, WKNavigationDelegate {
        private let parent: MagicTextView
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
