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
import CoreGraphics

public class ChartRendererBase: NSObject
{
    /// the component that handles the drawing area of the chart and it's offsets
    public var viewPortHandler: ChartViewPortHandler!
    
    /// the minimum value on the x-axis that should be plotted
    public var minX: Int = 0
    
    /// the maximum value on the x-axis that should be plotted
    public var maxX: Int = 0
    
    public override init()
    {
        super.init()
    }
    
    public init(viewPortHandler: ChartViewPortHandler)
    {
        super.init()
        self.viewPortHandler = viewPortHandler
    }
    
    /// Calculates the minimum and maximum x-value the chart can currently display (with the given zoom level).
    public func calcXBounds(chart chart: BarLineChartViewBase, xAxisModulus: Int)
    {
        let low = chart.lowestVisibleXIndex
        let high = chart.highestVisibleXIndex
        
        let subLow = (low % xAxisModulus == 0) ? xAxisModulus : 0
        
        minX = max((low / xAxisModulus) * (xAxisModulus) - subLow, 0)
        maxX = min((high / xAxisModulus) * (xAxisModulus) + xAxisModulus, Int(chart.chartXMax))
    }
}
        