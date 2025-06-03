//
//  MagicTextConfig.swift
//  MagicTextSDK
//
//  Created by Aric on 5/31/25.
//

import Foundation
import SwiftUI

/// A minimal configuration for the MagicText SDK
public struct MagicTextConfig {
    public let webURL: URL
    public let backgroundColor: Color?
    public let customCSS: String?
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
