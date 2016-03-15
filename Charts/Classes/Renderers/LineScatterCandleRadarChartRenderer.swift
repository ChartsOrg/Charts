//
//  LineScatterCandleRadarChartRenderer.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 29/7/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics


public class LineScatterCandleRadarChartRenderer: ChartDataRendererBase
{
    public override init(animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
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
        
        if set.isHighlightCrossEnabled
        {
            CGContextBeginPath(context)
            CGContextAddArc(context, point.x, point.y, 2.0, 0.0, CGFloat(M_PI) * 2, 1)
            CGContextSetFillColorWithColor(context,  set.highlightColor.CGColor)
            CGContextFillPath(context)
            CGContextStrokePath(context)
            
//            let dataEntry = set.entryForXIndex(Int(point.x))
//            let text = String(dataEntry?.xIndex) as NSString
//            text.drawInRect(CGRectMake(viewPortHandler.contentLeft, point.y, 40, 20), withAttributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(14)])
//            text.drawInRect(CGRectMake(viewPortHandler.contentRight-40, point.y, 40, 20), withAttributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(14)])
            
        }
        
        
    }
}