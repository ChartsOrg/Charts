//
//  LineRadarChartRenderer.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 27/01/2016.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics


public class LineRadarChartRenderer: LineScatterCandleRadarChartRenderer
{
    public override init(animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
    }
    
    /// Draws the provided path in filled mode with the provided drawable.
    public func drawFilledPath(context context: CGContext, path: CGPath, fill: ChartFill, fillAlpha: CGFloat)
    {
        CGContextSaveGState(context)
        CGContextBeginPath(context)
        CGContextAddPath(context, path)
        
        // filled is usually drawn with less alpha
        CGContextSetAlpha(context, fillAlpha)
        
        fill.fillPath(context: context, rect: viewPortHandler.contentRect)
        
        CGContextRestoreGState(context)
    }
    
    /// Draws the provided path in filled mode with the provided color and alpha.
    public func drawFilledPath(context context: CGContext, path: CGPath, fillColor: NSUIColor, fillAlpha: CGFloat)
    {
        CGContextSaveGState(context)
        CGContextBeginPath(context)
        CGContextAddPath(context, path)
        
        // filled is usually drawn with less alpha
        CGContextSetAlpha(context, fillAlpha)
        
        CGContextSetFillColorWithColor(context, fillColor.CGColor)
        CGContextFillPath(context)
        
        CGContextRestoreGState(context)
    }
}