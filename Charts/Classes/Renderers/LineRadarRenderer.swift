//
//  LineRadarRenderer.swift
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

@objc(LineRadarChartRenderer)
public class LineRadarRenderer: LineScatterCandleRadarRenderer
{
    public override init(animator: Animator?, viewPortHandler: ViewPortHandler?)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
    }
    
    /// Draws the provided path in filled mode with the provided drawable.
    public func drawFilledPath(context context: CGContext, path: CGPath, fill: Fill, fillAlpha: CGFloat)
    {
        guard let viewPortHandler = self.viewPortHandler
            else { return }
        
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