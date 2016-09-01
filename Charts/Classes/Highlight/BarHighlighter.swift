//
//  BarHighlighter.swift
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

@objc(BarChartHighlighter)
public class BarHighlighter: ChartHighlighter
{
    public override func getHighlight(x x: CGFloat, y: CGFloat) -> Highlight?
    {
        let high = super.getHighlight(x: x, y: y)
        
        if high == nil
        {
            return nil
        }
        
        if let barData = (self.chart as? BarChartDataProvider)?.barData
        {
            let pos = getValsForTouch(x: x, y: y)
            
            if let set = barData.getDataSetByIndex(high!.dataSetIndex) as? IBarChartDataSet
                where set.isStacked
            {
                return getStackedHighlight(high: high!,
                                           set: set,
                                           xValue: Double(pos.x),
                                           yValue: Double(pos.y))
            }
            
            return high
        }
        return nil
    }
    
    internal override func getDistance(x1 x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat
    {
        return abs(x1 - x2)
    }
    
    internal override var data: ChartData?
    {
        return (chart as? BarChartDataProvider)?.barData
    }
    
    /// This method creates the Highlight object that also indicates which value of a stacked BarEntry has been selected.
    /// - parameter high: the Highlight to work with looking for stacked values
    /// - parameter set:
    /// - parameter xIndex:
    /// - parameter yValue:
    /// - returns:
    public func getStackedHighlight(high high: Highlight,
                                         set: IBarChartDataSet,
                                         xValue: Double,
                                         yValue: Double) -> Highlight?
    {
        guard let
            chart = self.chart as? BarLineScatterCandleBubbleChartDataProvider,
            entry = set.entryForXValue(xValue) as? BarChartDataEntry
            else { return nil }
        
        // Not stacked
        if entry.yValues == nil
        {
            return high
        }
        
        if let ranges = entry.ranges
            where ranges.count > 0
        {
            let stackIndex = getClosestStackIndex(ranges: ranges, value: yValue)
            
            let pixel = chart
                .getTransformer(set.axisDependency)
                .pixelForValues(x: high.x, y: ranges[stackIndex].to)
            
            return Highlight(x: entry.x,
                             y: entry.y,
                             xPx: pixel.x,
                             yPx: pixel.y,
                             dataSetIndex: high.dataSetIndex,
                             stackIndex: stackIndex,
                             axis: high.axis)
        }
        
        return nil
    }
    
    /// - returns: The index of the closest value inside the values array / ranges (stacked barchart) to the value given as a parameter.
    /// - parameter entry:
    /// - parameter value:
    /// - returns:
    public func getClosestStackIndex(ranges ranges: [Range]?, value: Double) -> Int
    {
        if ranges == nil
        {
            return 0
        }
        
        var stackIndex = 0
        
        for range in ranges!
        {
            if range.contains(value)
            {
                return stackIndex
            }
            else
            {
                stackIndex += 1
            }
        }
        
        let length = max(ranges!.count - 1, 0)
        
        return (value > ranges![length].to) ? length : 0
    }
}
