//
//  Renderer.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

//@objc(ChartRenderer)
//public protocol IRenderer {
//    /// the component that handles the drawing area of the chart and it's offsets
//    @objc var viewPortHandler: ViewPortHandler { get }
//
//    @objc init(viewPortHandler: ViewPortHandler)
//}

@objc(ChartRenderer)
public protocol Renderer: class {
    /// the component that handles the drawing area of the chart and it's offsets
    @objc var viewPortHandler: ViewPortHandler { get }
}
