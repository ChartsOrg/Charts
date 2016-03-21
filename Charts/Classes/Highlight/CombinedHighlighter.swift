//
//  CombinedHighlighter.swift
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

public class CombinedHighlighter: ChartHighlighter
{
    /// Attension: Use super's getSelectionDetailsAtIndex to return the dataSetIndex in whole data.dataSets range, not subData's
    public override func getSelectionDetailsAtIndex(xIndex: Int) -> [ChartSelectionDetail]
    {
        return super.getSelectionDetailsAtIndex(xIndex)
    }

    public override func getHighlight(x x: Double, y: Double) -> ChartHighlight?
    {
        var h: ChartHighlight?
        
        h = super.getHighlight(x: x, y: y)
        
        if h === nil
        {
            return h
        }
        else
        {
            if let set = chart?.data?.getDataSetByIndex(h!.dataSetIndex) as? BarChartDataSet
            {
                if set.isStacked
                {
                    // caeate an array of the touch-point
                    var pt = CGPoint()
                    pt.y = CGFloat(y)
                    
                    // take the barChartTransformer from CombinedChartView to determine the x-axis value
                    (chart as? CombinedChartView)?.getBarChartTransformer(set.axisDependency).pixelToValue(&pt)
                    
                    return getStackedHighlight(old: h, set: set, xIndex: h!.xIndex, dataSetIndex: h!.dataSetIndex, yValue: Double(pt.y))
                }
                else
                {
                    
                }
            }
            
            return h
        }
    }
    
    /**
     Returns the corresponding x-index for a given touch-position in pixels.
     
     - parameter x: Double, point.x
     
     - returns: Int, xIndex
     */
    public override func getXIndex(x: Double) -> Int
    {
        if let barData = (chart as? CombinedChartView)?.barData
        {
            if !barData.isGrouped
            {
                return super.getXIndex(x)
            }
            else
            {
                let baseNoSpace = getBase(x)
                
                let setCount = barData.dataSetCount
                var xIndex = Int(baseNoSpace) / setCount
                
                if let valCount = chart?.data?.xValCount
                {
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
                else
                {
                    return -Int.max
                }
            }
        }
        
        return super.getXIndex(x)
    }
    
    /**
     get dataSetIndex for combined chart data.
     
     if the barData is not grouped, call super's;
     
     if the super's dataSetIndex's corresponding dataSet is LineChartDataSet, return this index
     
     Otherwise, calculate dataSetIndex for combined chart data based on the index of bar data's dataSetIndex
     
     - parameter xIndex: Int
     - parameter x:      Double
     - parameter y:      Double
     
     - returns: Int
     */
    public override func getDataSetIndex(xIndex xIndex: Int, x: Double, y: Double) -> Int
    {
        if let barData = (chart as? CombinedChartView)?.barData
        {
            if !barData.isGrouped
            {
                return super.getDataSetIndex(xIndex: xIndex, x: x, y: y)
            }
            else
            {
                // test which bar dataSet is selected
                let baseNoSpace = getBase(x)
                
                let setCount = barData.dataSetCount
                var dataSetIndex = Int(baseNoSpace) % setCount
                
                if dataSetIndex < 0
                {
                    dataSetIndex = 0
                }
                else if dataSetIndex >= setCount
                {
                    dataSetIndex = setCount - 1
                }
                
                let superDataSetIndex = super.getDataSetIndex(xIndex: xIndex, x: x, y: y)
                let dataSet = (chart as? CombinedChartView)?.data?.getDataSetByIndex(superDataSetIndex)
                
                if (dataSet != nil)
                {
                    if (dataSet!.dynamicType !== BarChartDataSet.self)
                    {
                        return superDataSetIndex
                    }
                }
                
                let barDataSet = barData.getDataSetByIndex(dataSetIndex)
                
                let combinedData = (chart as! CombinedChartView).data
                
                let barDataSetIndexInCombinedChartData = combinedData!.indexOfDataSet(barDataSet!)
                
                return barDataSetIndexInCombinedChartData
            }
        }
        else
        {
            return super.getDataSetIndex(xIndex: xIndex, x: x, y: y)
        }
    }
    
    /**
     Same as BarChartHighlighter.getStackedHighlight()
     
     Whatever changed in BarChartHighlighter.getStackedHighlight() should also be applied here
     
     This method creates the Highlight object that also indicates which value of a stacked BarEntry has been selected.
     
     - parameter old:          ChartHighlight
     - parameter set:          BarChartDataSet
     - parameter xIndex:       Int
     - parameter dataSetIndex: Int
     - parameter yValue:       Double
     
     - returns: ChartHighlight?
     */
    internal func getStackedHighlight(old old: ChartHighlight?, set: BarChartDataSet, xIndex: Int, dataSetIndex: Int, yValue: Double) -> ChartHighlight?
    {
        let entry = set.entryForXIndex(xIndex) as? BarChartDataEntry
        
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
    
    /**
     Same as BarChartHighlighter.getClosestStackIndex()
     
     Whatever changed in BarChartHighlighter.getClosestStackIndex() should also be applied here
     
     Returns the index of the closest value inside the values array / ranges (stacked barchart) to the value given as a parameter.
     
     - parameter ranges: [ChartRange]?
     - parameter value:  Double
     
     - returns: Int
     */
    internal func getClosestStackIndex(ranges ranges: [ChartRange]?, value: Double) -> Int
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
    
    /**
     Same as BarChartHighlighter.getBase()
     
     Whatever changed in BarChartHighlighter.getBase() should also be applied here
     
     Returns the base x-value to the corresponding x-touch value in pixels.
     
     - parameter x: Double
     
     - returns: Double
     */
    internal func getBase(x: Double) -> Double
    {
        if let barData = (chart as? CombinedChartView)?.barData
        {
            // create an array of the touch-point
            var pt = CGPoint()
            pt.x = CGFloat(x)
            
            // take any transformer to determine the x-axis value
            (chart as? CombinedChartView)?.getBarChartTransformer(ChartYAxis.AxisDependency.Left).pixelToValue(&pt)
            let xVal = Double(pt.x)
            
            let setCount = barData.dataSetCount ?? 0
            
            // calculate how often the group-space appears
            let steps = Int(xVal / (Double(setCount) + Double(barData.groupSpace)))
            
            let groupSpaceSum = Double(barData.groupSpace) * Double(steps)
            
            let baseNoSpace = xVal - groupSpaceSum
            
            return baseNoSpace
        }
        else
        {
            return 0.0
        }
    }
    
    /**
     Same as BarChartHighlighter.getRanges()
     
     Whatever changed in BarChartHighlighter.getRanges() should also be applied here
     
     Splits up the stack-values of the given bar-entry into Range objects.
     
     - parameter entry: BarChartDataEntry
     
     - returns: [ChartRange]?
     */
    internal func getRanges(entry entry: BarChartDataEntry) -> [ChartRange]?
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
