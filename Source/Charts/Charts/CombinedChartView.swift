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

import Foundation
import CoreGraphics

/// This chart class allows the combination of lines, bars, scatter and candle data all displayed in one chart area.
public class CombinedChartView: BarLineChartViewBase, CombinedChartDataProvider
{
    /// the fill-formatter used for determining the position of the fill-line
    internal var _fillFormatter: IFillFormatter!
    
    /// enum that allows to specify the order in which the different data objects for the combined-chart are drawn
    @objc(CombinedChartDrawOrder)
    public enum DrawOrder: Int
    {
        case Bar
        case Bubble
        case Line
        case Candle
        case Scatter
    }
    
    public override func initialize()
    {
        super.initialize()
        
        self.highlighter = CombinedHighlighter(chart: self, barDataProvider: self)
        
        // Old default behaviour
        self.highlightFullBarEnabled = true
        
        _fillFormatter = DefaultFillFormatter()
        
        renderer = CombinedChartRenderer(chart: self, animator: _animator, viewPortHandler: _viewPortHandler)
    }
    
    public override var data: ChartData?
    {
        get
        {
            return super.data
        }
        set
        {
            super.data = newValue
            
            self.highlighter = CombinedHighlighter(chart: self, barDataProvider: self)
            
            (renderer as! CombinedChartRenderer?)!.createRenderers()
            renderer?.initBuffers()
        }
    }
    
    public var fillFormatter: IFillFormatter
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
                _fillFormatter = DefaultFillFormatter()
            }
        }
    }
    
    // MARK: - CombinedChartDataProvider
    
    public var combinedData: CombinedChartData?
    {
        get
        {
            return _data as? CombinedChartData
        }
    }
    
    // MARK: - LineChartDataProvider
    
    public var lineData: LineChartData?
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
    
    public var barData: BarChartData?
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
    
    public var scatterData: ScatterChartData?
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
    
    public var candleData: CandleChartData?
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
    
    public var bubbleData: BubbleChartData?
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
    
    /// if set to true, all values are drawn above their bars, instead of below their top
    public var drawValueAboveBarEnabled: Bool
        {
        get { return (renderer as! CombinedChartRenderer!).drawValueAboveBarEnabled }
        set { (renderer as! CombinedChartRenderer!).drawValueAboveBarEnabled = newValue }
    }
    
    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    public var drawBarShadowEnabled: Bool
    {
        get { return (renderer as! CombinedChartRenderer!).drawBarShadowEnabled }
        set { (renderer as! CombinedChartRenderer!).drawBarShadowEnabled = newValue }
    }
    
    /// - returns: `true` if drawing values above bars is enabled, `false` ifnot
    public var isDrawValueAboveBarEnabled: Bool { return (renderer as! CombinedChartRenderer!).drawValueAboveBarEnabled; }
    
    /// - returns: `true` if drawing shadows (maxvalue) for each bar is enabled, `false` ifnot
    public var isDrawBarShadowEnabled: Bool { return (renderer as! CombinedChartRenderer!).drawBarShadowEnabled; }
    
    /// the order in which the provided data objects should be drawn.
    /// The earlier you place them in the provided array, the further they will be in the background. 
    /// e.g. if you provide [DrawOrder.Bar, DrawOrder.Line], the bars will be drawn behind the lines.
    public var drawOrder: [Int]
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
    
    /// Set this to `true` to make the highlight operation full-bar oriented, `false` to make it highlight single values
    public var highlightFullBarEnabled: Bool = false
    
    /// - returns: `true` the highlight is be full-bar oriented, `false` ifsingle-value
    public var isHighlightFullBarEnabled: Bool { return highlightFullBarEnabled }
}