//
//  CombinedChartView.swift
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

/// This chart class allows the combination of lines, bars, scatter and candle data all displayed in one chart area.
open class CombinedChartView: BarLineChartViewBase, CombinedChartDataProvider {
    /// the fill-formatter used for determining the position of the fill-line
    internal var _fillFormatter: FillFormatter!

    /// enum that allows to specify the order in which the different data objects for the combined-chart are drawn
    public enum DrawOrder: Int {
        case bar
        case bubble
        case line
        case candle
        case scatter
    }

    override open func initialize() {
        super.initialize()

        highlighter = CombinedHighlighter(chart: self, barDataProvider: self)

        // Old default behaviour
        highlightFullBarEnabled = true

        _fillFormatter = DefaultFillFormatter()

        renderer = CombinedChartRenderer(chart: self, animator: chartAnimator, viewPortHandler: viewPortHandler)
    }

    override open var data: ChartData? {
        get {
            return super.data
        }
        set {
            super.data = newValue

            self.highlighter = CombinedHighlighter(chart: self, barDataProvider: self)

            (renderer as? CombinedChartRenderer)?.createRenderers()
            renderer?.initBuffers()
        }
    }

    open var fillFormatter: FillFormatter {
        get {
            return _fillFormatter
        }
        set {
            _fillFormatter = newValue
            if _fillFormatter == nil {
                _fillFormatter = DefaultFillFormatter()
            }
        }
    }

    /// - Returns: The Highlight object (contains x-index and DataSet index) of the selected value at the given touch point inside the CombinedChart.
    override open func getHighlightByTouchPoint(_ pt: CGPoint) -> Highlight? {
        if data === nil {
            Swift.print("Can't select by touch. No data set.")
            return nil
        }

        guard let h = highlighter?.getHighlight(x: pt.x, y: pt.y)
        else { return nil }

        if !isHighlightFullBarEnabled { return h }

        // For isHighlightFullBarEnabled, remove stackIndex
        return Highlight(
            x: h.x, y: h.y,
            xPx: h.xPx, yPx: h.yPx,
            dataIndex: h.dataIndex,
            dataSetIndex: h.dataSetIndex,
            stackIndex: -1,
            axis: h.axis
        )
    }

    // MARK: - CombinedChartDataProvider

    open var combinedData: CombinedChartData? {
        return data as? CombinedChartData
    }

    // MARK: - LineChartDataProvider

    open var lineData: LineChartData? {
        return combinedData?.lineData
    }

    // MARK: - BarChartDataProvider

    open var barData: BarChartData? {
        return combinedData?.barData
    }

    // MARK: - ScatterChartDataProvider

    open var scatterData: ScatterChartData? {
        return combinedData?.scatterData
    }

    // MARK: - CandleChartDataProvider

    open var candleData: CandleChartData? {
        return combinedData?.candleData
    }

    // MARK: - BubbleChartDataProvider

    open var bubbleData: BubbleChartData? {
        return combinedData?.bubbleData
    }

    // MARK: - Accessors

    /// if set to true, all values are drawn above their bars, instead of below their top
    open var drawValueAboveBarEnabled: Bool {
        get { return (renderer as! CombinedChartRenderer).drawValueAboveBarEnabled }
        set { (renderer as! CombinedChartRenderer).drawValueAboveBarEnabled = newValue }
    }

    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    open var drawBarShadowEnabled: Bool {
        get { return (renderer as! CombinedChartRenderer).drawBarShadowEnabled }
        set { (renderer as! CombinedChartRenderer).drawBarShadowEnabled = newValue }
    }

    /// `true` if drawing values above bars is enabled, `false` ifnot
    open var isDrawValueAboveBarEnabled: Bool { return (renderer as! CombinedChartRenderer).drawValueAboveBarEnabled }

    /// `true` if drawing shadows (maxvalue) for each bar is enabled, `false` ifnot
    open var isDrawBarShadowEnabled: Bool { return (renderer as! CombinedChartRenderer).drawBarShadowEnabled }

    /// the order in which the provided data objects should be drawn.
    /// The earlier you place them in the provided array, the further they will be in the background.
    /// e.g. if you provide [DrawOrder.Bar, DrawOrder.Line], the bars will be drawn behind the lines.
    open var drawOrder: [Int] {
        get {
            return (renderer as! CombinedChartRenderer).drawOrder.map { $0.rawValue }
        }
        set {
            (renderer as! CombinedChartRenderer).drawOrder = newValue.map { DrawOrder(rawValue: $0)! }
        }
    }

    /// Set this to `true` to make the highlight operation full-bar oriented, `false` to make it highlight single values
    open var highlightFullBarEnabled: Bool = false

    /// `true` the highlight is be full-bar oriented, `false` ifsingle-value
    open var isHighlightFullBarEnabled: Bool { return highlightFullBarEnabled }

    // MARK: - ChartViewBase

    /// draws all MarkerViews on the highlighted positions
    override func drawMarkers(context: CGContext) {
        guard
            let marker = marker,
            isDrawMarkersEnabled, valuesToHighlight()
        else { return }

        for i in highlighted.indices {
            let highlight = highlighted[i]

            guard
                let set = combinedData?.getDataSetByHighlight(highlight),
                let e = data?.entry(for: highlight)
            else { continue }

            let entryIndex = set.entryIndex(entry: e)
            if entryIndex > Int(Double(set.entryCount) * chartAnimator.phaseX) {
                continue
            }

            let pos = getMarkerPosition(highlight: highlight)

            // check bounds
            if !viewPortHandler.isInBounds(x: pos.x, y: pos.y) {
                continue
            }

            // callbacks to update the content
            marker.refreshContent(entry: e, highlight: highlight)

            // draw the marker
            marker.draw(context: context, point: pos)
        }
    }
}
