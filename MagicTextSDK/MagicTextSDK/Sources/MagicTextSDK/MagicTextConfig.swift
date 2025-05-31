//
//  MagicTextConfig.swift
//  MagicTextSDK
//
//  Created by Aric on 5/31/25.
//

import Foundation
import SwiftUI

public struct MagicTextConfig {
    /// The URL to load in the WKWebView.
    public let webURL: URL

    /// Optional background color for the WKWebView’s container.
    public let backgroundColor: Color?

    /// Inject these CSS rules at document start (before the page’s own styles apply).
    public let customCSS: String?

    /// Inject this JavaScript at document end (after the DOM is fully loaded).
    public let customJS: String?

    public init(
        webURL: URL,
        backgroundColor: Color? = nil,
        customCSS: String? = nil,
        customJS: String? = nil
    ) {
        self.webURL = webURL
        self.backgroundColor = backgroundColor
        self.customCSS = customCSS
        self.customJS = customJS
    }
}
