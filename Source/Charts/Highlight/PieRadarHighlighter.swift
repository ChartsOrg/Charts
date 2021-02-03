//
//  PieRadarHighlighter.swift
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

open class PieRadarHighlighter: ChartHighlighter {
    override open func getHighlight(x: CGFloat, y: CGFloat) -> Highlight? {
        guard let chart = self.chart as? PieRadarChartViewBase else { return nil }

        let touchDistanceToCenter = chart.distanceToCenter(x: x, y: y)

        // check if a slice was touched
        guard touchDistanceToCenter <= chart.radius else {
            // if no slice was touched, highlight nothing
            return nil
        }

        var angle = chart.angleForPoint(x: x, y: y)

        if chart is PieChartView {
            angle /= CGFloat(chart.chartAnimator.phaseY)
        }

        // check if the index could be found
        guard let index = chart.indexForAngle(angle),
              index >= 0,
              index < chart.data?.maxEntryCountSet?.count ?? 0
        else {
            return nil
        }

        return closestHighlight(index: index, x: x, y: y)
    }

    /// - Parameters:
    ///   - index:
    ///   - x:
    ///   - y:
    /// - Returns: The closest Highlight object of the given objects based on the touch position inside the chart.
    open func closestHighlight(index _: Int, x _: CGFloat, y _: CGFloat) -> Highlight? {
        fatalError("closestHighlight(index, x, y) cannot be called on PieRadarChartHighlighter")
    }
}
