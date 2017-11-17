//
//  BarLineScatterCandleBubbleRenderer.swift
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

/// Class representing the bounds of the current viewport in terms of indices in the values array of a DataSet.
extension CountableClosedRange where Bound == Int {
    init(chart: BarLineScatterCandleBubbleChartDataProvider,
         dataSet: IBarLineScatterCandleBubbleChartDataSet,
         animator: Animator?) {

        let low = chart.lowestVisibleX
        let high = chart.highestVisibleX

        let entryFrom = dataSet.entryForXValue(low, closestToY: Double.nan, rounding: ChartDataSetRounding.down)
        let entryTo = dataSet.entryForXValue(high, closestToY: Double.nan, rounding: ChartDataSetRounding.up)

        self.lowerBound = entryFrom == nil ? 0 : dataSet.entryIndex(entry: entryFrom!)
        self.upperBound = entryTo == nil ? 0 : dataSet.entryIndex(entry: entryTo!)
    }
}

protocol BarLineScatterCandleBubbleRenderer: DataRenderer {
    typealias XBounds = CountableClosedRange<Int>

    var xBounds: XBounds! { get set }
}

extension BarLineScatterCandleBubbleRenderer {
    // TODO: Add back in when objc support is dropped
//    public func isDrawingValuesAllowed(dataProvider: ChartDataProvider?) -> Bool
//    {
//        guard let data = dataProvider?.data else { return false }
//        return data.entryCount < Int(CGFloat(dataProvider?.maxVisibleCount ?? 0) * viewPortHandler.scaleX)
//    }

    /// Checks if the provided entry object is in bounds for drawing considering the current animation phase.
    public func isInBoundsX(entry e: ChartDataEntry, dataSet: IBarLineScatterCandleBubbleChartDataSet) -> Bool
    {
        let entryIndex = dataSet.entryIndex(entry: e)

        if Double(entryIndex) >= Double(dataSet.entryCount) * (animator?.phaseX ?? 1.0)
        {
            return false
        }
        else
        {
            return true
        }
    }

    /// Calculates and returns the x-bounds for the given DataSet in terms of index in their values array.
    /// This includes minimum and maximum visible x, as well as range.
    func xBounds(chart: BarLineScatterCandleBubbleChartDataProvider,
                 dataSet: IBarLineScatterCandleBubbleChartDataSet,
                 animator: Animator?) -> XBounds
    {
        return XBounds(chart: chart, dataSet: dataSet, animator: animator)
    }

    /// - returns: `true` if the DataSet values should be drawn, `false` if not.
    func shouldDrawValues(forDataSet set: IChartDataSet) -> Bool
    {
        return set.isVisible && (set.isDrawValuesEnabled || set.isDrawIconsEnabled)
    }
}
