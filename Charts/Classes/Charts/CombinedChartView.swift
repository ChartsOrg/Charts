//
//  CombinedChartView.swift
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

/// This chart class allows the combination of lines, bars, scatter and candle data all displayed in one chart area.
open class CombinedChartView: BarLineChartViewBase, LineChartDataProvider, BarChartDataProvider, ScatterChartDataProvider, CandleChartDataProvider, BubbleChartDataProvider
{
    /// the fill-formatter used for determining the position of the fill-line
    internal var _fillFormatter: ChartFillFormatter!
    
    /// enum that allows to specify the order in which the different data objects for the combined-chart are drawn
    @objc(CombinedChartDrawOrder)
    public enum DrawOrder: Int
    {
        case bar
        case bubble
        case line
        case candle
        case scatter
    }
    
    open override func initialize()
    {
        super.initialize()
        
        self.highlighter = CombinedHighlighter(chart: self)
        
        // Old default behaviour
        self.highlightFullBarEnabled = true
        
        /// WORKAROUND: Swift 2.0 compiler malfunctions when optimizations are enabled, and assigning directly to _fillFormatter causes a crash with a EXC_BAD_ACCESS. See https://github.com/danielgindi/Charts/issues/406
        let workaroundFormatter = ChartDefaultFillFormatter()
        _fillFormatter = workaroundFormatter
        
        renderer = CombinedChartRenderer(chart: self, animator: _animator, viewPortHandler: _viewPortHandler)
    }
    
    override func calcMinMax()
    {
        super.calcMinMax()
        guard let data = _data else { return }
        
        if (self.barData !== nil || self.candleData !== nil || self.bubbleData !== nil)
        {
            _xAxis._axisMinimum = -0.5
            _xAxis._axisMaximum = Double(data.xVals.count) - 0.5
            
            if (self.bubbleData !== nil)
            {
                for set in self.bubbleData?.dataSets as! [IBubbleChartDataSet]
                {
                    let xmin = set.xMin
                    let xmax = set.xMax
                    
                    if (xmin < chartXMin)
                    {
                        _xAxis._axisMinimum = xmin
                    }
                    
                    if (xmax > chartXMax)
                    {
                        _xAxis._axisMaximum = xmax
                    }
                }
            }
        }
        
        _xAxis.axisRange = abs(_xAxis._axisMaximum - _xAxis._axisMinimum)
        
        if _xAxis.axisRange == 0.0, let lineData = self.lineData, lineData.yValCount > 0
        {
            _xAxis.axisRange = 1.0
        }
    }
    
    open override var data: ChartData?
    {
        get
        {
            return super.data
        }
        set
        {
            super.data = newValue
            (renderer as! CombinedChartRenderer?)!.createRenderers()
        }
    }
    
    open var fillFormatter: ChartFillFormatter
    {
        get
        {
            return _fillFormatter
        }
        set
        {
            _fillFormatter = newValue
            if (_fillFormatter == nil)
            {
                _fillFormatter = ChartDefaultFillFormatter()
            }
        }
    }
    
    // MARK: - LineChartDataProvider
    
    open var lineData: LineChartData?
    {
        get
        {
            if (_data === nil)
            {
                return nil
            }
            return (_data as! CombinedChartData!).lineData
        }
    }
    
    // MARK: - BarChartDataProvider
    
    open var barData: BarChartData?
    {
        get
        {
            if (_data === nil)
            {
                return nil
            }
            return (_data as! CombinedChartData!).barData
        }
    }
    
    // MARK: - ScatterChartDataProvider
    
    open var scatterData: ScatterChartData?
    {
        get
        {
            if (_data === nil)
            {
                return nil
            }
            return (_data as! CombinedChartData!).scatterData
        }
    }
    
    // MARK: - CandleChartDataProvider
    
    open var candleData: CandleChartData?
    {
        get
        {
            if (_data === nil)
            {
                return nil
            }
            return (_data as! CombinedChartData!).candleData
        }
    }
    
    // MARK: - BubbleChartDataProvider
    
    open var bubbleData: BubbleChartData?
    {
        get
        {
            if (_data === nil)
            {
                return nil
            }
            return (_data as! CombinedChartData!).bubbleData
        }
    }
    
    // MARK: - Accessors
    
    /// flag that enables or disables the highlighting arrow
    open var drawHighlightArrowEnabled: Bool
    {
        get { return (renderer as! CombinedChartRenderer!).drawHighlightArrowEnabled }
        set { (renderer as! CombinedChartRenderer!).drawHighlightArrowEnabled = newValue }
    }
    
    /// if set to true, all values are drawn above their bars, instead of below their top
    open var drawValueAboveBarEnabled: Bool
        {
        get { return (renderer as! CombinedChartRenderer!).drawValueAboveBarEnabled }
        set { (renderer as! CombinedChartRenderer!).drawValueAboveBarEnabled = newValue }
    }
    
    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    open var drawBarShadowEnabled: Bool
    {
        get { return (renderer as! CombinedChartRenderer!).drawBarShadowEnabled }
        set { (renderer as! CombinedChartRenderer!).drawBarShadowEnabled = newValue }
    }
    
    /// the order in which the provided data objects should be drawn.
    /// The earlier you place them in the provided array, the further they will be in the background. 
    /// e.g. if you provide [DrawOrder.Bar, DrawOrder.Line], the bars will be drawn behind the lines.
    open var drawOrder: [Int]
    {
        get
        {
            return (renderer as! CombinedChartRenderer!).drawOrder.map { $0.rawValue }
        }
        set
        {
            (renderer as! CombinedChartRenderer!).drawOrder = newValue.map { DrawOrder(rawValue: $0)! }
        }
    }
}
