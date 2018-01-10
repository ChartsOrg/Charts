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

open class CombinedChartRenderer: NSObject, DataRenderer
{
    public let viewPortHandler: ViewPortHandler
    public let animator: Animator

    @objc open weak var chart: CombinedChartView?

    /// if set to true, all values are drawn above their bars, instead of below their top
    @objc open var drawValueAboveBar = true
    
    /// if set to true, a grey area is drawn behind each bar that indicates the maximum value
    @objc open var drawBarShadow = false
    
    @objc open var subRenderers = [DataRenderer]()
    
    var _drawOrder: [CombinedChartView.DrawOrder] = [.bar, .bubble, .line, .candle, .scatter]
    
    @objc public init(chart: CombinedChartView, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        self.chart = chart
        self.viewPortHandler = viewPortHandler
        self.animator = animator

        super.init()
        
        createRenderers()
    }
    
    /// Creates the renderers needed for this combined-renderer in the required order. Also takes the DrawOrder into consideration.
    func createRenderers()
    {
        subRenderers = [DataRenderer]()
        
        guard let chart = chart else { return }

        for order in drawOrder
        {
            switch (order)
            {
            case .bar:
                if chart.barData !== nil
                {
                    subRenderers.append(BarChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }

            case .line:
                if chart.lineData !== nil
                {
                    subRenderers.append(LineChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }

            case .candle:
                if chart.candleData !== nil
                {
                    subRenderers.append(CandleStickChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }

            case .scatter:
                if chart.scatterData !== nil
                {
                    subRenderers.append(ScatterChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }

            case .bubble:
                if chart.bubbleData !== nil
                {
                    subRenderers.append(BubbleChartRenderer(dataProvider: chart, animator: animator, viewPortHandler: viewPortHandler))
                }
            }
        }
    }
    
    open func initBuffers()
    {
        subRenderers.forEach { $0.initBuffers() }
    }
    
    open func drawData(context: CGContext)
    {
        subRenderers.forEach { $0.drawData(context: context) }
    }
    
    open func drawValues(context: CGContext)
    {
        subRenderers.forEach { $0.drawValues(context: context) }
    }
    
    open func drawExtras(context: CGContext)
    {
        subRenderers.forEach { $0.drawExtras(context: context) }
    }
    
    open func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        for renderer in subRenderers
        {
            var _data: ChartData?
            
            if renderer is BarChartRenderer
            {
                _data = (renderer as! BarChartRenderer).dataProvider?.barData
            }
            else if renderer is LineChartRenderer
            {
                _data = (renderer as! LineChartRenderer).dataProvider?.lineData
            }
            else if renderer is CandleStickChartRenderer
            {
                _data = (renderer as! CandleStickChartRenderer).dataProvider?.candleData
            }
            else if renderer is ScatterChartRenderer
            {
                _data = (renderer as! ScatterChartRenderer).dataProvider?.scatterData
            }
            else if renderer is BubbleChartRenderer
            {
                _data = (renderer as! BubbleChartRenderer).dataProvider?.bubbleData
            }

            guard let data = _data else { return }
            let dataIndex = (chart?.data as? CombinedChartData)?.allData.index(of: data)
            let dataIndices = indices.filter{ $0.dataIndex == dataIndex || $0.dataIndex == -1 }
            
            renderer.drawHighlighted(context: context, indices: dataIndices)
        }
    }

    open func isDrawingValuesAllowed(dataProvider: ChartDataProvider?) -> Bool
    {
        guard let data = dataProvider?.data else { return false }
        return data.entryCount < Int(CGFloat(dataProvider?.maxVisibleCount ?? 0) * viewPortHandler.scaleX)
    }

    /// - returns: The sub-renderer object at the specified index.
    @objc open func getSubRenderer(index: Int) -> DataRenderer?
    {
        guard subRenderers.indices.contains(index) else { return nil }
        return subRenderers[index]
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
            if newValue.count > 0
            {
                _drawOrder = newValue
            }
        }
    }
}
