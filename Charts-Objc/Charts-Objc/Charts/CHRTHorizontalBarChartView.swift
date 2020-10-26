//
//  CHRTHorizontalBarChartView.swift
//  Charts-Objc
//
//  Created by Jacob Christie on 2020-10-26.
//

import Charts

@objc
@objcMembers
open class CHRTHorizontalBarChartView: Charts.HorizontalBarChartView {
    // MARK: - Properties

    open override var barData: BarChartData? {
        get { super.data as? BarChartData }
    }

    /// if set to true, all values are drawn above their bars, instead of below their top
    open override var drawValueAboveBarEnabled: Bool {
        get { super.drawValueAboveBarEnabled }
        set { super.drawValueAboveBarEnabled = newValue }
    }

    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    open override var drawBarShadowEnabled: Bool {
        get { super.drawBarShadowEnabled }
        set { super.drawBarShadowEnabled = newValue }
    }

    /// Adds half of the bar width to each side of the x-axis range in order to allow the bars of the barchart to be fully displayed.
    /// **default**: false
    open override var fitBars: Bool {
        get { super.fitBars }
        set { super.fitBars = newValue }
    }

    /// Set this to `true` to make the highlight operation full-bar oriented, `false` to make it highlight single values (relevant only for stacked).
    /// If enabled, highlighting operations will highlight the whole bar, even if only a single stack entry was tapped.
    open override var highlightFullBarEnabled: Bool {
        get { super.highlightFullBarEnabled }
        set { super.highlightFullBarEnabled = newValue }
    }

    open override var lowestVisibleX: Double {
        super.lowestVisibleX
    }

    open override var highestVisibleX: Double {
        super.highestVisibleX
    }

    // MARK: - Methods

    open override func getMarkerPosition(highlight: Highlight) -> CGPoint {
        super.getMarkerPosition(highlight: highlight)
    }

    open override func getBarBounds(entry e: BarChartDataEntry) -> CGRect {
        super.getBarBounds(entry: e)
    }

    open override func getPosition(
        entry e: ChartDataEntry,
        axis: YAxis.AxisDependency
    ) -> CGPoint {
        super.getPosition(entry: e, axis: axis)
    }

    open override func getHighlightByTouchPoint(_ pt: CGPoint) -> Highlight? {
        super.getHighlightByTouchPoint(pt)
    }

    // MARK: - Viewport

    open override func setVisibleXRangeMaximum(_ maxXRange: Double) {
        super.setVisibleXRangeMaximum(maxXRange)
    }

    open override func setVisibleXRangeMinimum(_ minXRange: Double) {
        super.setVisibleXRangeMinimum(minXRange)
    }

    open override func setVisibleXRange(minXRange: Double, maxXRange: Double) {
        super.setVisibleXRange(minXRange: minXRange, maxXRange: maxXRange)
    }

    open override func setVisibleYRangeMaximum(
        _ maxYRange: Double,
        axis: YAxis.AxisDependency
    ) {
        super.setVisibleYRangeMaximum(maxYRange, axis: axis)
    }

    open override func setVisibleYRangeMinimum(
        _ minYRange: Double,
        axis: YAxis.AxisDependency
    ) {
        super.setVisibleYRangeMinimum(minYRange, axis: axis)
    }

    open override func setVisibleYRange(
        minYRange: Double,
        maxYRange: Double,
        axis: YAxis.AxisDependency
    ) {
        super.setVisibleYRange(
            minYRange: minYRange,
            maxYRange: maxYRange,
            axis: axis
        )
    }
}
