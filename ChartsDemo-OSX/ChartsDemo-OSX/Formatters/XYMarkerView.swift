//
//  XYMarkerView.swift
//  ChartsDemo
//  Copyright © 2016 dcg. All rights reserved.
//

import Foundation
import Charts

open class XYMarkerView: BalloonMarker
{
    open var xAxisValueFormatter: IAxisValueFormatter?
    open var yAxisValueFormatter: IAxisValueFormatter?
    open var logXAxis : Bool?
    open var logYAxis : Bool?
    fileprivate var yFormatter = NumberFormatter()
    
    public init(color: NSColor, font: NSFont, textColor: NSColor, insets: EdgeInsets, xAxisValueFormatter: IAxisValueFormatter, yAxisValueFormatter : IAxisValueFormatter, logXAxis: Bool = false, logYAxis: Bool = false)
    {
        super.init(color: color, font: font, textColor: textColor, insets: insets)
        self.xAxisValueFormatter = xAxisValueFormatter
        self.yAxisValueFormatter = yAxisValueFormatter
        self.logXAxis = logXAxis
        self.logYAxis = logYAxis
        yFormatter.minimumFractionDigits = 1
        yFormatter.maximumFractionDigits = 1
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        var x = entry.x
        var y = entry.y
        if logXAxis == true
        {
            x = pow(10, x)
        }
        
        if logYAxis == true
        {
            y = pow(10, y)
        }
        
        setLabel("x: " + xAxisValueFormatter!.stringForValue(x, axis: nil) + ", y: " + yAxisValueFormatter!.stringForValue(y, axis: nil))
    }
}

