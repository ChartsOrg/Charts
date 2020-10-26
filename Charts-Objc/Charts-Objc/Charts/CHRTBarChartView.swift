//
//  CHRTBarChartView.swift
//  Charts-Objc
//
//  Created by Jacob Christie on 2020-10-26.
//

import Charts

@objc
@objcMembers
open class CHRTBarChartView: Charts.BarChartView {
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

    // MARK: - Methods

    /// - Returns: The Highlight object (contains x-index and DataSet index) of the selected value at the given touch point inside the BarChart.
    open override func getHighlightByTouchPoint(_ pt: CGPoint) -> Highlight? {
        super.getHighlightByTouchPoint(pt)
    }

    /// - Returns: The bounding box of the specified Entry in the specified DataSet. Returns null if the Entry could not be found in the charts data.
    open override func getBarBounds(entry e: BarChartDataEntry) -> CGRect {
        super.getBarBounds(entry: e)
    }

    /// Groups all BarDataSet objects this data object holds together by modifying the x-value of their entries.
    /// Previously set x-values of entries will be overwritten. Leaves space between bars and groups as specified by the parameters.
    /// Calls `notifyDataSetChanged()` afterwards.
    ///
    /// - Parameters:
    ///   - fromX: the starting point on the x-axis where the grouping should begin
    ///   - groupSpace: the space between groups of bars in values (not pixels) e.g. 0.8f for bar width 1f
    ///   - barSpace: the space between individual bars in values (not pixels) e.g. 0.1f for bar width 1f
    open override func groupBars(
        fromX x: Double,
        groupSpace: Double,
        barSpace: Double
    ) {
        super.groupBars(fromX: x, groupSpace: groupSpace, barSpace: barSpace)
    }

    /// Highlights the value at the given x-value in the given DataSet. Provide -1 as the dataSetIndex to undo all highlighting.
    ///
    /// - Parameters:
    ///   - x:
    ///   - dataSetIndex:
    ///   - stackIndex: the index inside the stack - only relevant for stacked entries
    open override func highlightValue(
        x: Double,
        dataSetIndex: Int,
        stackIndex: Int
    ) {
        super.highlightValue(
            x: x,
            dataSetIndex: dataSetIndex,
            stackIndex: stackIndex
        )
    }
}
