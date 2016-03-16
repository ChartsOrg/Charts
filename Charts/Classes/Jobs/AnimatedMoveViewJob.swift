//
//  AnimatedMoveChartViewJob.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

public class AnimatedMoveChartViewJob: AnimatedViewPortJob
{
    public override init(
        viewPortHandler: ChartViewPortHandler,
        xIndex: CGFloat,
        yValue: Double,
        transformer: ChartTransformer,
        view: ChartViewBase,
        xOrigin: CGFloat,
        yOrigin: CGFloat,
        duration: NSTimeInterval,
        easing: ChartEasingFunctionBlock?)
    {
        super.init(viewPortHandler: viewPortHandler,
            xIndex: xIndex,
            yValue: yValue,
            transformer: transformer,
            view: view,
            xOrigin: xOrigin,
            yOrigin: yOrigin,
            duration: duration,
            easing: easing)
    }
    
    internal override func animationUpdate()
    {
        guard let
            viewPortHandler = viewPortHandler,
            transformer = transformer,
            view = view
            else { return }
        
        var pt = CGPoint(
            x: xOrigin + (xIndex - xOrigin) * phase,
            y: yOrigin + (CGFloat(yValue) - yOrigin) * phase
        );
        
        transformer.pointValueToPixel(&pt)
        viewPortHandler.centerViewPort(pt: pt, chart: view)
    }
}