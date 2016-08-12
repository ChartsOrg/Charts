//
//  LineScatterCandleRadarRenderer.swift
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

@objc(LineScatterCandleRadarChartRenderer)
public class LineScatterCandleRadarRenderer: BarLineScatterCandleBubbleRenderer
{
    public override init(animator: Animator?, viewPortHandler: ViewPortHandler?)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
    }
    
    /// Draws vertical & horizontal highlight-lines if enabled.
    /// :param: context
    /// :param: points
    /// :param: horizontal
    /// :param: vertical
    public func drawHighlightLines(context context: CGContext, point: CGPoint, set: ILineScatterCandleRadarChartDataSet)
    {
        guard let
            viewPortHandler = self.viewPortHandler
            else { return }
        
        // draw vertical highlight lines
        if set.isVerticalHighlightIndicatorEnabled
        {
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, point.x, viewPortHandler.contentTop)
            CGContextAddLineToPoint(context, point.x, viewPortHandler.contentBottom)
            CGContextStrokePath(context)
        }
        
        // draw horizontal highlight lines
        if set.isHorizontalHighlightIndicatorEnabled
        {
            CGContextBeginPath(context)
            CGContextMoveToPoint(context, viewPortHandler.contentLeft, point.y)
            CGContextAddLineToPoint(context, viewPortHandler.contentRight, point.y)
            CGContextStrokePath(context)
        }
    }
}