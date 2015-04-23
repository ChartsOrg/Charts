//
//  ChartRendererBase.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 3/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics.CGBase

public class ChartRendererBase: NSObject
{
    /// the component that handles the drawing area of the chart and it's offsets
    public var viewPortHandler: ChartViewPortHandler!;
    internal var _minX: Int = 0;
    internal var _maxX: Int = 0;
    
    public override init()
    {
        super.init();
    }
    
    public init(viewPortHandler: ChartViewPortHandler)
    {
        super.init();
        self.viewPortHandler = viewPortHandler;
    }

    /// Returns true if the specified value fits in between the provided min and max bounds, false if not.
    internal func fitsBounds(val: Float, min: Float, max: Float) -> Bool
    {
        if (val < min || val > max)
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    
    /// Calculates the minimum and maximum x-value the chart can currently display (with the given zoom level).
    internal func calcXBounds(trans: ChartTransformer!)
    {
        var minx = trans.getValueByTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: 0.0)).x;
        var maxx = trans.getValueByTouchPoint(CGPoint(x: viewPortHandler.contentRight, y: 0.0)).x;
        
        if (isnan(minx))
        {
            minx = 0;
        }
        if (isnan(maxx))
        {
            maxx = 0;
        }
        
        if (!isinf(minx))
        {
            _minX = max(0, Int(minx));
        }
        if (!isinf(maxx))
        {
            _maxX = max(0, Int(ceil(maxx)));
        }
    }
}