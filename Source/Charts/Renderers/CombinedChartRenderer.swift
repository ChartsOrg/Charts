//
//  CombinedChartRenderer.swift
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

public class CombinedChartRenderer: DataRenderer
{
    public weak var chart: CombinedChartView?
    
    /// if set to true, all values are drawn above their bars, instead of below their top
    public var drawValueAboveBarEnabled = true
    
    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    public var drawBarShadowEnabled = false
    
    internal var _renderers = [DataRenderer]()
    
    internal var _drawOrder: [CombinedChartView.DrawOrder] = [.Bar, .Bubble, .Line, .Candle, .Scatter]
    
    public init(chart: CombinedChartView?, animator: Animator, viewPortHandler: ViewPortHandler?)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.chart = chart
        
        createRenderers()
    }
    
    /// Creates the renderers needed for this combined-renderer in the required order. Also takes the DrawOrder into consideration.
    internal func createRenderers()
    {
        _renderers = [DataRenderer]()
        
        guard let
            chart = chart,
            animator = animator,
            viewPortHandler = self.viewPortHandler
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
    
    public override func initBuffers()
    {
        for renderer in _renderers
        {
            renderer.initBuffers()
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
    
    public override func drawHighlighted(context context: CGContext, indices: [Highlight])
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
            
            let dataIndex = data == nil ? nil : (chart?.data as? CombinedChartData)?.allData.indexOf(data!)
            
            let dataIndices = indices.filter{ $0.dataIndex == dataIndex || $0.dataIndex == -1 }
            
            renderer.drawHighlighted(context: context, indices: dataIndices)
        }
    }

    /// - returns: The sub-renderer object at the specified index.
    public func getSubRenderer(index index: Int) -> DataRenderer?
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

    /// - returns: All sub-renderers.
    public var subRenderers: [DataRenderer]
    {
        get { return _renderers }
        set { _renderers = newValue }
    }
    
    // MARK: Accessors
    
    /// - returns: `true` if drawing values above bars is enabled, `false` ifnot
    public var isDrawValueAboveBarEnabled: Bool { return drawValueAboveBarEnabled; }
    
    /// - returns: `true` if drawing shadows (maxvalue) for each bar is enabled, `false` ifnot
    public var isDrawBarShadowEnabled: Bool { return drawBarShadowEnabled; }
    
    /// the order in which the provided data objects should be drawn.
    /// The earlier you place them in the provided array, the further they will be in the background.
    /// e.g. if you provide [DrawOrder.Bar, DrawOrder.Line], the bars will be drawn behind the lines.
    public var drawOrder: [CombinedChartView.DrawOrder]
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
