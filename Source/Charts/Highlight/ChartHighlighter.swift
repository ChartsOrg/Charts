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

open class ChartHighlighter : NSObject, IHighlighter
{
    /// instance of the data-provider
    open weak var chart: ChartDataProvider?
    
    public init(chart: ChartDataProvider)
    {
        self.chart = chart
    }
    
    open func getHighlight(x: CGFloat, y: CGFloat) -> Highlight?
    {
        let xVal = Double(getValsForTouch(x: x, y: y).x)
        
        return getHighlight(xValue: xVal, x: x, y: y)
    }
    
    /// - returns: The corresponding x-pos for a given touch-position in pixels.
    /// - parameter x:
    /// - returns:
    open func getValsForTouch(x: CGFloat, y: CGFloat) -> CGPoint
    {
        guard let chart = self.chart as? BarLineScatterCandleBubbleChartDataProvider
            else { return CGPoint.zero }
        
        // take any transformer to determine the values
        return chart.getTransformer(forAxis: YAxis.AxisDependency.left).valueForTouchPoint(x: x, y: y)
    }
    
    /// - returns: The corresponding ChartHighlight for a given x-value and xy-touch position in pixels.
    /// - parameter xValue:
    /// - parameter x:
    /// - parameter y:
    /// - returns:
    open func getHighlight(xValue xVal: Double, x: CGFloat, y: CGFloat) -> Highlight?
    {
        guard let chart = chart
            else { return nil }
        
        let closestValues = getHighlights(xValue: xVal, x: x, y: y)
        if closestValues.isEmpty
        {
            return nil
        }
        
        let leftAxisMinDist = getMinimumDistance(closestValues: closestValues, y: y, axis: YAxis.AxisDependency.left)
        let rightAxisMinDist = getMinimumDistance(closestValues: closestValues, y: y, axis: YAxis.AxisDependency.right)
        
        let axis = leftAxisMinDist < rightAxisMinDist ? YAxis.AxisDependency.left : YAxis.AxisDependency.right
        
        let detail = closestSelectionDetailByPixel(closestValues: closestValues, x: x, y: y, axis: axis, minSelectionDistance: chart.maxHighlightDistance)
        
        return detail
    }
    
    /// - returns: A list of Highlight objects representing the entries closest to the given xVal.
    /// The returned list contains two objects per DataSet (closest rounding up, closest rounding down).
    /// - parameter xValue: the transformed x-value of the x-touch position
    /// - parameter x: touch position
    /// - parameter y: touch position
    /// - returns:
    open func getHighlights(xValue: Double, x: CGFloat, y: CGFloat) -> [Highlight]
    {
        var vals = [Highlight]()
        
        guard let
            data = self.data
            else { return vals }
        
        for i in 0 ..< data.dataSetCount
        {
            guard let dataSet = data.getDataSetByIndex(i)
                else { continue }
            
            // don't include datasets that cannot be highlighted
            if !dataSet.isHighlightEnabled
            {
                continue
            }
            
            // extract all y-values from all DataSets at the given x-value.
            // some datasets (i.e bubble charts) make sense to have multiple values for an x-value. We'll have to find a way to handle that later on. It's more complicated now when x-indices are floating point.
            
            vals.append(contentsOf: buildHighlights(dataSet: dataSet, dataSetIndex: i, xValue: xValue, rounding: .closest))
        }
        
        return vals
    }
    
    /// - returns: An array of `Highlight` objects corresponding to the selected xValue and dataSetIndex.
    internal func buildHighlights(
        dataSet set: IChartDataSet,
        dataSetIndex: Int,
        xValue: Double,
        rounding: ChartDataSetRounding) -> [Highlight]
    {
        var highlights = [Highlight]()
        
        guard let chart = self.chart as? BarLineScatterCandleBubbleChartDataProvider
            else { return highlights }
        
        var entries = set.entriesForXValue(xValue)
        if entries.count == 0
        {
            // Try to find closest x-value and take all entries for that x-value
            if let closest = set.entryForXValue(xValue, closestToY: Double.nan, rounding: rounding)
            {
                entries = set.entriesForXValue(closest.x)
            }
        }
        
        for e in entries
        {
            let px = chart.getTransformer(forAxis: set.axisDependency).pixelForValues(x: e.x, y: e.y)
            
            highlights.append(Highlight(x: e.x, y: e.y, xPx: px.x, yPx: px.y, dataSetIndex: dataSetIndex, axis: set.axisDependency))
        }
        
        return highlights
    }

    // - MARK: - Utilities
    
    /// - returns: The `ChartHighlight` of the closest value on the x-y cartesian axes
    internal func closestSelectionDetailByPixel(
        closestValues: [Highlight],
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
        var distance = CGFloat.greatestFiniteMagnitude
        
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
    
    internal func getHighlightPos(high: Highlight) -> CGFloat
    {
        return high.yPx
    }
    
    internal func getDistance(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat
    {
        return hypot(x1 - x2, y1 - y2)
    }
    
    internal var data: ChartData?
    {
        return chart?.data
    }
}
