//
//  HorizontalBarChartView.swift
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

/// BarChart with horizontal bar orientation. In this implementation, x- and y-axis are switched.
open class HorizontalBarChartView: BarChartView {
    override internal func initialize() {
        super.initialize()

        _leftAxisTransformer = TransformerHorizontalBarChart(viewPortHandler: viewPortHandler)
        _rightAxisTransformer = TransformerHorizontalBarChart(viewPortHandler: viewPortHandler)

        renderer = HorizontalBarChartRenderer(dataProvider: self, animator: chartAnimator, viewPortHandler: viewPortHandler)
        leftYAxisRenderer = YAxisRendererHorizontalBarChart(viewPortHandler: viewPortHandler, axis: leftAxis, transformer: _leftAxisTransformer)
        rightYAxisRenderer = YAxisRendererHorizontalBarChart(viewPortHandler: viewPortHandler, axis: rightAxis, transformer: _rightAxisTransformer)
        xAxisRenderer = XAxisRendererHorizontalBarChart(viewPortHandler: viewPortHandler, axis: xAxis, transformer: _leftAxisTransformer, chart: self)

        highlighter = HorizontalBarHighlighter(chart: self)
    }

    override internal func calculateLegendOffsets(offsetLeft: inout CGFloat, offsetTop: inout CGFloat, offsetRight: inout CGFloat, offsetBottom: inout CGFloat)
    {
        guard
            legend.isEnabled,
            !legend.drawInside
        else { return }

        // setup offsets for legend
        switch legend.orientation {
        case .vertical:
            switch legend.horizontalAlignment {
            case .left:
                offsetLeft += min(legend.neededWidth, viewPortHandler.chartWidth * legend.maxSizePercent) + legend.xOffset

            case .right:
                offsetRight += min(legend.neededWidth, viewPortHandler.chartWidth * legend.maxSizePercent) + legend.xOffset

            case .center:

                switch legend.verticalAlignment {
                case .top:
                    offsetTop += min(legend.neededHeight, viewPortHandler.chartHeight * legend.maxSizePercent) + legend.yOffset

                case .bottom:
                    offsetBottom += min(legend.neededHeight, viewPortHandler.chartHeight * legend.maxSizePercent) + legend.yOffset

                default:
                    break
                }
            }

        case .horizontal:
            switch legend.verticalAlignment {
            case .top:
                offsetTop += min(legend.neededHeight, viewPortHandler.chartHeight * legend.maxSizePercent) + legend.yOffset

                // left axis equals the top x-axis in a horizontal chart
                if leftAxis.isEnabled, leftAxis.isDrawLabelsEnabled {
                    offsetTop += leftAxis.getRequiredHeightSpace()
                }

            case .bottom:
                offsetBottom += min(legend.neededHeight, viewPortHandler.chartHeight * legend.maxSizePercent) + legend.yOffset

                // right axis equals the bottom x-axis in a horizontal chart
                if rightAxis.isEnabled, rightAxis.isDrawLabelsEnabled {
                    offsetBottom += rightAxis.getRequiredHeightSpace()
                }
            default:
                break
            }
        }
    }

    override internal func calculateOffsets() {
        var offsetLeft: CGFloat = 0.0,
            offsetRight: CGFloat = 0.0,
            offsetTop: CGFloat = 0.0,
            offsetBottom: CGFloat = 0.0

        calculateLegendOffsets(offsetLeft: &offsetLeft,
                               offsetTop: &offsetTop,
                               offsetRight: &offsetRight,
                               offsetBottom: &offsetBottom)

        // offsets for y-labels
        if leftAxis.needsOffset {
            offsetTop += leftAxis.getRequiredHeightSpace()
        }

        if rightAxis.needsOffset {
            offsetBottom += rightAxis.getRequiredHeightSpace()
        }

        let xlabelwidth = xAxis.labelRotatedWidth

        if xAxis.isEnabled {
            // offsets for x-labels
            if xAxis.labelPosition == .bottom {
                offsetLeft += xlabelwidth
            } else if xAxis.labelPosition == .top {
                offsetRight += xlabelwidth
            } else if xAxis.labelPosition == .bothSided {
                offsetLeft += xlabelwidth
                offsetRight += xlabelwidth
            }
        }

        offsetTop += extraTopOffset
        offsetRight += extraRightOffset
        offsetBottom += extraBottomOffset
        offsetLeft += extraLeftOffset

        viewPortHandler.restrainViewPort(
            offsetLeft: max(minOffset, offsetLeft),
            offsetTop: max(minOffset, offsetTop),
            offsetRight: max(minOffset, offsetRight),
            offsetBottom: max(minOffset, offsetBottom)
        )

        prepareOffsetMatrix()
        prepareValuePxMatrix()
    }

    override internal func prepareValuePxMatrix() {
        _rightAxisTransformer.prepareMatrixValuePx(chartXMin: rightAxis._axisMinimum, deltaX: CGFloat(rightAxis.axisRange), deltaY: CGFloat(xAxis.axisRange), chartYMin: xAxis._axisMinimum)
        _leftAxisTransformer.prepareMatrixValuePx(chartXMin: leftAxis._axisMinimum, deltaX: CGFloat(leftAxis.axisRange), deltaY: CGFloat(xAxis.axisRange), chartYMin: xAxis._axisMinimum)
    }

    override open func getMarkerPosition(highlight: Highlight) -> CGPoint {
        return CGPoint(x: highlight.drawY, y: highlight.drawX)
    }

    override open func getBarBounds(entry e: BarChartDataEntry) -> CGRect {
        guard
            let data = data as? BarChartData,
            let set = data.getDataSetForEntry(e) as? BarChartDataSet
        else { return .null }

        let y = e.y
        let x = e.x

        let barWidth = data.barWidth

        let top = x - 0.5 + barWidth / 2.0
        let bottom = x + 0.5 - barWidth / 2.0
        let left = y >= 0.0 ? y : 0.0
        let right = y <= 0.0 ? y : 0.0

        var bounds = CGRect(x: left, y: top, width: right - left, height: bottom - top)

        getTransformer(forAxis: set.axisDependency).rectValueToPixel(&bounds)

        return bounds
    }

    override open func getPosition(entry e: ChartDataEntry, axis: YAxis.AxisDependency) -> CGPoint {
        var vals = CGPoint(x: CGFloat(e.y), y: CGFloat(e.x))

        getTransformer(forAxis: axis).pointValueToPixel(&vals)

        return vals
    }

    override open func getHighlightByTouchPoint(_ pt: CGPoint) -> Highlight? {
        if data === nil {
            Swift.print("Can't select by touch. No data set.", terminator: "\n")
            return nil
        }

        return highlighter?.getHighlight(x: pt.y, y: pt.x)
    }

    /// The lowest x-index (value on the x-axis) that is still visible on he chart.
    override open var lowestVisibleX: Double {
        var pt = CGPoint(
            x: viewPortHandler.contentLeft,
            y: viewPortHandler.contentBottom
        )

        getTransformer(forAxis: .left).pixelToValues(&pt)

        return max(xAxis._axisMinimum, Double(pt.y))
    }

    /// The highest x-index (value on the x-axis) that is still visible on the chart.
    override open var highestVisibleX: Double {
        var pt = CGPoint(
            x: viewPortHandler.contentLeft,
            y: viewPortHandler.contentTop
        )

        getTransformer(forAxis: .left).pixelToValues(&pt)

        return min(xAxis._axisMaximum, Double(pt.y))
    }

    // MARK: - Viewport

    override open func setVisibleXRangeMaximum(_ maxXRange: Double) {
        let xScale = xAxis.axisRange / maxXRange
        viewPortHandler.setMinimumScaleY(CGFloat(xScale))
    }

    override open func setVisibleXRangeMinimum(_ minXRange: Double) {
        let xScale = xAxis.axisRange / minXRange
        viewPortHandler.setMaximumScaleY(CGFloat(xScale))
    }

    override open func setVisibleXRange(minXRange: Double, maxXRange: Double) {
        let minScale = xAxis.axisRange / minXRange
        let maxScale = xAxis.axisRange / maxXRange
        viewPortHandler.setMinMaxScaleY(minScaleY: CGFloat(minScale), maxScaleY: CGFloat(maxScale))
    }

    override open func setVisibleYRangeMaximum(_ maxYRange: Double, axis: YAxis.AxisDependency) {
        let yScale = getAxisRange(axis: axis) / maxYRange
        viewPortHandler.setMinimumScaleX(CGFloat(yScale))
    }

    override open func setVisibleYRangeMinimum(_ minYRange: Double, axis: YAxis.AxisDependency) {
        let yScale = getAxisRange(axis: axis) / minYRange
        viewPortHandler.setMaximumScaleX(CGFloat(yScale))
    }

    override open func setVisibleYRange(minYRange: Double, maxYRange: Double, axis: YAxis.AxisDependency)
    {
        let minScale = getAxisRange(axis: axis) / minYRange
        let maxScale = getAxisRange(axis: axis) / maxYRange
        viewPortHandler.setMinMaxScaleX(minScaleX: CGFloat(minScale), maxScaleX: CGFloat(maxScale))
    }
}
