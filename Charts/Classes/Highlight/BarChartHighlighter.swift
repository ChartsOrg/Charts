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
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

internal class BarChartHighlighter: ChartHighlighter
{
    internal init(chart: BarChartView)
    {
        super.init(chart: chart)
    }
    
    internal override func getHighlight(#x: Double, y: Double) -> ChartHighlight?
    {
        var h = super.getHighlight(x: x, y: y)
        
        if h === nil
        {
            return h
        }
        else
        {
            if let set = _chart?.data?.getDataSetByIndex(h!.dataSetIndex) as? BarChartDataSet
            {
                if set.isStacked
                {
                    // create an array of the touch-point
                    var pt = CGPoint()
                    pt.y = CGFloat(y)
                    
                    // take any transformer to determine the x-axis value
                    _chart?.getTransformer(set.axisDependency).pixelToValue(&pt)
                    
                    return getStackedHighlight(old: h, set: set, xIndex: h!.xIndex, dataSetIndex: h!.dataSetIndex, yValue: Double(pt.y))
                }
            }
            
            return h
        }
    }
    
    internal override func getXIndex(x: Double) -> Int
    {
        if let barChartData = _chart?.data as? BarChartData
        {
            if !barChartData.isGrouped
            {
                return super.getXIndex(x)
            }
            else
            {
                let baseNoSpace = getBase(x)
                
                let setCount = barChartData.dataSetCount
                var xIndex = Int(baseNoSpace) / setCount
                
                let valCount = barChartData.xValCount
                
                if xIndex < 0
                {
                    xIndex = 0
                }
                else if xIndex >= valCount
                {
                    xIndex = valCount - 1
                }
                
                return xIndex
            }
        }
        else
        {
            return 0
        }
    }
    
    internal override func getDataSetIndex(#xIndex: Int, x: Double, y: Double) -> Int
    {
        if let barChartData = _chart?.data as? BarChartData
        {
            if !barChartData.isGrouped
            {
                return 0
            }
            else
            {
                let baseNoSpace = getBase(x)
                
                let setCount = barChartData.dataSetCount
                var dataSetIndex = Int(baseNoSpace) % setCount
                
                if dataSetIndex < 0
                {
                    dataSetIndex = 0
                }
                else if dataSetIndex >= setCount
                {
                    dataSetIndex = setCount - 1
                }
                
                return dataSetIndex
            }
        }
        else
        {
            return 0
        }
    }
    
    /// This method creates the Highlight object that also indicates which value of a stacked BarEntry has been selected.
    /// :param: old the old highlight object before looking for stacked values
    /// :param: set
    /// :param: xIndex
    /// :param: dataSetIndex
    /// :param: yValue
    /// :returns:
    internal func getStackedHighlight(#old: ChartHighlight?, set: BarChartDataSet, xIndex: Int, dataSetIndex: Int, yValue: Double) -> ChartHighlight?
    {
        var entry = set.entryForXIndex(xIndex) as? BarChartDataEntry
        
        if entry?.values === nil
        {
            return old
        }

        if let ranges = getRanges(entry: entry!)
        {
            let stackIndex = getClosestStackIndex(ranges: ranges, value: yValue)
            let h = ChartHighlight(xIndex: xIndex, dataSetIndex: dataSetIndex, stackIndex: stackIndex, range: ranges[stackIndex])
            return h
        }
        return nil
    }
    
    /// Returns the index of the closest value inside the values array / ranges (stacked barchart) to the value given as a parameter.
    /// :param: entry
    /// :param: value
    /// :returns:
    internal func getClosestStackIndex(#ranges: [ChartRange]?, value: Double) -> Int
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
                stackIndex++
            }
        }
        
        let length = ranges!.count - 1
        
        return (value > ranges![length].to) ? length : 0
    }
    
    /// Returns the base x-value to the corresponding x-touch value in pixels.
    /// :param: x
    /// :returns:
    internal func getBase(x: Double) -> Double
    {
        if let barChartData = _chart?.data as? BarChartData
        {
            // create an array of the touch-point
            var pt = CGPoint()
            pt.x = CGFloat(x)
            
            // take any transformer to determine the x-axis value
            _chart?.getTransformer(ChartYAxis.AxisDependency.Left).pixelToValue(&pt)
            let xVal = Double(pt.x)
            
            let setCount = barChartData.dataSetCount ?? 0
            
            // calculate how often the group-space appears
            let steps = Int(xVal / (Double(setCount) + Double(barChartData.groupSpace)))
            
            let groupSpaceSum = Double(barChartData.groupSpace) * Double(steps)
            
            let baseNoSpace = xVal - groupSpaceSum
            
            return baseNoSpace
        }
        else
        {
            return 0.0
        }
    }

    /// Splits up the stack-values of the given bar-entry into Range objects.
    /// :param: entry
    /// :returns:
    internal func getRanges(#entry: BarChartDataEntry) -> [ChartRange]?
    {
        let values = entry.values
        if (values == nil)
        {
            return nil
        }
        
        var negRemain = -entry.negativeSum
        var posRemain: Double = 0.0
        
        var ranges = [ChartRange]()
        ranges.reserveCapacity(values!.count)
        
        for (var i = 0, count = values!.count; i < count; i++)
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
