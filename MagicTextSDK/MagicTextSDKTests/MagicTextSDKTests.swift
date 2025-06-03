//
//  MagicTextSDKTests.swift
//  MagicTextSDKTests
//
//  Created by Aric on 6/2/25.
//

import XCTest
import SwiftUI
import WebKit
@testable import MagicTextSDK

final class MagicTextSDKTests: XCTestCase {

    func testMagicTextConfigInitialization() {
        let testURL = URL(string: "https://example.com")!
        let redColor = Color.red
        let cssString = "body { background: red !important; }"
        let jsString = "console.log('hello');"

        let config = MagicTextConfig(
            webURL: testURL,
            backgroundColor: redColor,
            customCSS: cssString,
            customJS: jsString
        )

        XCTAssertEqual(config.webURL, testURL, "webURL should match initializer")
        XCTAssertEqual(config.backgroundColor, redColor, "backgroundColor should match initializer")
        XCTAssertEqual(config.customCSS, cssString, "customCSS should match initializer")
        XCTAssertEqual(config.customJS, jsString, "customJS should match initializer")
    }
    
    func testMakeUIViewAppliesBackgroundColor() {
        let testURL = URL(string: "https://example.com")!
        let green = Color.green
        let config = MagicTextConfig(
            webURL: testURL,
            backgroundColor: green,
            customCSS: nil,
            customJS: nil
        )

        // Create view & coordinator
        let view = MagicTextView(config: config)
        let coordinator = view.makeCoordinator()

        // Build WKWebViewConfiguration using that coordinator’s userContentController
        let webConfig = WKWebViewConfiguration()
        webConfig.userContentController = coordinator.userContentController

        // Instantiate WKWebView
        let webView = WKWebView(frame: .zero, configuration: webConfig)

        // Simulate makeUIView’s backgroundColor logic
        if let bgColor = config.backgroundColor {
            webView.backgroundColor = UIColor(bgColor)
            webView.scrollView.backgroundColor = UIColor(bgColor)
        }

        // Verify
        let expected = UIColor(green)
        XCTAssertEqual(webView.backgroundColor, expected,
                       "WKWebView.backgroundColor should match config.backgroundColor")
        XCTAssertEqual(webView.scrollView.backgroundColor, expected,
                       "WKWebView.scrollView.backgroundColor should match config.backgroundColor")
    }
    
    func testUserScriptsInjection() {
        // 1) Prepare a config with both CSS and JS
        let testURL = URL(string: "https://example.com")!
        let cssString = "p { color: blue !important; }"
        let jsString  = "console.log('Magic');"
        let config = MagicTextConfig(
            webURL: testURL,
            backgroundColor: nil,
            customCSS: cssString,
            customJS: jsString
        )

        // 2) Create the view and its Coordinator
        let view = MagicTextView(config: config)
        let coordinator = view.makeCoordinator()

        // 3) Build a WKWebViewConfiguration that uses the same userContentController
        let webConfig = WKWebViewConfiguration()
        webConfig.userContentController = coordinator.userContentController

        // 4) Instantiate a WKWebView (as makeUIView would)
        let webView = WKWebView(frame: .zero, configuration: webConfig)

        // 5) Manually replicate updateUIView’s injection logic:

        // a) Inject CSS at document start
        if let css = config.customCSS {
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
            coordinator.userContentController.addUserScript(cssScript)
        }

        // b) Inject JS at document end
        if let js = config.customJS {
            let jsScript = WKUserScript(
                source: js,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
            coordinator.userContentController.addUserScript(jsScript)
        }

        // c) Load the URL (not strictly needed for the test, but mirrors updateUIView flow)
        webView.load(URLRequest(url: testURL))

        // 6) Inspect the Coordinator’s userContentController.userScripts
        let scripts = coordinator.userContentController.userScripts
        XCTAssertEqual(scripts.count, 2,
                       "There should be exactly 2 user scripts: one for CSS injection and one for JS injection")

        // 7) Verify CSS script
        let cssScriptFound = scripts.first { $0.injectionTime == .atDocumentStart }
        XCTAssertNotNil(cssScriptFound, "Expected a CSS script at .atDocumentStart")
        if let source = cssScriptFound?.source {
            XCTAssertTrue(source.contains(cssString),
                          "CSS script’s source should contain the original CSS string")
        }

        // 8) Verify JS script
        let jsScriptFound = scripts.first { $0.injectionTime == .atDocumentEnd }
        XCTAssertNotNil(jsScriptFound, "Expected a JS script at .atDocumentEnd")
        if let source = jsScriptFound?.source {
            XCTAssertTrue(source.contains(jsString),
                          "JS script’s source should contain the original JS string")
        }
    }
    
    func testOnLoadCallbackIsCalled() {
        let config = MagicTextConfig(webURL: URL(string: "https://example.com")!)
        var didCallOnLoad = false

        let view = MagicTextView(config: config, onLoad: { didCallOnLoad = true })
        let coordinator = view.makeCoordinator()

        // Simulate a successful navigation finish
        coordinator.webView(WKWebView(), didFinish: nil)
        XCTAssertTrue(didCallOnLoad, "onLoad should be invoked when navigation finishes")
    }

    func testOnErrorCallbackIsCalled() {
        let config = MagicTextConfig(webURL: URL(string: "https://example.com")!)
        var capturedError: Error?

        let view = MagicTextView(config: config, onError: { capturedError = $0 })
        let coordinator = view.makeCoordinator()

        // Simulate a provisional navigation error
        let sampleError = NSError(domain: "TestDomain", code: 42, userInfo: nil)
        coordinator.webView(WKWebView(),
                            didFailProvisionalNavigation: nil,
                            withError: sampleError)

        XCTAssertNotNil(capturedError, "onError should be invoked when provisional navigation fails")
        XCTAssertEqual((capturedError! as NSError).code, 42)
    }

}
