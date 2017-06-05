//
//  XYMarkerView.swift
//  ChartsDemo
//  Copyright © 2016 dcg. All rights reserved.
//

import Foundation
import Charts

open class YMarkerView: BalloonMarker
{
    open var yAxisValueFormatter: IAxisValueFormatter?
    fileprivate var yFormatter = NumberFormatter()
    
    public init(color: NSColor, font: NSFont, textColor: NSColor, insets: EdgeInsets, yAxisValueFormatter : IAxisValueFormatter)
    {
        super.init(color: color, font: font, textColor: textColor, insets: insets)
        
        self.yAxisValueFormatter = yAxisValueFormatter
        yFormatter.minimumFractionDigits = 1
        yFormatter.maximumFractionDigits = 1
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        setLabel("y: " + yAxisValueFormatter!.stringForValue(entry.y, axis: nil))
    }
}



