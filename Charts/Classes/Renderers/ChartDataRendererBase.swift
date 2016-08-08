//
//  ChartDataRendererBase.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

public class ChartDataRendererBase: ChartRendererBase
{
    public var animator: ChartAnimator?
    
    public init(animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler?)
    {
        super.init(viewPortHandler: viewPortHandler)
        
        self.animator = animator
    }

    public func drawData(context context: CGContext)
    {
        fatalError("drawData() cannot be called on ChartDataRendererBase")
    }
    
    public func drawValues(context context: CGContext)
    {
        fatalError("drawValues() cannot be called on ChartDataRendererBase")
    }
    
    public func drawExtras(context context: CGContext)
    {
        fatalError("drawExtras() cannot be called on ChartDataRendererBase")
    }
    
    /// Draws all highlight indicators for the values that are currently highlighted.
    ///
    /// - parameter indices: the highlighted values
    public func drawHighlighted(context context: CGContext, indices: [Highlight])
    {
        fatalError("drawHighlighted() cannot be called on ChartDataRendererBase")
    }
    
    /// An opportunity for initializing internal buffers used for rendering with a new size.
    /// Since this might do memory allocations, it should only be called if necessary.
    public func initBuffers() { }
    
    public func isDrawingValuesAllowed(dataProvider dataProvider: ChartDataProvider?) -> Bool
    {
        guard let data = dataProvider?.data
            else { return false }
        
        return data.entryCount < Int(CGFloat(dataProvider?.maxVisibleCount ?? 0) * (viewPortHandler?.scaleX ?? 1.0))
    }
}