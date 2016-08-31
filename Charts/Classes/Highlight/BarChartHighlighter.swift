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

open class BarChartHighlighter: ChartHighlighter
{
    open override func getHighlight(x: CGFloat, y: CGFloat) -> ChartHighlight?
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
            
            if let set = barData.getDataSetByIndex(dataSetIndex) as? IBarChartDataSet, set.isStacked
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
    
    open override func getXIndex(_ x: CGFloat) -> Int
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
    
    open override func getSelectionDetail(xIndex: Int, y: CGFloat, dataSetIndex: Int?) -> ChartSelectionDetail?
    {
        if let barData = self.chart?.data as? BarChartData
        {
            let dataSetIndex = dataSetIndex ?? 0
			if let dataSet = (barData.dataSetCount > dataSetIndex ? barData.getDataSetByIndex(dataSetIndex) : nil) {
				let yValue = dataSet.yValForXIndex(xIndex)
            
				if yValue.isNaN { return nil }
            
				return ChartSelectionDetail(value: yValue, dataSetIndex: dataSetIndex, dataSet: dataSet)
			}
			return nil
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
    open func getStackedHighlight(selectionDetail: ChartSelectionDetail,
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

        if let ranges = getRanges(entry: entry), ranges.count > 0
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
    open func getClosestStackIndex(ranges: [ChartRange]?, value: Double) -> Int
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
    open func getBase(_ x: CGFloat) -> Double
    {
        guard let barData = self.chart?.data as? BarChartData
            else { return 0.0 }
        
        // create an array of the touch-point
        var pt = CGPoint()
        pt.x = CGFloat(x)
        
        // take any transformer to determine the x-axis value
        self.chart?.getTransformer(ChartYAxis.AxisDependency.left).pixelToValue(&pt)
        let xVal = Double(pt.x)
        
        let setCount = barData.dataSetCount 
        
        // calculate how often the group-space appears
        let steps = Int(xVal / (Double(setCount) + Double(barData.groupSpace)))
        
        let groupSpaceSum = Double(barData.groupSpace) * Double(steps)
        
        let baseNoSpace = xVal - groupSpaceSum
        
        return baseNoSpace
    }

    /// Splits up the stack-values of the given bar-entry into Range objects.
    /// - parameter entry:
    /// - returns:
    open func getRanges(entry: BarChartDataEntry) -> [ChartRange]?
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
