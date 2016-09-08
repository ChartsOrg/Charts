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

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

/// BarChart with horizontal bar orientation. In this implementation, x- and y-axis are switched.
public class HorizontalBarChartView: BarChartView
{
    internal override func initialize()
    {
        super.initialize()
        
        _leftAxisTransformer = TransformerHorizontalBarChart(viewPortHandler: _viewPortHandler)
        _rightAxisTransformer = TransformerHorizontalBarChart(viewPortHandler: _viewPortHandler)
        
        renderer = HorizontalBarChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        _leftYAxisRenderer = YAxisRendererHorizontalBarChart(viewPortHandler: _viewPortHandler, yAxis: _leftAxis, transformer: _leftAxisTransformer)
        _rightYAxisRenderer = YAxisRendererHorizontalBarChart(viewPortHandler: _viewPortHandler, yAxis: _rightAxis, transformer: _rightAxisTransformer)
        _xAxisRenderer = XAxisRendererHorizontalBarChart(viewPortHandler: _viewPortHandler, xAxis: _xAxis, transformer: _leftAxisTransformer, chart: self)
        
        self.highlighter = HorizontalBarHighlighter(chart: self)
    }
    
    internal override func calculateOffsets()
    {
        var offsetLeft: CGFloat = 0.0,
        offsetRight: CGFloat = 0.0,
        offsetTop: CGFloat = 0.0,
        offsetBottom: CGFloat = 0.0
        
        calculateLegendOffsets(offsetLeft: &offsetLeft,
                               offsetTop: &offsetTop,
                               offsetRight: &offsetRight,
                               offsetBottom: &offsetBottom)
        
        // offsets for y-labels
        if (_leftAxis.needsOffset)
        {
            offsetTop += _leftAxis.getRequiredHeightSpace()
        }
        
        if (_rightAxis.needsOffset)
        {
            offsetBottom += _rightAxis.getRequiredHeightSpace()
        }
        
        let xlabelwidth = _xAxis.labelRotatedWidth
        
        if (_xAxis.isEnabled)
        {
            // offsets for x-labels
            if (_xAxis.labelPosition == .Bottom)
            {
                offsetLeft += xlabelwidth
            }
            else if (_xAxis.labelPosition == .Top)
            {
                offsetRight += xlabelwidth
            }
            else if (_xAxis.labelPosition == .BothSided)
            {
                offsetLeft += xlabelwidth
                offsetRight += xlabelwidth
            }
        }
        
        offsetTop += self.extraTopOffset
        offsetRight += self.extraRightOffset
        offsetBottom += self.extraBottomOffset
        offsetLeft += self.extraLeftOffset
        
        _viewPortHandler.restrainViewPort(
            offsetLeft: max(self.minOffset, offsetLeft),
            offsetTop: max(self.minOffset, offsetTop),
            offsetRight: max(self.minOffset, offsetRight),
            offsetBottom: max(self.minOffset, offsetBottom))
        
        prepareOffsetMatrix()
        prepareValuePxMatrix()
    }
    
    internal override func prepareValuePxMatrix()
    {
        _rightAxisTransformer.prepareMatrixValuePx(chartXMin: _rightAxis._axisMinimum, deltaX: CGFloat(_rightAxis.axisRange), deltaY: CGFloat(_xAxis.axisRange), chartYMin: _xAxis._axisMinimum)
        _leftAxisTransformer.prepareMatrixValuePx(chartXMin: _leftAxis._axisMinimum, deltaX: CGFloat(_leftAxis.axisRange), deltaY: CGFloat(_xAxis.axisRange), chartYMin: _xAxis._axisMinimum)
    }
    
    public override func getMarkerPosition(highlight highlight: Highlight) -> CGPoint
    {
        return CGPoint(x: highlight.drawY, y: highlight.drawX)
    }
    
    public override func getBarBounds(e: BarChartDataEntry) -> CGRect
    {
        guard let
            data = _data as? BarChartData,
            set = data.getDataSetForEntry(e) as? IBarChartDataSet
            else { return CGRectNull }
        
        let y = e.y
        let x = e.x
        
        let barWidth = data.barWidth
        
        let top = x - 0.5 + barWidth / 2.0
        let bottom = x + 0.5 - barWidth / 2.0
        let left = y >= 0.0 ? y : 0.0
        let right = y <= 0.0 ? y : 0.0
        
        var bounds = CGRect(x: left, y: top, width: right - left, height: bottom - top)
        
        getTransformer(set.axisDependency).rectValueToPixel(&bounds)
        
        return bounds
    }
    
    public override func getPosition(e: ChartDataEntry, axis: YAxis.AxisDependency) -> CGPoint
    {
        var vals = CGPoint(x: CGFloat(e.y), y: CGFloat(e.x))
        
        getTransformer(axis).pointValueToPixel(&vals)
        
        return vals
    }

    public override func getHighlightByTouchPoint(pt: CGPoint) -> Highlight?
    {
        if _data === nil
        {
            Swift.print("Can't select by touch. No data set.", terminator: "\n")
            return nil
        }
        
        return self.highlighter?.getHighlight(x: pt.y, y: pt.x)
    }
    
    /// - returns: The lowest x-index (value on the x-axis) that is still visible on he chart.
    public override var lowestVisibleX: Double
    {
        var pt = CGPoint(
            x: viewPortHandler.contentLeft,
            y: viewPortHandler.contentBottom)
        
        getTransformer(.Left).pixelToValues(&pt)
        
        return max(xAxis._axisMinimum, Double(pt.y))
    }
    
    /// - returns: The highest x-index (value on the x-axis) that is still visible on the chart.
    public override var highestVisibleX: Double
    {
        var pt = CGPoint(
            x: viewPortHandler.contentLeft,
            y: viewPortHandler.contentTop)
        
        getTransformer(.Left).pixelToValues(&pt)
        
        return min(xAxis._axisMaximum, Double(pt.y))
    }
    
    // MARK: - Viewport
    
    public override func setVisibleXRangeMaximum(maxXRange: Double)
    {
        let xScale = xAxis.axisRange / maxXRange
        viewPortHandler.setMinimumScaleY(CGFloat(xScale))
    }
    
    public override func setVisibleXRangeMinimum(minXRange: Double)
    {
        let xScale = xAxis.axisRange / minXRange
        viewPortHandler.setMaximumScaleY(CGFloat(xScale))
    }
    
    public override func setVisibleXRange(minXRange minXRange: Double, maxXRange: Double)
    {
        let minScale = xAxis.axisRange / minXRange
        let maxScale = xAxis.axisRange / maxXRange
        viewPortHandler.setMinMaxScaleY(minScaleY: CGFloat(minScale), maxScaleY: CGFloat(maxScale))
    }
    
    public override func setVisibleYRangeMaximum(maxYRange: Double, axis: YAxis.AxisDependency)
    {
        let yScale = getAxisRange(axis) / maxYRange
        viewPortHandler.setMinimumScaleX(CGFloat(yScale))
    }
    
    public override func setVisibleYRangeMinimum(minYRange: Double, axis: YAxis.AxisDependency)
    {
        let yScale = getAxisRange(axis) / minYRange
        viewPortHandler.setMaximumScaleX(CGFloat(yScale))
    }
    
    public override func setVisibleYRange(minYRange minYRange: Double, maxYRange: Double, axis: YAxis.AxisDependency)
    {
        let minScale = getAxisRange(axis) / minYRange
        let maxScale = getAxisRange(axis) / maxYRange
        viewPortHandler.setMinMaxScaleX(minScaleX: CGFloat(minScale), maxScaleX: CGFloat(maxScale))
    }
}
