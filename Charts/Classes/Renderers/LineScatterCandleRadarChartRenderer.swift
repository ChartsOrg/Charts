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
import UIKit

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
    public func drawHighlightLines(context context: CGContext?, points: UnsafePointer<CGPoint>, horizontal: Bool, vertical: Bool)
    {
        // draw vertical highlight lines
        if vertical
        {
            CGContextStrokeLineSegments(context, points, 2)
        }
        
        // draw horizontal highlight lines
        if horizontal
        {
            CGContextStrokeLineSegments(context, points.advancedBy(2), 2)
        }
    }
}