//
//  RadarChartView.swift
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

/// Implementation of the RadarChart, a "spidernet"-like chart. It works best
/// when displaying 5-10 entries per DataSet.
open class RadarChartView: PieRadarChartViewBase {
    /// width of the web lines that come from the center.
    open var webLineWidth = CGFloat(1.5)

    /// width of the web lines that are in between the lines coming from the center
    open var innerWebLineWidth = CGFloat(0.75)

    /// color for the web lines that come from the center
    open var webColor = NSUIColor(red: 122 / 255.0, green: 122 / 255.0, blue: 122.0 / 255.0, alpha: 1.0)

    /// color for the web lines in between the lines that come from the center.
    open var innerWebColor = NSUIColor(red: 122 / 255.0, green: 122 / 255.0, blue: 122.0 / 255.0, alpha: 1.0)

    /// transparency the grid is drawn with (0.0 - 1.0)
    open var webAlpha: CGFloat = 150.0 / 255.0

    /// flag indicating if the web lines should be drawn or not
    open var drawWeb = true

    /// modulus that determines how many labels and web-lines are skipped before the next is drawn
    private var _skipWebLineCount = 0

    /// the object reprsenting the y-axis labels
    private var _yAxis: YAxis!

    internal var _yAxisRenderer: YAxisRendererRadarChart!
    internal var _xAxisRenderer: XAxisRendererRadarChart!

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override internal func initialize() {
        super.initialize()

        _yAxis = YAxis(position: .left)
        _yAxis.labelXOffset = 10.0

        renderer = RadarChartRenderer(chart: self, animator: chartAnimator, viewPortHandler: viewPortHandler)

        _yAxisRenderer = YAxisRendererRadarChart(viewPortHandler: viewPortHandler, axis: _yAxis, chart: self)
        _xAxisRenderer = XAxisRendererRadarChart(viewPortHandler: viewPortHandler, axis: xAxis, chart: self)

        highlighter = RadarHighlighter(chart: self)
    }

    override internal func calcMinMax() {
        super.calcMinMax()

        guard let data = data else { return }

        _yAxis.calculate(min: data.getYMin(axis: .left), max: data.getYMax(axis: .left))
        xAxis.calculate(min: 0.0, max: Double(data.maxEntryCountSet?.count ?? 0))
    }

    override open func notifyDataSetChanged() {
        calcMinMax()

        _yAxisRenderer?.computeAxis(min: _yAxis._axisMinimum, max: _yAxis._axisMaximum, inverted: _yAxis.isInverted)
        _xAxisRenderer?.computeAxis(min: xAxis._axisMinimum, max: xAxis._axisMaximum, inverted: false)

        if let data = data,
           !legend.isLegendCustom
        {
            legendRenderer.computeLegend(data: data)
        }

        calculateOffsets()

        setNeedsDisplay()
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)

        guard data != nil, let renderer = renderer else { return }

        let optionalContext = NSUIGraphicsGetCurrentContext()
        guard let context = optionalContext else { return }

        if xAxis.isEnabled {
            _xAxisRenderer.computeAxis(min: xAxis._axisMinimum, max: xAxis._axisMaximum, inverted: false)
        }

        _xAxisRenderer?.renderAxisLabels(context: context)

        if drawWeb {
            renderer.drawExtras(context: context)
        }

        if _yAxis.isEnabled && _yAxis.isDrawLimitLinesBehindDataEnabled {
            _yAxisRenderer.renderLimitLines(context: context)
        }

        renderer.drawData(context: context)

        if valuesToHighlight() {
            renderer.drawHighlighted(context: context, indices: highlighted)
        }

        if _yAxis.isEnabled && !_yAxis.isDrawLimitLinesBehindDataEnabled {
            _yAxisRenderer.renderLimitLines(context: context)
        }

        _yAxisRenderer.renderAxisLabels(context: context)

        renderer.drawValues(context: context)

        legendRenderer.renderLegend(context: context)

        drawDescription(in: context)

        drawMarkers(context: context)
    }

    /// The factor that is needed to transform values into pixels.
    open var factor: CGFloat {
        let content = viewPortHandler.contentRect
        return min(content.width / 2.0, content.height / 2.0)
            / CGFloat(_yAxis.axisRange)
    }

    /// The angle that each slice in the radar chart occupies.
    open var sliceAngle: CGFloat {
        return 360.0 / CGFloat(data?.maxEntryCountSet?.count ?? 0)
    }

    override open func indexForAngle(_ angle: CGFloat) -> Int? {
        // take the current angle of the chart into consideration
        let a = (angle - rotationAngle).normalizedAngle

        let sliceAngle = self.sliceAngle

        let max = data?.maxEntryCountSet?.count ?? 0
        return (0..<max).firstIndex {
            sliceAngle * CGFloat($0 + 1) - sliceAngle / 2.0 > a
        } ?? 0
    }

    /// The object that represents all y-labels of the RadarChart.
    open var yAxis: YAxis {
        return _yAxis
    }

    /// Sets the number of web-lines that should be skipped on chart web before the next one is drawn. This targets the lines that come from the center of the RadarChart.
    /// if count = 1 -> 1 line is skipped in between
    open var skipWebLineCount: Int {
        get {
            return _skipWebLineCount
        }
        set {
            _skipWebLineCount = max(0, newValue)
        }
    }

    override internal var requiredLegendOffset: CGFloat {
        return legend.font.pointSize * 4.0
    }

    override internal var requiredBaseOffset: CGFloat {
        return xAxis.isEnabled && xAxis.isDrawLabelsEnabled ? xAxis.labelRotatedWidth : 10.0
    }

    override open var radius: CGFloat {
        let content = viewPortHandler.contentRect
        return min(content.width / 2.0, content.height / 2.0)
    }

    /// The maximum value this chart can display on it's y-axis.
    override open var chartYMax: Double { return _yAxis._axisMaximum }

    /// The minimum value this chart can display on it's y-axis.
    override open var chartYMin: Double { return _yAxis._axisMinimum }

    /// The range of y-values this chart can display.
    open var yRange: Double { return _yAxis.axisRange }
}
