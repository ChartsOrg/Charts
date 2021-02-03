//
//  BarChartData.swift
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

open class BarChartData: BarLineScatterCandleBubbleChartData {
    public required init() {
        super.init()
    }

    override public init(dataSets: [ChartDataSet]) {
        super.init(dataSets: dataSets)
    }

    public required init(arrayLiteral elements: ChartDataSet...) {
        super.init(dataSets: elements)
    }

    /// The width of the bars on the x-axis, in values (not pixels)
    ///
    /// **default**: 0.85
    open var barWidth = Double(0.85)

    /// Groups all BarDataSet objects this data object holds together by modifying the x-value of their entries.
    /// Previously set x-values of entries will be overwritten. Leaves space between bars and groups as specified by the parameters.
    /// Do not forget to call notifyDataSetChanged() on your BarChart object after calling this method.
    ///
    /// - Parameters:
    ///   - fromX: the starting point on the x-axis where the grouping should begin
    ///   - groupSpace: The space between groups of bars in values (not pixels) e.g. 0.8f for bar width 1f
    ///   - barSpace: The space between individual bars in values (not pixels) e.g. 0.1f for bar width 1f
    open func groupBars(fromX: Double, groupSpace: Double, barSpace: Double) {
        guard !isEmpty, let max = maxEntryCountSet else {
            print("BarData needs to hold at least 2 BarDataSets to allow grouping.", terminator: "\n")
            return
        }

        let groupSpaceWidthHalf = groupSpace / 2.0
        let barSpaceHalf = barSpace / 2.0
        let barWidthHalf = barWidth / 2.0

        var fromX = fromX

        let interval = groupWidth(groupSpace: groupSpace, barSpace: barSpace)

        for i in max.indices {
            let start = fromX
            fromX += groupSpaceWidthHalf

            (_dataSets as! [BarChartDataSet]).forEach { set in
                fromX += barSpaceHalf
                fromX += barWidthHalf

                if set.indices.contains(i) {
                    set[i].x = fromX
                }

                fromX += barWidthHalf
                fromX += barSpaceHalf
            }

            fromX += groupSpaceWidthHalf
            let end = fromX
            let innerInterval = end - start
            let diff = interval - innerInterval

            // correct rounding errors
            if diff > 0 || diff < 0 {
                fromX += diff
            }
        }

        notifyDataChanged()
    }

    /// In case of grouped bars, this method returns the space an individual group of bar needs on the x-axis.
    ///
    /// - Parameters:
    ///   - groupSpace:
    ///   - barSpace:
    open func groupWidth(groupSpace: Double, barSpace: Double) -> Double {
        return Double(count) * (barWidth + barSpace) + groupSpace
    }
}
