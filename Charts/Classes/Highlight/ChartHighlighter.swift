//
//  ChartHighlighter.swift
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

public class ChartHighlighter : NSObject
{
    /// instance of the data-provider
    public weak var chart: BarLineChartViewBase?
    
    public init(chart: BarLineChartViewBase)
    {
        self.chart = chart
    }
    
    /// Returns a Highlight object corresponding to the given x- and y- touch positions in pixels.
    /// - parameter x:
    /// - parameter y:
    /// - returns:
    public func getHighlight(x x: CGFloat, y: CGFloat) -> ChartHighlight?
    {
        let xVal = Double(getValsForTouch(x: x, y: y).x)
        
        guard let
            selectionDetail = getSelectionDetail(xValue: xVal, x: x, y: y)
            else { return nil }
        
        return ChartHighlight(
            x: selectionDetail.xValue,
            y: selectionDetail.yValue,
            dataIndex: selectionDetail.dataIndex,
            dataSetIndex: selectionDetail.dataSetIndex,
            stackIndex: -1)
    }
    
    /// Returns the corresponding x-pos for a given touch-position in pixels.
    /// - parameter x:
    /// - returns:
    public func getValsForTouch(x x: CGFloat, y: CGFloat) -> CGPoint
    {
        guard let chart = self.chart
            else { return CGPointZero }
        
        // take any transformer to determine the values
        return chart.getTransformer(ChartYAxis.AxisDependency.Left).valueForTouchPoint(x: x, y: y)
    }
    
    /// Returns the corresponding ChartSelectionDetail for a given x-value and xy-touch position in pixels.
    /// - parameter xValue:
    /// - parameter x:
    /// - parameter y:
    /// - returns:
    public func getSelectionDetail(xValue xVal: Double, x: CGFloat, y: CGFloat) -> ChartSelectionDetail?
    {
        guard let chart = chart
            else { return nil }
        
        let valsAtIndex = getSelectionDetailsAtIndex(xVal)
        
        let leftdist = getMinimumDistance(valsAtIndex, y: y, axis: ChartYAxis.AxisDependency.Left)
        let rightdist = getMinimumDistance(valsAtIndex, y: y, axis: ChartYAxis.AxisDependency.Right)
        
        let axis = leftdist < rightdist ? ChartYAxis.AxisDependency.Left : ChartYAxis.AxisDependency.Right
        
        let detail = closestSelectionDetailByPixel(valsAtIndex: valsAtIndex, x: x, y: y, axis: axis, minSelectionDistance: chart.maxHighlightDistance)
        
        return detail
    }
    
    /// Returns a list of SelectionDetail object corresponding to the given x-value.
    /// - parameter xValue:
    /// - returns:
    public func getSelectionDetailsAtIndex(xValue: Double) -> [ChartSelectionDetail]
    {
        var vals = [ChartSelectionDetail]()
        
        guard let
            data = self.chart?.data
            else { return vals }
        
        for i in 0 ..< data.dataSetCount
        {
            let dataSet = data.getDataSetByIndex(i)
            
            // dont include datasets that cannot be highlighted
            if !dataSet.isHighlightEnabled
            {
                continue
            }
            
            // extract all y-values from all DataSets at the given x-value.
            // some datasets (i.e bubble charts) make sense to have multiple values for an x-value. We'll have to find a way to handle that later on. It's more complicated now when x-indices are floating point.
            
            if let details = getDetails(dataSet, dataSetIndex: i, xValue: xValue, rounding: .Up)
            {
                vals.append(details)
            }
            
            if let details = getDetails(dataSet, dataSetIndex: i, xValue: xValue, rounding: .Down)
            {
                vals.append(details)
            }
        }
        
        return vals
    }
    
    internal func getDetails(
        set: IChartDataSet,
        dataSetIndex: Int,
        xValue: Double,
        rounding: ChartDataSetRounding) -> ChartSelectionDetail?
    {
        guard let chart = self.chart
            else { return nil }
        
        if let e = set.entryForXPos(xValue, rounding: rounding)
        {
            let px = chart.getTransformer(set.axisDependency).pixelForValue(x: e.x, y: e.y)
            
            return ChartSelectionDetail(x: px.x, y: px.y, xValue: e.x, yValue: e.y, dataSetIndex: dataSetIndex, dataSet: set)
        }
        
        return nil
    }

    // - MARK: - Utilities
    
    /// - returns: the `ChartSelectionDetail` of the closest value on the x-y cartesian axes
    internal func closestSelectionDetailByPixel(
        valsAtIndex valsAtIndex: [ChartSelectionDetail],
                    x: CGFloat,
                    y: CGFloat,
                    axis: ChartYAxis.AxisDependency?,
                    minSelectionDistance: CGFloat) -> ChartSelectionDetail?
    {
        var distance = minSelectionDistance
        var detail: ChartSelectionDetail?
        
        for i in 0 ..< valsAtIndex.count
        {
            let sel = valsAtIndex[i]
            
            if (axis == nil || sel.dataSet?.axisDependency == axis)
            {
                let cDistance = getDistance(x: x, y: y, selX: sel.x, selY: sel.y)
                
                if (cDistance < distance)
                {
                    detail = sel
                    distance = cDistance
                }
            }
        }
        
        return detail
    }
    
    /// - returns: the minimum distance from a touch-y-value (in pixels) to the closest y-value (in pixels) that is displayed in the chart.
    internal func getMinimumDistance(
        valsAtIndex: [ChartSelectionDetail],
        y: CGFloat,
        axis: ChartYAxis.AxisDependency) -> CGFloat
    {
        var distance = CGFloat.max
        
        for i in 0 ..< valsAtIndex.count
        {
            let sel = valsAtIndex[i]
            
            if (sel.dataSet!.axisDependency == axis)
            {
                let cdistance = abs(getSelectionPos(sel: sel) - y)
                if (cdistance < distance)
                {
                    distance = cdistance
                }
            }
        }
        
        return distance
    }
    
    internal func getSelectionPos(sel sel: ChartSelectionDetail) -> CGFloat
    {
        return sel.y
    }
    
    internal func getDistance(x x: CGFloat, y: CGFloat, selX: CGFloat, selY: CGFloat) -> CGFloat
    {
        return hypot(x - selX, y - selY)
    }
}
