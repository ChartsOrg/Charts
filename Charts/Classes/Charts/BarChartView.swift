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
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

/// Chart that draws bars.
public class BarChartView: BarLineChartViewBase, BarChartRendererDelegate
{
    /// flag that enables or disables the highlighting arrow
    private var _drawHighlightArrowEnabled = false
    
    /// if set to true, all values are drawn above their bars, instead of below their top
    private var _drawValueAboveBarEnabled = true

    /// if set to true, all values of a stack are drawn individually, and not just their sum
    private var _drawValuesForWholeStackEnabled = true
    
    /// if set to true, a grey area is darawn behind each bar that indicates the maximum value
    private var _drawBarShadowEnabled = false
    
    internal override func initialize()
    {
        super.initialize()
        
        renderer = BarChartRenderer(delegate: self, animator: _animator, viewPortHandler: _viewPortHandler)
        _xAxisRenderer = ChartXAxisRendererBarChart(viewPortHandler: _viewPortHandler, xAxis: _xAxis, transformer: _leftAxisTransformer, chart: self)
        
        _chartXMin = -0.5
    }
    
    internal override func calcMinMax()
    {
        super.calcMinMax()
        
        if (_data === nil)
        {
            return
        }
        
        var barData = _data as! BarChartData
        
        // increase deltax by 1 because the bars have a width of 1
        _deltaX += 0.5
        
        // extend xDelta to make space for multiple datasets (if ther are one)
        _deltaX *= CGFloat(_data.dataSetCount)
        
        var maxEntry = 0
        
        for (var i = 0, count = barData.dataSetCount; i < count; i++)
        {
            var set = barData.getDataSetByIndex(i)
            
            if (maxEntry < set!.entryCount)
            {
                maxEntry = set!.entryCount
            }
        }
        
        var groupSpace = barData.groupSpace
        _deltaX += CGFloat(maxEntry) * groupSpace
        _chartXMax = Double(_deltaX) - _chartXMin
    }
    
    /// Returns the Highlight object (contains x-index and DataSet index) of the selected value at the given touch point inside the BarChart.
    public override func getHighlightByTouchPoint(var pt: CGPoint) -> ChartHighlight!
    {
        if (_dataNotSet || _data === nil)
        {
            println("Can't select by touch. No data set.")
            return nil
        }
        
        _leftAxisTransformer.pixelToValue(&pt)
        
        if (pt.x < CGFloat(_chartXMin) || pt.x > CGFloat(_chartXMax))
        {
            return nil
        }
        
        return getHighlight(xPosition: pt.x, yPosition: pt.y)
    }
    
    /// Returns the correct Highlight object (including xIndex and dataSet-index) for the specified touch position.
    internal func getHighlight(#xPosition: CGFloat, yPosition: CGFloat) -> ChartHighlight!
    {
        if (_dataNotSet || _data === nil)
        {
            return nil
        }
        
        var barData = _data as! BarChartData!
        
        var setCount = barData.dataSetCount
        var valCount = barData.xValCount
        var dataSetIndex = 0
        var xIndex = 0
        
        if (!barData.isGrouped)
        { // only one dataset exists
            
            xIndex = Int(round(xPosition))
            
            // check bounds
            if (xIndex < 0)
            {
                xIndex = 0
            }
            else if (xIndex >= valCount)
            {
                xIndex = valCount - 1
            }
        }
        else
        { // if this bardata is grouped into more datasets
            
            // calculate how often the group-space appears
            var steps = Int(xPosition / (CGFloat(setCount) + CGFloat(barData.groupSpace)))
            
            var groupSpaceSum = barData.groupSpace * CGFloat(steps)
            
            var baseNoSpace = xPosition - groupSpaceSum
            
            dataSetIndex = Int(baseNoSpace) % setCount
            xIndex = Int(baseNoSpace) / setCount

            // check bounds
            if (xIndex < 0)
            {
                xIndex = 0
                dataSetIndex = 0
            }
            else if (xIndex >= valCount)
            {
                xIndex = valCount - 1
                dataSetIndex = setCount - 1
            }

            // check bounds
            if (dataSetIndex < 0)
            {
                dataSetIndex = 0
            }
            else if (dataSetIndex >= setCount)
            {
                dataSetIndex = setCount - 1
            }
        }
        
        var dataSet = barData.getDataSetByIndex(dataSetIndex) as! BarChartDataSet!
        if (!dataSet.isStacked)
        {
            return ChartHighlight(xIndex: xIndex, dataSetIndex: dataSetIndex)
        }
        else
        {
            return getStackedHighlight(xIndex: xIndex, dataSetIndex: dataSetIndex, yValue: Double(yPosition))
        }
    }
    
    /// This method creates the Highlight object that also indicates which value of a stacked BarEntry has been selected.
    internal func getStackedHighlight(#xIndex: Int, dataSetIndex: Int, yValue: Double) -> ChartHighlight!
    {
        var dataSet = _data.getDataSetByIndex(dataSetIndex)
        var entry = dataSet.entryForXIndex(xIndex) as! BarChartDataEntry!

        if (entry !== nil)
        {
            var stackIndex = entry.getClosestIndexAbove(yValue)
            return ChartHighlight(xIndex: xIndex, dataSetIndex: dataSetIndex, stackIndex: stackIndex)
        }
        else
        {
            return nil
        }
    }
    
    /// Returns the bounding box of the specified Entry in the specified DataSet. Returns null if the Entry could not be found in the charts data.
    public func getBarBounds(e: BarChartDataEntry) -> CGRect!
    {
        var set = _data.getDataSetForEntry(e) as! BarChartDataSet!
        
        if (set === nil)
        {
            return nil
        }
        
        var barspace = set.barSpace
        var y = CGFloat(e.value)
        var x = CGFloat(e.xIndex)
        
        var barWidth: CGFloat = 0.5
        
        var spaceHalf = barspace / 2.0
        var left = x - barWidth + spaceHalf
        var right = x + barWidth - spaceHalf
        var top = y >= 0.0 ? y : 0.0
        var bottom = y <= 0.0 ? y : 0.0
        
        var bounds = CGRect(x: left, y: top, width: right - left, height: bottom - top)
        
        getTransformer(set.axisDependency).rectValueToPixel(&bounds)
        
        return bounds
    }
    
    public override var lowestVisibleXIndex: Int
    {
        var step = CGFloat(_data.dataSetCount)
        var div = (step <= 1.0) ? 1.0 : step + (_data as! BarChartData).groupSpace
        
        var pt = CGPoint(x: _viewPortHandler.contentLeft, y: _viewPortHandler.contentBottom)
        getTransformer(ChartYAxis.AxisDependency.Left).pixelToValue(&pt)
        
        return Int((pt.x <= CGFloat(chartXMin)) ? 0.0 : (pt.x / div) + 1.0)
    }

    public override var highestVisibleXIndex: Int
    {
        var step = CGFloat(_data.dataSetCount)
        var div = (step <= 1.0) ? 1.0 : step + (_data as! BarChartData).groupSpace
        
        var pt = CGPoint(x: _viewPortHandler.contentRight, y: _viewPortHandler.contentBottom)
        getTransformer(ChartYAxis.AxisDependency.Left).pixelToValue(&pt)
        
        return Int((pt.x >= CGFloat(chartXMax)) ? CGFloat(chartXMax) / div : (pt.x / div))
    }

    // MARK: Accessors
    
    /// flag that enables or disables the highlighting arrow
    public var drawHighlightArrowEnabled: Bool
    {
        get { return _drawHighlightArrowEnabled; }
        set
        {
            _drawHighlightArrowEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// if set to true, all values are drawn above their bars, instead of below their top
    public var drawValueAboveBarEnabled: Bool
    {
        get { return _drawValueAboveBarEnabled; }
        set
        {
            _drawValueAboveBarEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// if set to true, all values of a stack are drawn individually, and not just their sum
    public var drawValuesForWholeStackEnabled: Bool
    {
        get { return _drawValuesForWholeStackEnabled; }
        set
        {
            _drawValuesForWholeStackEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    public var drawBarShadowEnabled: Bool
    {
        get { return _drawBarShadowEnabled; }
        set
        {
            _drawBarShadowEnabled = newValue
            setNeedsDisplay()
        }
    }
    
    /// returns true if drawing the highlighting arrow is enabled, false if not
    public var isDrawHighlightArrowEnabled: Bool { return drawHighlightArrowEnabled; }
    
    /// returns true if drawing values above bars is enabled, false if not
    public var isDrawValueAboveBarEnabled: Bool { return drawValueAboveBarEnabled; }
    
    /// returns true if all values of a stack are drawn, and not just their sum
    public var isDrawValuesForWholeStackEnabled: Bool { return drawValuesForWholeStackEnabled; }
    
    /// returns true if drawing shadows (maxvalue) for each bar is enabled, false if not
    public var isDrawBarShadowEnabled: Bool { return drawBarShadowEnabled; }
    
    // MARK: - BarChartRendererDelegate
    
    public func barChartRendererData(renderer: BarChartRenderer) -> BarChartData!
    {
        return _data as! BarChartData!
    }
    
    public func barChartRenderer(renderer: BarChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    {
        return getTransformer(which)
    }
    
    public func barChartRendererMaxVisibleValueCount(renderer: BarChartRenderer) -> Int
    {
        return maxVisibleValueCount
    }
    
    public func barChartDefaultRendererValueFormatter(renderer: BarChartRenderer) -> NSNumberFormatter!
    {
        return valueFormatter
    }
    
    public func barChartRendererChartYMax(renderer: BarChartRenderer) -> Double
    {
        return chartYMax
    }
    
    public func barChartRendererChartYMin(renderer: BarChartRenderer) -> Double
    {
        return chartYMin
    }
    
    public func barChartRendererChartXMax(renderer: BarChartRenderer) -> Double
    {
        return chartXMax
    }
    
    public func barChartRendererChartXMin(renderer: BarChartRenderer) -> Double
    {
        return chartXMin
    }
    
    public func barChartIsDrawHighlightArrowEnabled(renderer: BarChartRenderer) -> Bool
    {
        return drawHighlightArrowEnabled
    }
    
    public func barChartIsDrawValueAboveBarEnabled(renderer: BarChartRenderer) -> Bool
    {
        return drawValueAboveBarEnabled
    }
    
    public func barChartIsDrawValuesForWholeStackEnabled(renderer: BarChartRenderer) -> Bool
    {
        return drawValuesForWholeStackEnabled
    }
    
    public func barChartIsDrawBarShadowEnabled(renderer: BarChartRenderer) -> Bool
    {
        return drawBarShadowEnabled
    }
    
    public func barChartIsInverted(renderer: BarChartRenderer, axis: ChartYAxis.AxisDependency) -> Bool
    {
        return getAxis(axis).isInverted
    }
}