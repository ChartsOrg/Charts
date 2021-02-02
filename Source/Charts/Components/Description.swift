//
//  Description.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import CoreGraphics
import Foundation

#if canImport(UIKit)
    import UIKit
#endif

#if canImport(Cocoa)
    import Cocoa
#endif

open class Description: ComponentBase {
    override public init() {
        #if os(tvOS)
            // 23 is the smallest recommended font size on the TV
            font = .systemFont(ofSize: 23)
        #elseif os(OSX)
            font = .systemFont(ofSize: NSUIFont.systemFontSize)
        #else
            font = .systemFont(ofSize: 8.0)
        #endif

        super.init()
    }

    /// The text to be shown as the description.
    open var text: String?

    /// Custom position for the description text in pixels on the screen.
    open var position: CGPoint?

    /// The text alignment of the description text. Default RIGHT.
    open var textAlign = TextAlignment.right

    /// Font object used for drawing the description text.
    open var font: NSUIFont

    /// Text color used for drawing the description text
    open var textColor = NSUIColor.labelOrBlack
}
