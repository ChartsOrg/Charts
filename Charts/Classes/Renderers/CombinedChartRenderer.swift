//
//  CombinedChartRenderer.swift
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

public class CombinedChartRenderer: ChartDataRendererBase
{
    public weak var chart: CombinedChartView?
    
    /// flag that enables or disables the highlighting arrow
    public var drawHighlightArrowEnabled = false
    
    /// if set to true, all values are drawn above their bars, instead of below their top
    public var drawValueAboveBarEnabled = true
    
    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    public var drawBarShadowEnabled = true
    
    internal var _renderers = [ChartDataRendererBase]()
    
    internal var _drawOrder: [CombinedChartView.CombinedChartDrawOrder] = [.Bar, .Bubble, .Line, .Candle, .Scatter]
    
    public init(chart: CombinedChartView, animator: ChartAnimator, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.chart = chart
        
        createRenderers()
    }
    
    /// Creates the renderers needed for this combined-renderer in the required order. Also takes the DrawOrder into consideration.
    internal func createRenderers()
    {
        _renderers = [ChartDataRendererBase]()
        
        guard let
            chart = chart,
            animator = animator
            else { return }

        for order in drawOrder
        {
            switch (order)
            {
            case .Bar:
                if (chart.barData !== nil)
                {
                    _renderers.append(BarChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
                break
                
            case .Line:
                if (chart.lineData !== nil)
                {
                    _renderers.append(LineChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
                break
                
            case .Candle:
                if (chart.candleData !== nil)
                {
                    _renderers.append(CandleStickChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
                break
                
            case .Scatter:
                if (chart.scatterData !== nil)
                {
                    _renderers.append(ScatterChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
                break
                
            case .Bubble:
                if (chart.bubbleData !== nil)
                {
                    _renderers.append(BubbleChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
                break
            }
        }

    }
    
    public override func drawData(context context: CGContext)
    {
        for renderer in _renderers
        {
            renderer.drawData(context: context)
        }
    }
    
    public override func drawValues(context context: CGContext)
    {
        for renderer in _renderers
        {
            renderer.drawValues(context: context)
        }
    }
    
    public override func drawExtras(context context: CGContext)
    {
        for renderer in _renderers
        {
            renderer.drawExtras(context: context)
        }
    }
    
    public override func drawHighlighted(context context: CGContext, indices: [ChartHighlight])
    {
        for renderer in _renderers
        {
            renderer.drawHighlighted(context: context, indices: indices)
        }
    }
    
    public override func calcXBounds(chart chart: BarLineChartViewBase, xAxisModulus: Int)
    {
        for renderer in _renderers
        {
            renderer.calcXBounds(chart: chart, xAxisModulus: xAxisModulus)
        }
    }

    /// - returns: the sub-renderer object at the specified index.
    public func getSubRenderer(index index: Int) -> ChartDataRendererBase?
    {
        if (index >= _renderers.count || index < 0)
        {
            return nil
        }
        else
        {
            return _renderers[index]
        }
    }

    /// Returns all sub-renderers.
    public var subRenderers: [ChartDataRendererBase]
    {
        get { return _renderers }
        set { _renderers = newValue }
    }
    
    // MARK: Accessors
    
    /// - returns: true if drawing the highlighting arrow is enabled, false if not
    public var isDrawHighlightArrowEnabled: Bool { return drawHighlightArrowEnabled; }
    
    /// - returns: true if drawing values above bars is enabled, false if not
    public var isDrawValueAboveBarEnabled: Bool { return drawValueAboveBarEnabled; }
    
    /// - returns: true if drawing shadows (maxvalue) for each bar is enabled, false if not
    public var isDrawBarShadowEnabled: Bool { return drawBarShadowEnabled; }
    
    /// the order in which the provided data objects should be drawn.
    /// The earlier you place them in the provided array, the further they will be in the background.
    /// e.g. if you provide [DrawOrder.Bar, DrawOrder.Line], the bars will be drawn behind the lines.
    public var drawOrder: [CombinedChartView.CombinedChartDrawOrder]
    {
        get
        {
            return _drawOrder
        }
        set
        {
            if (newValue.count > 0)
            {
                _drawOrder = newValue
            }
        }
    }
}
