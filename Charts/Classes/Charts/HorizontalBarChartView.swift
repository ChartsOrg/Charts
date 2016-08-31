//
//  HorizontalBarChartView.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
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
        
        _leftAxisTransformer = ChartTransformerHorizontalBarChart(viewPortHandler: _viewPortHandler)
        _rightAxisTransformer = ChartTransformerHorizontalBarChart(viewPortHandler: _viewPortHandler)
        
        renderer = HorizontalBarChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        _leftYAxisRenderer = ChartYAxisRendererHorizontalBarChart(viewPortHandler: _viewPortHandler, yAxis: _leftAxis, transformer: _leftAxisTransformer)
        _rightYAxisRenderer = ChartYAxisRendererHorizontalBarChart(viewPortHandler: _viewPortHandler, yAxis: _rightAxis, transformer: _rightAxisTransformer)
        _xAxisRenderer = ChartXAxisRendererHorizontalBarChart(viewPortHandler: _viewPortHandler, xAxis: _xAxis, transformer: _leftAxisTransformer, chart: self)
        
        self.highlighter = HorizontalBarChartHighlighter(chart: self)
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
        
        if (_xAxis.enabled)
        {
            // offsets for x-labels
            if (_xAxis.labelPosition == .bottom)
            {
                offsetLeft += xlabelwidth
            }
            else if (_xAxis.labelPosition == .top)
            {
                offsetRight += xlabelwidth
            }
            else if (_xAxis.labelPosition == .bothSided)
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

    internal override func calcModulus()
    {
        if let data = _data
        {
            _xAxis.axisLabelModulus = Int(ceil((CGFloat(data.xValCount) * _xAxis.labelRotatedHeight) / (_viewPortHandler.contentHeight * viewPortHandler.touchMatrix.d)))
        }
        else
        {
            _xAxis.axisLabelModulus = 1
        }
        
        if (_xAxis.axisLabelModulus < 1)
        {
            _xAxis.axisLabelModulus = 1
        }
    }
    
    open override func getBarBounds(_ e: BarChartDataEntry) -> CGRect
    {
        guard let
            set = _data?.getDataSetForEntry(e) as? IBarChartDataSet
            else { return CGRect.null }
        
        let barspace = set.barSpace
        let y = CGFloat(e.value)
        let x = CGFloat(e.xIndex)
        
        let spaceHalf = barspace / 2.0
        let top = x - 0.5 + spaceHalf
        let bottom = x + 0.5 - spaceHalf
        let left = y >= 0.0 ? y : 0.0
        let right = y <= 0.0 ? y : 0.0
        
        var bounds = CGRect(x: left, y: top, width: right - left, height: bottom - top)
        
        getTransformer(set.axisDependency).rectValueToPixel(&bounds)
        
        return bounds
    }
    
    open override func getPosition(_ e: ChartDataEntry, axis: ChartYAxis.AxisDependency) -> CGPoint
    {
        var vals = CGPoint(x: CGFloat(e.value), y: CGFloat(e.xIndex))
        
        getTransformer(axis).pointValueToPixel(&vals)
        
        return vals
    }

    open override func getHighlightByTouchPoint(_ pt: CGPoint) -> ChartHighlight?
    {
        if _data === nil
        {
            Swift.print("Can't select by touch. No data set.", terminator: "\n")
            return nil
        }
        
        return self.highlighter?.getHighlight(x: pt.y, y: pt.x)
    }
    
    open override var lowestVisibleXIndex: Int
    {
        let step = CGFloat(_data?.dataSetCount ?? 0)
        let div = (step <= 1.0) ? 1.0 : step + (_data as! BarChartData).groupSpace
        
        var pt = CGPoint(x: _viewPortHandler.contentLeft, y: _viewPortHandler.contentBottom)
        getTransformer(ChartYAxis.AxisDependency.left).pixelToValue(&pt)
        
        return Int(((pt.y <= 0.0) ? 0.0 : pt.y / div) + 1.0)
    }
    
    open override var highestVisibleXIndex: Int
    {
        let step = CGFloat(_data?.dataSetCount ?? 0)
        let div = (step <= 1.0) ? 1.0 : step + (_data as! BarChartData).groupSpace
        
        var pt = CGPoint(x: _viewPortHandler.contentLeft, y: _viewPortHandler.contentTop)
        getTransformer(ChartYAxis.AxisDependency.left).pixelToValue(&pt)
        
        return Int((pt.y >= CGFloat(chartXMax)) ? CGFloat(chartXMax) / div : (pt.y / div))
    }
}
