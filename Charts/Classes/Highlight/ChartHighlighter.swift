//
//  ChartHighlighter.swift
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

public class ChartHighlighter : NSObject, IHighlighter
{
    /// instance of the data-provider
    public weak var chart: ChartDataProvider?
    
    public init(chart: ChartDataProvider)
    {
        self.chart = chart
    }
    
    public func getHighlight(x x: CGFloat, y: CGFloat) -> Highlight?
    {
        let xVal = Double(getValsForTouch(x: x, y: y).x)
        
        return getHighlight(xValue: xVal, x: x, y: y)
    }
    
    /// - returns: The corresponding x-pos for a given touch-position in pixels.
    /// - parameter x:
    /// - returns:
    public func getValsForTouch(x x: CGFloat, y: CGFloat) -> CGPoint
    {
        guard let chart = self.chart as? BarLineScatterCandleBubbleChartDataProvider
            else { return CGPointZero }
        
        // take any transformer to determine the values
        return chart.getTransformer(YAxis.AxisDependency.Left).valueForTouchPoint(x: x, y: y)
    }
    
    /// - returns: The corresponding ChartHighlight for a given x-value and xy-touch position in pixels.
    /// - parameter xValue:
    /// - parameter x:
    /// - parameter y:
    /// - returns:
    public func getHighlight(xValue xVal: Double, x: CGFloat, y: CGFloat) -> Highlight?
    {
        guard let chart = chart
            else { return nil }
        
        let closestValues = getHighlights(xValue: xVal, x: x, y: y)
        if closestValues.isEmpty
        {
            return nil
        }
        
        let leftAxisMinDist = getMinimumDistance(closestValues, y: y, axis: YAxis.AxisDependency.Left)
        let rightAxisMinDist = getMinimumDistance(closestValues, y: y, axis: YAxis.AxisDependency.Right)
        
        let axis = leftAxisMinDist < rightAxisMinDist ? YAxis.AxisDependency.Left : YAxis.AxisDependency.Right
        
        let detail = closestSelectionDetailByPixel(closestValues: closestValues, x: x, y: y, axis: axis, minSelectionDistance: chart.maxHighlightDistance)
        
        return detail
    }
    
    /// - returns: A list of Highlight objects representing the entries closest to the given xVal.
    /// The returned list contains two objects per DataSet (closest rounding up, closest rounding down).
    /// - parameter xValue: the transformed x-value of the x-touch position
    /// - parameter x: touch position
    /// - parameter y: touch position
    /// - returns:
    public func getHighlights(xValue xValue: Double, x: CGFloat, y: CGFloat) -> [Highlight]
    {
        var vals = [Highlight]()
        
        guard let
            data = self.data
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
            
            if let high = buildHighlight(dataSet: dataSet, dataSetIndex: i, xValue: xValue, rounding: .Closest)
            {
                vals.append(high)
            }
        }
        
        return vals
    }
    
    /// - returns: The SelectionDetail object corresponding to the selected xValue and dataSetIndex.
    internal func buildHighlight(
        dataSet set: IChartDataSet,
        dataSetIndex: Int,
        xValue: Double,
        rounding: ChartDataSetRounding) -> Highlight?
    {
        guard let chart = self.chart as? BarLineScatterCandleBubbleChartDataProvider
            else { return nil }
        
        if let e = set.entryForXValue(xValue, rounding: rounding)
        {
            let px = chart.getTransformer(set.axisDependency).pixelForValues(x: e.x, y: e.y)
            
            return Highlight(x: e.x, y: e.y, xPx: px.x, yPx: px.y, dataSetIndex: dataSetIndex, axis: set.axisDependency)
        }
        
        return nil
    }

    // - MARK: - Utilities
    
    /// - returns: The `ChartHighlight` of the closest value on the x-y cartesian axes
    internal func closestSelectionDetailByPixel(
        closestValues closestValues: [Highlight],
                    x: CGFloat,
                    y: CGFloat,
                    axis: YAxis.AxisDependency?,
                    minSelectionDistance: CGFloat) -> Highlight?
    {
        var distance = minSelectionDistance
        var closest: Highlight?
        
        for i in 0 ..< closestValues.count
        {
            let high = closestValues[i]
            
            if axis == nil || high.axis == axis
            {
                let cDistance = getDistance(x1: x, y1: y, x2: high.xPx, y2: high.yPx)
                
                if cDistance < distance
                {
                    closest = high
                    distance = cDistance
                }
            }
        }
        
        return closest
    }
    
    /// - returns: The minimum distance from a touch-y-value (in pixels) to the closest y-value (in pixels) that is displayed in the chart.
    internal func getMinimumDistance(
        closestValues: [Highlight],
        y: CGFloat,
        axis: YAxis.AxisDependency) -> CGFloat
    {
        var distance = CGFloat.max
        
        for i in 0 ..< closestValues.count
        {
            let high = closestValues[i]
            
            if high.axis == axis
            {
                let tempDistance = abs(getHighlightPos(high: high) - y)
                if tempDistance < distance
                {
                    distance = tempDistance
                }
            }
        }
        
        return distance
    }
    
    internal func getHighlightPos(high high: Highlight) -> CGFloat
    {
        return high.yPx
    }
    
    internal func getDistance(x1 x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat
    {
        return hypot(x1 - x2, y1 - y2)
    }
    
    internal var data: ChartData?
    {
        return chart?.data
    }
}
