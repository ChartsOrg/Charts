//
//  DataRenderer.swift
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

@objc(ChartDataRendererBase)
public protocol DataRenderer: Renderer
{
    @objc var animator: Animator? { get set }
    
//    @objc public init(animator: Animator?, viewPortHandler: ViewPortHandler)
//    {
//        super.init(viewPortHandler: viewPortHandler)
//
//        self.animator = animator
//    }

    func drawData(context: CGContext)
//    {
//        fatalError("drawData() cannot be called on DataRenderer")
//    }

    func drawValues(context: CGContext)
//    {
//        fatalError("drawValues() cannot be called on DataRenderer")
//    }

    func drawExtras(context: CGContext)
//    {
//        fatalError("drawExtras() cannot be called on DataRenderer")
//    }

    /// Draws all highlight indicators for the values that are currently highlighted.
    ///
    /// - parameter indices: the highlighted values
    func drawHighlighted(context: CGContext, indices: [Highlight])
//    {
//        fatalError("drawHighlighted() cannot be called on DataRenderer")
//    }

    /// An opportunity for initializing internal buffers used for rendering with a new size.
    /// Since this might do memory allocations, it should only be called if necessary.
    func initBuffers() //{ }
    
    func isDrawingValuesAllowed(dataProvider: ChartDataProvider?) -> Bool
//    {
//        guard let data = dataProvider?.data else { return false }
//        return data.entryCount < Int(CGFloat(dataProvider?.maxVisibleCount ?? 0) * viewPortHandler.scaleX)
//    }
}
