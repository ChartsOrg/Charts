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
            
            guard let selectionDetail = getSelectionDetail(xValue: Double(pos.x), x: x, y: y)
                else { return nil }
            
            if let set = barData.getDataSetByIndex(selectionDetail.dataSetIndex) as? IBarChartDataSet
                where set.isStacked
            {
                return getStackedHighlight(selectionDetail: selectionDetail,
                                           set: set,
                                           xValue: Double(pos.x),
                                           yValue: Double(pos.y))
            }
            
            return ChartHighlight(x: selectionDetail.xValue,
                                  y: selectionDetail.yValue,
                                  dataIndex: selectionDetail.dataIndex,
                                  dataSetIndex: selectionDetail.dataSetIndex,
                                  stackIndex: -1)
        }
        return nil
    }
    
    internal override func getDistance(x x: CGFloat, y: CGFloat, selX: CGFloat, selY: CGFloat) -> CGFloat
    {
        return abs(x - selX)
    }
    
    /// This method creates the Highlight object that also indicates which value of a stacked BarEntry has been selected.
    /// - parameter selectionDetail: the selection detail to work with looking for stacked values
    /// - parameter set:
    /// - parameter xIndex:
    /// - parameter yValue:
    /// - returns:
    public func getStackedHighlight(selectionDetail selectionDetail: ChartSelectionDetail,
                                                    set: IBarChartDataSet,
                                                    xValue: Double,
                                                    yValue: Double) -> ChartHighlight?
    {
        guard let entry = set.entryForXPos(xValue) as? BarChartDataEntry
            else { return nil }
        
        // Not stacked
        if entry.yValues == nil
        {
            return ChartHighlight(x: entry.x,
                                  y: entry.y,
                                  dataIndex: selectionDetail.dataIndex,
                                  dataSetIndex: selectionDetail.dataSetIndex,
                                  stackIndex: -1)
        }
        
        if let ranges = getRanges(entry: entry)
            where ranges.count > 0
        {
            let stackIndex = getClosestStackIndex(ranges: ranges, value: yValue)
            return ChartHighlight(x: entry.x,
                                  y: entry.positiveSum - entry.negativeSum,
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
