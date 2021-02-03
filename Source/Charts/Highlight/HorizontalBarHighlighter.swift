//
//  HorizontalBarHighlighter.swift
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

open class HorizontalBarHighlighter: BarHighlighter {
    override open func getHighlight(x: CGFloat, y: CGFloat) -> Highlight? {
        guard let barData = chart?.data as? BarChartData else { return nil }

        let pos = getValsForTouch(x: y, y: x)
        guard let high = getHighlight(xValue: Double(pos.y), x: y, y: x) else { return nil }

        if let set = barData[high.dataSetIndex] as? BarChartDataSet,
           set.isStacked
        {
            return getStackedHighlight(high: high,
                                       set: set,
                                       xValue: Double(pos.y),
                                       yValue: Double(pos.x))
        }

        return high
    }

    override internal func buildHighlights(
        dataSet set: ChartDataSet,
        dataSetIndex: Int,
        xValue: Double,
        rounding: ChartDataSetRounding
    ) -> [Highlight] {
        guard let chart = self.chart as? BarLineScatterCandleBubbleChartDataProvider else { return [] }

        var entries = set.entriesForXValue(xValue)
        if entries.isEmpty, let closest = set.entryForXValue(xValue, closestToY: .nan, rounding: rounding)
        {
            // Try to find closest x-value and take all entries for that x-value
            entries = set.entriesForXValue(closest.x)
        }

        return entries.map { e in
            let px = chart.getTransformer(forAxis: set.axisDependency)
                .pixelForValues(x: e.y, y: e.x)
            return Highlight(x: e.x, y: e.y, xPx: px.x, yPx: px.y, dataSetIndex: dataSetIndex, axis: set.axisDependency)
        }
    }

    override internal func getDistance(x1 _: CGFloat, y1: CGFloat, x2 _: CGFloat, y2: CGFloat) -> CGFloat
    {
        return abs(y1 - y2)
    }
}
