//
//  HorizontalBarHighlighter.swift
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

@objc(HorizontalBarChartHighlighter)
public class HorizontalBarHighlighter: BarHighlighter
{
    public override func getHighlight(x x: CGFloat, y: CGFloat) -> Highlight?
    {
        if let barData = self.chart?.data as? BarChartData
        {
            let pos = getValsForTouch(x: y, y: x)
            
            guard let high = getHighlight(xValue: Double(pos.y), x: y, y: x)
                else { return nil }
            
            if let set = barData.getDataSetByIndex(high.dataSetIndex) as? IBarChartDataSet
                where set.isStacked
            {
                return getStackedHighlight(high: high,
                                           set: set,
                                           xValue: Double(pos.y),
                                           yValue: Double(pos.x))
            }
            
            return high
        }
        return nil
    }
    
    internal override func buildHighlight(
        dataSet set: IChartDataSet,
        dataSetIndex: Int,
        xValue: Double,
        rounding: ChartDataSetRounding) -> Highlight?
    {
        guard let chart = self.chart as? BarLineScatterCandleBubbleChartDataProvider
            else { return nil }
        
        if let e = set.entryForXValue(xValue, rounding: rounding)
        {
            let px = chart.getTransformer(set.axisDependency).pixelForValues(x: e.y, y: e.x)
            
            return Highlight(x: e.x, y: e.y, xPx: px.x, yPx: px.y,dataSetIndex: dataSetIndex, axis: set.axisDependency)
        }
        
        return nil
    }
    
    internal override func getDistance(x1 x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat
    {
        return abs(y1 - y2)
    }
}
