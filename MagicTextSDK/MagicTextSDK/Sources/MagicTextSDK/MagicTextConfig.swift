//
//  MagicTextConfig.swift
//  MagicTextSDK
//
//  Created by Aric on 5/31/25.
//

import Foundation
import SwiftUI

/// A minimal configuration for the MagicText SDK.
public struct MagicTextConfig {
    /// The URL to load in the WKWebView.
    public let webURL: URL

    public init(webURL: URL) {
        self.webURL = webURL
    }
}
