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
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

/// This chart class allows the combination of lines, bars, scatter and candle data all displayed in one chart area.
public class CombinedChartView: BarLineChartViewBase, LineChartDataProvider, BarChartDataProvider, ScatterChartDataProvider, CandleChartDataProvider, BubbleChartDataProvider
{
    /// the fill-formatter used for determining the position of the fill-line
    internal var _fillFormatter: ChartFillFormatter!
    
    internal var _barChartXMax = Double(0.0)
    internal var _barChartXMin = Double(0.0)
    internal var _barChartDeltaX = CGFloat(0.0)
    
    internal var _barChartLeftYAxisRenderer: ChartYAxisRenderer!
    internal var _barChartRightYAxisRenderer: ChartYAxisRenderer!
    
    internal var _barChartLeftAxisTransformer: ChartTransformer!
    internal var _barChartRightAxisTransformer: ChartTransformer!
    
    /// enum that allows to specify the order in which the different data objects for the combined-chart are drawn
    @objc
    public enum CombinedChartDrawOrder: Int
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
        
        self.highlighter = CombinedHighlighter(chart: self)
        
        /// WORKAROUND: Swift 2.0 compiler malfunctions when optimizations are enabled, and assigning directly to _fillFormatter causes a crash with a EXC_BAD_ACCESS. See https://github.com/danielgindi/ios-charts/issues/406
        let workaroundFormatter = ChartDefaultFillFormatter()
        _fillFormatter = workaroundFormatter
        
        _barChartLeftAxisTransformer = ChartTransformer(viewPortHandler: _viewPortHandler)
        _barChartRightAxisTransformer = ChartTransformer(viewPortHandler: _viewPortHandler)
        
        _barChartLeftYAxisRenderer = ChartYAxisRenderer(viewPortHandler: _viewPortHandler, yAxis: _leftAxis, transformer: _leftAxisTransformer)
        _barChartRightYAxisRenderer = ChartYAxisRenderer(viewPortHandler: _viewPortHandler, yAxis: _rightAxis, transformer: _rightAxisTransformer)
        
        renderer = CombinedChartRenderer(chart: self, animator: _animator, viewPortHandler: _viewPortHandler)
    }
    
    override func calcMinMax()
    {
        super.calcMinMax()
        guard let data = _data else { return }
        
        if (self.barData !== nil || self.candleData !== nil || self.bubbleData !== nil)
        {
            _chartXMin = -0.5
            _chartXMax = Double(data.xVals.count) - 0.5
            
            if (self.bubbleData !== nil)
            {
                for set in self.bubbleData?.dataSets as! [IBubbleChartDataSet]
                {
                    let xmin = set.xMin
                    let xmax = set.xMax
                    
                    if (xmin < chartXMin)
                    {
                        _chartXMin = xmin
                    }
                    
                    if (xmax > chartXMax)
                    {
                        _chartXMax = xmax
                    }
                }
            }
            
            if (self.barData !== nil)
            {
                let barData = self.barData
                
                _barChartXMin = _chartXMin
                _barChartXMax = _chartXMax
                _barChartDeltaX = _deltaX
                // increase deltax by 1 because the bars have a width of 1
                _barChartDeltaX += 0.5
                
                // extend xDelta to make space for multiple datasets (if ther are one)
                _barChartDeltaX *= CGFloat(barData!.dataSetCount)
                
                let maxEntry = _data.xValCount
                
                let groupSpace = barData!.groupSpace
                _barChartDeltaX += CGFloat(maxEntry) * groupSpace
                _barChartXMax = Double(_barChartDeltaX) - _barChartXMin
            }
        }
        
        _deltaX = CGFloat(abs(_chartXMax - _chartXMin))
        
        if (_deltaX == 0.0 && self.lineData?.yValCount > 0)
        {
            _deltaX = 1.0
        }
    }
    
    internal override func prepareValuePxMatrix()
    {
        super.prepareValuePxMatrix()
        
        _barChartRightAxisTransformer.prepareMatrixValuePx(chartXMin: _barChartXMin, deltaX: _barChartDeltaX, deltaY: CGFloat(_rightAxis.axisRange), chartYMin: _rightAxis.axisMinimum)
        _barChartLeftAxisTransformer.prepareMatrixValuePx(chartXMin: _barChartXMin, deltaX: _barChartDeltaX, deltaY: CGFloat(_leftAxis.axisRange), chartYMin: _leftAxis.axisMinimum)
    }
    
    internal override func prepareOffsetMatrix()
    {
        super.prepareOffsetMatrix()
        
        _barChartRightAxisTransformer.prepareMatrixOffset(_rightAxis.isInverted)
        _barChartLeftAxisTransformer.prepareMatrixOffset(_leftAxis.isInverted)
    }
    
    /// Returns the Transformer class that contains all matrices and is
    /// responsible for transforming values into pixels on the screen and
    /// backwards.
    public func getBarChartTransformer(which: ChartYAxis.AxisDependency) -> ChartTransformer
    {
        if (which == .Left)
        {
            return _barChartLeftAxisTransformer
        }
        else
        {
            return _barChartRightAxisTransformer
        }
    }
    
    public override func getMarkerPosition(entry e: ChartDataEntry, highlight: ChartHighlight) -> CGPoint
    {
        let dataSetIndex = highlight.dataSetIndex
        let dataSet = _data.getDataSetByIndex(dataSetIndex)
        var xPos = CGFloat(e.xIndex)
        var yPos = e.value
        
        if (dataSet!.dynamicType === BarChartDataSet.self)
        {
            let bd = (_data as! CombinedChartData).barData
            let space = bd.groupSpace
            
            let barDataSetIndex = bd.indexOfDataSet(dataSet)
            
            let x = CGFloat(e.xIndex * (bd.dataSetCount - 1) + barDataSetIndex) + space * CGFloat(e.xIndex) + space / 2.0
            
            xPos += x
            
            if let barEntry = e as? BarChartDataEntry
            {
                if barEntry.values != nil && highlight.range !== nil
                {
                    yPos = highlight.range!.to
                }
            }
        }
        
        var pt = CGPoint(x: xPos, y: CGFloat(yPos) * _animator.phaseY)
        
        if (dataSet!.dynamicType === BarChartDataSet.self)
        {
            getBarChartTransformer(_data.getDataSetByIndex(dataSetIndex)!.axisDependency).pointValueToPixel(&pt)
        }
        else
        {
            getTransformer(_data.getDataSetByIndex(dataSetIndex)!.axisDependency).pointValueToPixel(&pt)
        }
        
        return pt
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
            (renderer as! CombinedChartRenderer?)!.createRenderers()
        }
    }
    
    public var fillFormatter: ChartFillFormatter
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
    
    public var barChartXMax: Double
        {
            return _barChartXMax
    }
    
    public var barChartXMin: Double
        {
            return _barChartXMin
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
    
    /// flag that enables or disables the highlighting arrow
    public var drawHighlightArrowEnabled: Bool
    {
        get { return (renderer as! CombinedChartRenderer!).drawHighlightArrowEnabled }
        set { (renderer as! CombinedChartRenderer!).drawHighlightArrowEnabled = newValue }
    }
    
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
    
    /// - returns: true if drawing the highlighting arrow is enabled, false if not
    public var isDrawHighlightArrowEnabled: Bool { return (renderer as! CombinedChartRenderer!).drawHighlightArrowEnabled; }
    
    /// - returns: true if drawing values above bars is enabled, false if not
    public var isDrawValueAboveBarEnabled: Bool { return (renderer as! CombinedChartRenderer!).drawValueAboveBarEnabled; }
    
    /// - returns: true if drawing shadows (maxvalue) for each bar is enabled, false if not
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
            (renderer as! CombinedChartRenderer!).drawOrder = newValue.map { CombinedChartDrawOrder(rawValue: $0)! }
        }
    }
}