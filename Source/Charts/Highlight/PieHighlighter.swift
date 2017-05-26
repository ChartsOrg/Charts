//
//  PieHighlighter.swift
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

@objc(PieChartHighlighter)
open class PieHighlighter: PieRadarHighlighter
{
    open override func closestHighlight(index: Int, x: CGFloat, y: CGFloat) -> Highlight?
    {
        guard let set = chart?.data?.dataSets[0]
            else { return nil }
        
        guard let entry = set.entryForIndex(index)
            else { return nil }
        
        guard let chart = self.chart as? PieChartView
            else { return nil }
        
        if chart.isTapHoleEnabled
        {
            let touchDistanceToCenter = chart.distanceToCenter(x: x, y: y)
            if touchDistanceToCenter < chart.holeRadiusPercent * chart.radius {return nil}
        }
        
        
        return Highlight(x: Double(index), y: entry.y, xPx: x, yPx: y, dataSetIndex: 0, axis: set.axisDependency)
    }
    
    
}
