//
//  BarChartView.swift
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

/// Chart that draws bars.
open class BarChartView: BarLineChartViewBase, BarChartDataProvider
{
    /// flag that enables or disables the highlighting arrow
    private var _drawHighlightArrowEnabled = false
    
    /// if set to true, all values are drawn above their bars, instead of below their top
    private var _drawValueAboveBarEnabled = true

    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    private var _drawBarShadowEnabled = false
    
    internal override func initialize()
    {
        super.initialize()
        
        renderer = BarChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        _xAxisRenderer = ChartXAxisRendererBarChart(viewPortHandler: _viewPortHandler, xAxis: _xAxis, transformer: _leftAxisTransformer, chart: self)
        
        self.highlighter = BarChartHighlighter(chart: self)
        
        _xAxis._axisMinimum = -0.5
    }
    
    internal override func calcMinMax()
    {
        super.calcMinMax()
        
        guard let data = _data else { return }
        
        let barData = data as! BarChartData
        
        // increase deltax by 1 because the bars have a width of 1
        _xAxis.axisRange += 0.5
        
        // extend xDelta to make space for multiple datasets (if ther are one)
        _xAxis.axisRange *= Double(data.dataSetCount)
        
        let groupSpace = barData.groupSpace
        _xAxis.axisRange += Double(barData.xValCount) * Double(groupSpace)
        _xAxis._axisMaximum = _xAxis.axisRange - _xAxis._axisMinimum
    }
    
    /// - returns: the Highlight object (contains x-index and DataSet index) of the selected value at the given touch point inside the BarChart.
    open override func getHighlightByTouchPoint(_ pt: CGPoint) -> ChartHighlight?
    {
        if _data === nil
        {
            Swift.print("Can't select by touch. No data set.")
            return nil
        }

        return self.highlighter?.getHighlight(x: pt.x, y: pt.y)
    }
        
    /// - returns: the bounding box of the specified Entry in the specified DataSet. Returns null if the Entry could not be found in the charts data.
    open func getBarBounds(_ e: BarChartDataEntry) -> CGRect
    {
        guard let set = _data?.getDataSetForEntry(e) as? IBarChartDataSet
            else { return CGRect.null }
        
        let barspace = set.barSpace
        let y = CGFloat(e.value)
        let x = CGFloat(e.xIndex)
        
        let barWidth: CGFloat = 0.5
        
        let spaceHalf = barspace / 2.0
        let left = x - barWidth + spaceHalf
        let right = x + barWidth - spaceHalf
        let top = y >= 0.0 ? y : 0.0
        let bottom = y <= 0.0 ? y : 0.0
        
        var bounds = CGRect(x: left, y: top, width: right - left, height: bottom - top)
        
        getTransformer(set.axisDependency).rectValueToPixel(&bounds)
        
        return bounds
    }
    
    open override var lowestVisibleXIndex: Int
    {
        let step = CGFloat(_data?.dataSetCount ?? 0)
        let div = (step <= 1.0) ? 1.0 : step + (_data as! BarChartData).groupSpace
        
        var pt = CGPoint(x: _viewPortHandler.contentLeft, y: _viewPortHandler.contentBottom)
        getTransformer(ChartYAxis.AxisDependency.left).pixelToValue(&pt)
        
        return Int((pt.x <= CGFloat(chartXMin)) ? 0.0 : (pt.x / div) + 1.0)
    }

    open override var highestVisibleXIndex: Int
    {
        let step = CGFloat(_data?.dataSetCount ?? 0)
        let div = (step <= 1.0) ? 1.0 : step + (_data as! BarChartData).groupSpace
        
        var pt = CGPoint(x: _viewPortHandler.contentRight, y: _viewPortHandler.contentBottom)
        getTransformer(ChartYAxis.AxisDependency.left).pixelToValue(&pt)
        
        return Int((pt.x >= CGFloat(chartXMax)) ? CGFloat(chartXMax) / div : (pt.x / div))
    }

    // MARK: Accessors
    
    /// flag that enables or disables the highlighting arrow
    open var drawHighlightArrowEnabled: Bool
    {
        get { return _drawHighlightArrowEnabled; }
        set
        {
            _drawHighlightArrowEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// if set to true, all values are drawn above their bars, instead of below their top
    open var drawValueAboveBarEnabled: Bool
    {
        get { return _drawValueAboveBarEnabled; }
        set
        {
            _drawValueAboveBarEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    open var drawBarShadowEnabled: Bool
    {
        get { return _drawBarShadowEnabled; }
        set
        {
            _drawBarShadowEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    // MARK: - BarChartDataProbider
    
    open var barData: BarChartData? { return _data as? BarChartData }
}
