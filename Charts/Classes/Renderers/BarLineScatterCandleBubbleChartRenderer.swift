//
//  BarLineScatterCandleBubbleChartRenderer.swift
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


public class BarLineScatterCandleBubbleChartRenderer: ChartDataRendererBase
{
    public override init(animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler?)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
    }
    
    /// Calculates and returns the x-bounds for the given DataSet in terms of index in their values array.
    /// This includes minimum and maximum visible x, as well as range.
    internal func xBounds(chart: BarLineScatterCandleBubbleChartDataProvider,
                          dataSet: IBarLineScatterCandleBubbleChartDataSet,
                          animator: ChartAnimator?) -> XBounds
    {
        return XBounds(chart: chart, dataSet: dataSet, animator: animator)
    }

    /// Class representing the bounds of the current viewport in terms of indices in the values array of a DataSet.
    public class XBounds
    {
        /// minimum visible entry index
        public let min: Int

        /// maximum visible entry index
        public let max: Int

        /// range of visible entry indices
        public let range: Int

        public init(chart: BarLineScatterCandleBubbleChartDataProvider,
                    dataSet: IBarLineScatterCandleBubbleChartDataSet,
                    animator: ChartAnimator?)
        {
            let phaseX = Swift.max(0.0, Swift.min(1.0, animator?.phaseX ?? 1.0))

            let low = chart.lowestVisibleX
            let high = chart.highestVisibleX

            let entryFrom = dataSet.entryForXPos(low, rounding: ChartDataSetRounding.Down)
            let entryTo = dataSet.entryForXPos(high, rounding: ChartDataSetRounding.Up)

            self.min = entryFrom == nil ? 0 : dataSet.entryIndex(entry: entryFrom!)
            self.max = entryTo == nil ? 0 : dataSet.entryIndex(entry: entryTo!)
            range = Int(Double(self.max - self.min) * phaseX)
        }
    }

}