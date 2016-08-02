//
//  ChartBarHighlighter.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 26/7/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

public class BarChartHighlighter: ChartHighlighter
{
    public override func getHighlight(x x: CGFloat, y: CGFloat) -> ChartHighlight?
    {
        if let barData = self.chart?.data as? BarChartData
        {
            let pos = getValsForTouch(x: x, y: y)
            
            guard let high = getHighlight(xValue: Double(pos.x), x: x, y: y)
                else { return nil }
            
            if let set = barData.getDataSetByIndex(high.dataSetIndex) as? IBarChartDataSet
                where set.isStacked
            {
                return getStackedHighlight(high: high,
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
    
    /// This method creates the Highlight object that also indicates which value of a stacked BarEntry has been selected.
    /// - parameter high: the Highlight to work with looking for stacked values
    /// - parameter set:
    /// - parameter xIndex:
    /// - parameter yValue:
    /// - returns:
    public func getStackedHighlight(high high: ChartHighlight,
                                         set: IBarChartDataSet,
                                         xValue: Double,
                                         yValue: Double) -> ChartHighlight?
    {
        guard let
            chart = self.chart as? BarLineScatterCandleBubbleChartDataProvider,
            entry = set.entryForXPos(xValue) as? BarChartDataEntry
            else { return nil }
        
        // Not stacked
        if entry.yValues == nil
        {
            return high
        }
        
        if let ranges = getRanges(entry: entry)
            where ranges.count > 0
        {
            let stackIndex = getClosestStackIndex(ranges: ranges, value: yValue)
            
            let range = ranges[stackIndex]
            
            let pixel = chart.getTransformer(set.axisDependency).pixelForValue(x: high.x, y: range.to)

            return ChartHighlight(x: entry.x,
                                  y: entry.y,
                                  xPx: pixel.x,
                                  yPx: pixel.y,
                                  dataSetIndex: high.dataSetIndex,
                                  stackIndex: stackIndex,
                                  range: range,
                                  axis: high.axis)
        }
        
        return nil
    }
    
    /// Returns the index of the closest value inside the values array / ranges (stacked barchart) to the value given as a parameter.
    /// - parameter entry:
    /// - parameter value:
    /// - returns:
    public func getClosestStackIndex(ranges ranges: [ChartRange]?, value: Double) -> Int
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
    
    /// Splits up the stack-values of the given bar-entry into Range objects.
    /// - parameter entry:
    /// - returns:
    public func getRanges(entry entry: BarChartDataEntry) -> [ChartRange]?
    {
        let values = entry.yValues
        if (values == nil)
        {
            return nil
        }
        
        var negRemain = -entry.negativeSum
        var posRemain: Double = 0.0
        
        var ranges = [ChartRange]()
        ranges.reserveCapacity(values!.count)
        
        for i in 0 ..< values!.count
        {
            let value = values![i]
            
            if value < 0
            {
                ranges.append(ChartRange(from: negRemain, to: negRemain + abs(value)))
                negRemain += abs(value)
            }
            else
            {
                ranges.append(ChartRange(from: posRemain, to: posRemain+value))
                posRemain += value
            }
        }
        
        return ranges
    }
}
