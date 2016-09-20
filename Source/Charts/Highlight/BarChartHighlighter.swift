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
            let xIndex = getXIndex(x)
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
            
            guard let selectionDetail = getSelectionDetail(xIndex: xIndex, y: y, dataSetIndex: dataSetIndex)
                else { return nil }
            
            if let set = barData.getDataSetByIndex(dataSetIndex) as? IBarChartDataSet
                where set.isStacked
            {
                var pt = CGPoint(x: 0.0, y: y)
                
                // take any transformer to determine the x-axis value
                self.chart?.getTransformer(set.axisDependency).pixelToValue(&pt)
                
                return getStackedHighlight(selectionDetail: selectionDetail,
                                           set: set,
                                           xIndex: xIndex,
                                           yValue: Double(pt.y))
            }
            
            return ChartHighlight(xIndex: xIndex,
                                  value: selectionDetail.value,
                                  dataIndex: selectionDetail.dataIndex,
                                  dataSetIndex: selectionDetail.dataSetIndex,
                                  stackIndex: -1)
        }
        return nil
    }
    
    public override func getXIndex(x: CGFloat) -> Int
    {
        if let barData = self.chart?.data as? BarChartData
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
                
                let valCount = barData.xValCount
                
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
    
    public override func getSelectionDetail(xIndex xIndex: Int, y: CGFloat, dataSetIndex: Int?) -> ChartSelectionDetail?
    {
        if let barData = self.chart?.data as? BarChartData
        {
            let dataSetIndex = dataSetIndex ?? 0
            let dataSet = barData.dataSetCount > dataSetIndex ? barData.getDataSetByIndex(dataSetIndex) : nil
            let yValue = dataSet.yValForXIndex(xIndex)
            
            if isnan(yValue) { return nil }
            
            return ChartSelectionDetail(value: yValue, dataSetIndex: dataSetIndex, dataSet: dataSet)
        }
        else
        {
            return nil
        }
    }
    
    /// This method creates the Highlight object that also indicates which value of a stacked BarEntry has been selected.
    /// - parameter selectionDetail: the selection detail to work with
    /// - parameter set:
    /// - parameter xIndex:
    /// - parameter yValue:
    /// - returns:
    public func getStackedHighlight(selectionDetail selectionDetail: ChartSelectionDetail,
                                                    set: IBarChartDataSet,
                                                    xIndex: Int,
                                                    yValue: Double) -> ChartHighlight?
    {
        guard let entry = set.entryForXIndex(xIndex) as? BarChartDataEntry
            else { return nil }
        
        if entry.values == nil
        {
            return ChartHighlight(xIndex: xIndex,
                                  value: entry.value,
                                  dataIndex: selectionDetail.dataIndex,
                                  dataSetIndex: selectionDetail.dataSetIndex,
                                  stackIndex: -1)
        }

        if let ranges = getRanges(entry: entry)
            where ranges.count > 0
        {
            let stackIndex = getClosestStackIndex(ranges: ranges, value: yValue)
            return ChartHighlight(xIndex: xIndex,
                                   value: entry.positiveSum - entry.negativeSum,
                                   dataIndex: selectionDetail.dataIndex,
                                   dataSetIndex: selectionDetail.dataSetIndex,
                                   stackIndex: stackIndex,
                                   range: ranges[stackIndex])
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
    
    /// Returns the base x-value to the corresponding x-touch value in pixels.
    /// - parameter x:
    /// - returns:
    public func getBase(x: CGFloat) -> Double
    {
        guard let barData = self.chart?.data as? BarChartData
            else { return 0.0 }
        
        // create an array of the touch-point
        var pt = CGPoint()
        pt.x = CGFloat(x)
        
        // take any transformer to determine the x-axis value
        self.chart?.getTransformer(ChartYAxis.AxisDependency.Left).pixelToValue(&pt)
        let xVal = Double(pt.x)
        
        let setCount = barData.dataSetCount ?? 0
        
        // calculate how often the group-space appears
        let steps = Int(xVal / (Double(setCount) + Double(barData.groupSpace)))
        
        let groupSpaceSum = Double(barData.groupSpace) * Double(steps)
        
        let baseNoSpace = xVal - groupSpaceSum
        
        return baseNoSpace
    }

    /// Splits up the stack-values of the given bar-entry into Range objects.
    /// - parameter entry:
    /// - returns:
    public func getRanges(entry entry: BarChartDataEntry) -> [ChartRange]?
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
