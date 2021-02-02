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

import CoreGraphics
import Foundation

open class BarHighlighter: ChartHighlighter {
    override open func getHighlight(x: CGFloat, y: CGFloat) -> Highlight? {
        guard
            let barData = (chart as? BarChartDataProvider)?.barData,
            let high = super.getHighlight(x: x, y: y)
        else { return nil }

        let pos = getValsForTouch(x: x, y: y)

        if let set = barData[high.dataSetIndex] as? BarChartDataSetProtocol,
           set.isStacked
        {
            return getStackedHighlight(high: high,
                                       set: set,
                                       xValue: Double(pos.x),
                                       yValue: Double(pos.y))
        } else {
            return high
        }
    }

    override internal func getDistance(x1: CGFloat, y1 _: CGFloat, x2: CGFloat, y2 _: CGFloat) -> CGFloat
    {
        return abs(x1 - x2)
    }

    override internal var data: ChartData? {
        return (chart as? BarChartDataProvider)?.barData
    }

    /// This method creates the Highlight object that also indicates which value of a stacked BarEntry has been selected.
    ///
    /// - Parameters:
    ///   - high: the Highlight to work with looking for stacked values
    ///   - set:
    ///   - xIndex:
    ///   - yValue:
    /// - Returns:
    open func getStackedHighlight(high: Highlight,
                                  set: BarChartDataSetProtocol,
                                  xValue: Double,
                                  yValue: Double) -> Highlight?
    {
        guard
            let chart = self.chart as? BarLineScatterCandleBubbleChartDataProvider,
            let entry = set.entryForXValue(xValue, closestToY: yValue) as? BarChartDataEntry
        else { return nil }

        // Not stacked
        if entry.yValues == nil {
            return high
        }

        guard
            let ranges = entry.ranges,
            !ranges.isEmpty
        else { return nil }

        let stackIndex = getClosestStackIndex(ranges: ranges, value: yValue)
        let pixel = chart
            .getTransformer(forAxis: set.axisDependency)
            .pixelForValues(x: high.x, y: ranges[stackIndex].to)

        return Highlight(x: entry.x,
                         y: entry.y,
                         xPx: pixel.x,
                         yPx: pixel.y,
                         dataSetIndex: high.dataSetIndex,
                         stackIndex: stackIndex,
                         axis: high.axis)
    }

    /// - Parameters:
    ///   - entry:
    ///   - value:
    /// - Returns: The index of the closest value inside the values array / ranges (stacked barchart) to the value given as a parameter.
    open func getClosestStackIndex(ranges: [Range]?, value: Double) -> Int {
        guard let ranges = ranges else { return 0 }

        if let stackIndex = ranges.firstIndex(where: { $0.contains(value) }) {
            return stackIndex
        } else {
            let length = max(ranges.endIndex - 1, 0)
            return (value > ranges[length].to) ? length : 0
        }
    }
}
