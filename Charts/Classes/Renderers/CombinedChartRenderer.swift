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
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

open class CombinedChartRenderer: ChartDataRendererBase
{
    open weak var chart: CombinedChartView?
    
    /// flag that enables or disables the highlighting arrow
    open var drawHighlightArrowEnabled = false
    
    /// if set to true, all values are drawn above their bars, instead of below their top
    open var drawValueAboveBarEnabled = true
    
    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    open var drawBarShadowEnabled = true
    
    internal var _renderers = [ChartDataRendererBase]()
    
    internal var _drawOrder: [CombinedChartView.DrawOrder] = [.bar, .bubble, .line, .candle, .scatter]
    
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
        
        guard let chart = chart,
              let animator = animator
        else { return }

        for order in drawOrder
        {
            switch (order)
            {
            case .bar:
                if (chart.barData !== nil)
                {
                    _renderers.append(BarChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
                break
                
            case .line:
                if (chart.lineData !== nil)
                {
                    _renderers.append(LineChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
                break
                
            case .candle:
                if (chart.candleData !== nil)
                {
                    _renderers.append(CandleStickChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
                break
                
            case .scatter:
                if (chart.scatterData !== nil)
                {
                    _renderers.append(ScatterChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
                break
                
            case .bubble:
                if (chart.bubbleData !== nil)
                {
                    _renderers.append(BubbleChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
                break
            }
        }

    }
    
    open override func drawData(context: CGContext)
    {
        for renderer in _renderers
        {
            renderer.drawData(context: context)
        }
    }
    
    open override func drawValues(context: CGContext)
    {
        for renderer in _renderers
        {
            renderer.drawValues(context: context)
        }
    }
    
    open override func drawExtras(context: CGContext)
    {
        for renderer in _renderers
        {
            renderer.drawExtras(context: context)
        }
    }
    
    open override func drawHighlighted(context: CGContext, indices: [ChartHighlight])
    {
        for renderer in _renderers
        {
            var data: ChartData?
            
            if renderer is BarChartRenderer
            {
                data = (renderer as! BarChartRenderer).dataProvider?.barData
            }
            else if renderer is LineChartRenderer
            {
                data = (renderer as! LineChartRenderer).dataProvider?.lineData
            }
            else if renderer is CandleStickChartRenderer
            {
                data = (renderer as! CandleStickChartRenderer).dataProvider?.candleData
            }
            else if renderer is ScatterChartRenderer
            {
                data = (renderer as! ScatterChartRenderer).dataProvider?.scatterData
            }
            else if renderer is BubbleChartRenderer
            {
                data = (renderer as! BubbleChartRenderer).dataProvider?.bubbleData
            }
            
            let dataIndex = data == nil ? nil : (chart?.data as? CombinedChartData)?.allData.index(of: data!)
            
            let dataIndices = indices.filter{ $0.dataIndex == dataIndex || $0.dataIndex == -1 }
            
            renderer.drawHighlighted(context: context, indices: dataIndices)
        }
    }
    
    open override func calcXBounds(chart: BarLineScatterCandleBubbleChartDataProvider, xAxisModulus: Int)
    {
        for renderer in _renderers
        {
            renderer.calcXBounds(chart: chart, xAxisModulus: xAxisModulus)
        }
    }

    /// - returns: the sub-renderer object at the specified index.
    open func getSubRenderer(index: Int) -> ChartDataRendererBase?
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
    open var subRenderers: [ChartDataRendererBase]
    {
        get { return _renderers }
        set { _renderers = newValue }
    }
    
    // MARK: Accessors
    
    /// the order in which the provided data objects should be drawn.
    /// The earlier you place them in the provided array, the further they will be in the background.
    /// e.g. if you provide [DrawOrder.Bar, DrawOrder.Line], the bars will be drawn behind the lines.
    open var drawOrder: [CombinedChartView.DrawOrder]
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
