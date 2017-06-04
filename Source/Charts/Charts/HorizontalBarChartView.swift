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
open class HorizontalBarChartView: BarChartView
{
    internal override func initialize()
    {
        super.initialize()
        
        _leftAxisTransformer = TransformerHorizontalBarChart(viewPortHandler: _viewPortHandler)
        _leftAxisTransformer1 = TransformerHorizontalBarChart(viewPortHandler: _viewPortHandler)
        
        _rightAxisTransformer = TransformerHorizontalBarChart(viewPortHandler: _viewPortHandler)
        _rightAxisTransformer1 = TransformerHorizontalBarChart(viewPortHandler: _viewPortHandler)
        
        renderer = HorizontalBarChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        
        _leftYAxisRenderer  = YAxisRendererHorizontalBarChart( viewPortHandler: _viewPortHandler, yAxis: _leftAxis,  transformer: _leftAxisTransformer)
        _leftYAxisRenderer1 = YAxisRendererHorizontalBarChart( viewPortHandler: _viewPortHandler, yAxis: _leftAxis1, transformer: _leftAxisTransformer1)
        
        _rightYAxisRenderer = YAxisRendererHorizontalBarChart(viewPortHandler: _viewPortHandler, yAxis: _rightAxis, transformer: _rightAxisTransformer)
        _rightYAxisRenderer1 = YAxisRendererHorizontalBarChart(viewPortHandler: _viewPortHandler, yAxis: _rightAxis1, transformer: _rightAxisTransformer1)
        
        _xAxisRenderer = XAxisRendererHorizontalBarChart(viewPortHandler: _viewPortHandler, xAxis: _xAxis, transformer: _leftAxisTransformer, chart: self)
        
        self.highlighter = HorizontalBarHighlighter(chart: self)
    }
    
    internal override func calculateOffsets()
    {
        var offsetLeft: CGFloat = 0.0,
        offsetRight: CGFloat = 0.0,
        offsetTop: CGFloat = 0.0,
        offsetBottom: CGFloat = 0.0
        
        offsetTop += self.extraTopOffset
        offsetRight += self.extraRightOffset
        offsetBottom += self.extraBottomOffset
        offsetLeft += self.extraLeftOffset
        
        var offsetLeftLegend = CGFloat(0.0)
        var offsetRightLegend = CGFloat(0.0)
        var offsetTopLegend = CGFloat(0.0)
        var offsetBottomLegend = CGFloat(0.0)
        
        calculateLegendOffsets(offsetLeft: &offsetLeftLegend,
                               offsetTop: &offsetTopLegend,
                               offsetRight: &offsetRightLegend,
                               offsetBottom: &offsetBottomLegend)
        
        let axisRectWidth = viewPortHandler.contentWidth
        let axisRectLeft = viewPortHandler.contentLeft
        
        let lineWidth : CGFloat = 1.0
        let stick : CGFloat = 5.0
        
        // offsets for y-labels
        // Space from top to bottom
        // offsetTop = offsetTopLegend + leftAxis1.axisRectTop.height + leftAxis.axisRectTop.height + leftAxis.yOffset
        
        // rect axis
        // 1 pixel  : line height
        // 5 pixels : stick
        // n pixels : label height
        // n pixels : name height
        offsetTop = offsetTopLegend
        var offsetTopTmp = offsetTop
        if leftAxis1.needsOffsetSecondary
        {
            offsetTop += lineWidth + stick + leftAxis1.getRequiredHeightSpaceSecondary()
            if leftAxis1.nameAxisEnabled
            {
                let nameAxisHeight = leftAxis.nameAxis.size(attributes: [NSFontAttributeName: leftAxis.nameAxisFont]).height
                offsetTop += nameAxisHeight
            }
            let height = offsetTop - offsetTopTmp
            leftAxis1.axisRectTop = CGRect(x: axisRectLeft,
                                           y: offsetTopTmp,
                                           width: axisRectWidth,
                                           height: height)
        }
        
        offsetTopTmp = offsetTop
        if leftAxis.needsOffset
        {
            offsetTop += lineWidth + stick + leftAxis.getRequiredHeightSpace()
            if leftAxis.nameAxisEnabled
            {
                let nameAxisHeight = leftAxis.nameAxis.size(attributes: [NSFontAttributeName: leftAxis.nameAxisFont]).height
                offsetTop += nameAxisHeight
            }
            let height = offsetTop - offsetTopTmp
            leftAxis.axisRectTop = CGRect(x: axisRectLeft,
                                          y: offsetTopTmp,
                                          width: axisRectWidth,
                                          height: height)
        }
        offsetTop += leftAxis.yOffset
        
        // Space from bottom to top
        offsetBottom = offsetBottomLegend
        var offsetBottomTmp = offsetBottom
        if rightAxis1.needsOffsetSecondary
        {
            offsetBottom += rightAxis1.getRequiredHeightSpaceSecondary()
            if rightAxis1.nameAxisEnabled
            {
                let nameAxisHeight = rightAxis1.nameAxis.size(attributes: [NSFontAttributeName: rightAxis1.nameAxisFont]).height
                offsetBottom += nameAxisHeight
            }
            let height = offsetBottom - offsetBottomTmp
            rightAxis1.axisRectBottom = CGRect(x: axisRectLeft,
                                               y: viewPortHandler.chartHeight - offsetBottom,
                                               width: axisRectWidth,
                                               height: height)
        }
        
        offsetBottomTmp = offsetBottom
        if rightAxis.needsOffset
        {
            offsetBottom += rightAxis.getRequiredHeightSpace()
            if rightAxis.nameAxisEnabled
            {
                let nameAxisHeight = rightAxis.nameAxis.size(attributes: [NSFontAttributeName: rightAxis.nameAxisFont]).height
                offsetBottom += nameAxisHeight
            }
            let height = offsetBottom - offsetBottomTmp
            rightAxis.axisRectBottom = CGRect(x: axisRectLeft,
                                              y: viewPortHandler.chartHeight - offsetBottom,
                                              width: axisRectWidth,
                                              height: height)
        }
        offsetBottom += leftAxis.yOffset
        
        let xlabelwidth = _xAxis.labelRotatedWidth
        if _xAxis.isEnabled
        {
            var namexAxisHeight = CGFloat(0.0)
            if xAxis.nameAxisEnabled
            {
                namexAxisHeight = xAxis.nameAxis.size(attributes: [NSFontAttributeName: xAxis.nameAxisFont]).height
            }
            
            // offsets for x-labels
            offsetLeft = offsetLeftLegend
            offsetRight = offsetRightLegend
            if _xAxis.labelPosition == .bottom
            {
                offsetLeft += xlabelwidth + namexAxisHeight
                xAxis.axisRectLeft = CGRect(x: offsetLeft - xlabelwidth - namexAxisHeight,
                                            y:viewPortHandler.contentTop,
                                            width: namexAxisHeight,
                                            height:viewPortHandler.contentHeight)
            }
            else if _xAxis.labelPosition == .top
            {
                offsetRight += xlabelwidth + namexAxisHeight
                xAxis.axisRectRight = CGRect(x: viewPortHandler.contentRight + xlabelwidth,
                                             y: viewPortHandler.contentTop,
                                             width: namexAxisHeight,
                                             height: viewPortHandler.contentHeight)
            }
            else if _xAxis.labelPosition == .bothSided
            {
                offsetLeft += xlabelwidth + namexAxisHeight
                xAxis.axisRectLeft = CGRect(x: offsetLeft - xlabelwidth - namexAxisHeight,
                                            y:viewPortHandler.contentTop,
                                            width: namexAxisHeight,
                                            height:viewPortHandler.contentHeight)
                
                offsetRight += xlabelwidth + namexAxisHeight
                xAxis.axisRectRight = CGRect(x: viewPortHandler.contentRight + xlabelwidth,
                                             y: viewPortHandler.contentTop,
                                             width: namexAxisHeight,
                                             height: viewPortHandler.contentHeight)
            }
        }
        
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
        _rightAxisTransformer1.prepareMatrixValuePx(chartXMin: _rightAxis1._axisMinimum, deltaX: CGFloat(_rightAxis1.axisRange), deltaY: CGFloat(_xAxis.axisRange), chartYMin: _xAxis._axisMinimum)
        
        _leftAxisTransformer.prepareMatrixValuePx(chartXMin: _leftAxis._axisMinimum, deltaX: CGFloat(_leftAxis.axisRange), deltaY: CGFloat(_xAxis.axisRange), chartYMin: _xAxis._axisMinimum)
        _leftAxisTransformer1.prepareMatrixValuePx(chartXMin: _leftAxis1._axisMinimum, deltaX: CGFloat(_leftAxis1.axisRange), deltaY: CGFloat(_xAxis.axisRange), chartYMin: _xAxis._axisMinimum)
    }
    
    open override func getMarkerPosition(highlight: Highlight) -> CGPoint
    {
        return CGPoint(x: highlight.drawY, y: highlight.drawX)
    }
    
    open override func getBarBounds(entry e: BarChartDataEntry) -> CGRect
    {
        guard
            let data = _data as? BarChartData,
            let set = data.getDataSetForEntry(e) as? IBarChartDataSet
            else { return CGRect.null }
        
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
    
    open override func getPosition(entry e: ChartDataEntry, axis: YAxis.AxisDependency) -> CGPoint
    {
        var vals = CGPoint(x: CGFloat(e.y), y: CGFloat(e.x))
        
        getTransformer(forAxis: axis).pointValueToPixel(&vals)
        
        return vals
    }
    
    open override func getHighlightByTouchPoint(_ pt: CGPoint) -> Highlight?
    {
        if _data === nil
        {
            Swift.print("Can't select by touch. No data set.", terminator: "\n")
            return nil
        }
        
        return self.highlighter?.getHighlight(x: pt.y, y: pt.x)
    }
    
    /// - returns: The lowest x-index (value on the x-axis) that is still visible on he chart.
    open override var lowestVisibleX: Double
    {
        var pt = CGPoint(
            x: viewPortHandler.contentLeft,
            y: viewPortHandler.contentBottom)
        
        getTransformer(forAxis: .left).pixelToValues(&pt)
        
        return max(xAxis._axisMinimum, Double(pt.y))
    }
    
    /// - returns: The highest x-index (value on the x-axis) that is still visible on the chart.
    open override var highestVisibleX: Double
    {
        var pt = CGPoint(
            x: viewPortHandler.contentLeft,
            y: viewPortHandler.contentTop)
        
        getTransformer(forAxis: .left).pixelToValues(&pt)
        
        return min(xAxis._axisMaximum, Double(pt.y))
    }
    
    // MARK: - Viewport
    
    open override func setVisibleXRangeMaximum(_ maxXRange: Double)
    {
        let xScale = xAxis.axisRange / maxXRange
        viewPortHandler.setMinimumScaleY(CGFloat(xScale))
    }
    
    open override func setVisibleXRangeMinimum(_ minXRange: Double)
    {
        let xScale = xAxis.axisRange / minXRange
        viewPortHandler.setMaximumScaleY(CGFloat(xScale))
    }
    
    open override func setVisibleXRange(minXRange: Double, maxXRange: Double)
    {
        let minScale = xAxis.axisRange / minXRange
        let maxScale = xAxis.axisRange / maxXRange
        viewPortHandler.setMinMaxScaleY(minScaleY: CGFloat(minScale), maxScaleY: CGFloat(maxScale))
    }
    
    open override func setVisibleYRangeMaximum(_ maxYRange: Double, axis: YAxis.AxisDependency)
    {
        let yScale = getAxisRange(axis: axis) / maxYRange
        viewPortHandler.setMinimumScaleX(CGFloat(yScale))
    }
    
    open override func setVisibleYRangeMinimum(_ minYRange: Double, axis: YAxis.AxisDependency)
    {
        let yScale = getAxisRange(axis: axis) / minYRange
        viewPortHandler.setMaximumScaleX(CGFloat(yScale))
    }
    
    open override func setVisibleYRange(minYRange: Double, maxYRange: Double, axis: YAxis.AxisDependency)
    {
        let minScale = getAxisRange(axis: axis) / minYRange
        let maxScale = getAxisRange(axis: axis) / maxYRange
        viewPortHandler.setMinMaxScaleX(minScaleX: CGFloat(minScale), maxScaleX: CGFloat(maxScale))
    }
}
