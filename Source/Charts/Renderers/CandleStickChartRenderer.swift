//
//  CandleStickChartRenderer.swift
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

#if !os(OSX)
    import UIKit
#endif


open class CandleStickChartRenderer: LineScatterCandleRadarRenderer
{
    open weak var dataProvider: CandleChartDataProvider?
    
    public init(dataProvider: CandleChartDataProvider?, animator: Animator?, viewPortHandler: ViewPortHandler?)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    open override func drawData(context: CGContext)
    {
        guard let dataProvider = dataProvider, let candleData = dataProvider.candleData else { return }

        for set in candleData.dataSets as! [ICandleChartDataSet] where set.isVisible
        {
            drawDataSet(context: context, dataSet: set)
        }
    }
    
    fileprivate var _shadowPoints = [CGPoint](repeating: CGPoint(), count: 4)
    fileprivate var _rangePoints = [CGPoint](repeating: CGPoint(), count: 2)
    fileprivate var _openPoints = [CGPoint](repeating: CGPoint(), count: 2)
    fileprivate var _closePoints = [CGPoint](repeating: CGPoint(), count: 2)
    fileprivate var _bodyRect = CGRect()
    fileprivate var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    open func drawDataSet(context: CGContext, dataSet: ICandleChartDataSet)
    {
        guard let dataProvider = dataProvider,
            let animator = animator
            else { return }

        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        let barSpace = dataSet.barSpace
        let showCandleBar = dataSet.showCandleBar
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        context.saveGState()
        defer { context.restoreGState() }

        context.setLineWidth(dataSet.shadowWidth)
        
        for j in _xBounds.min...(_xBounds.range + _xBounds.min)
        {
            // get the entry
            guard let e = dataSet.entryForIndex(j) as? CandleChartDataEntry else { continue }
            
            let xPos = CGFloat(e.x)
            
            let open = CGFloat(e.open)
            let close = CGFloat(e.close)
            let high = CGFloat(e.high)
            let low = CGFloat(e.low)
            
            if showCandleBar
            {
                // calculate the shadow
                
                _shadowPoints[0].x = xPos
                _shadowPoints[1].x = xPos
                _shadowPoints[2].x = xPos
                _shadowPoints[3].x = xPos
                
                if open > close
                {
                    _shadowPoints[0].y = high * phaseY
                    _shadowPoints[1].y = open * phaseY
                    _shadowPoints[2].y = low * phaseY
                    _shadowPoints[3].y = close * phaseY
                }
                else if open < close
                {
                    _shadowPoints[0].y = high * phaseY
                    _shadowPoints[1].y = close * phaseY
                    _shadowPoints[2].y = low * phaseY
                    _shadowPoints[3].y = open * phaseY
                }
                else
                {
                    _shadowPoints[0].y = high * phaseY
                    _shadowPoints[1].y = open * phaseY
                    _shadowPoints[2].y = low * phaseY
                    _shadowPoints[3].y = _shadowPoints[1].y
                }
                
                trans.pointValuesToPixel(&_shadowPoints)
                
                // draw the shadows
                
                var shadowColor: NSUIColor! = nil
                if dataSet.shadowColorSameAsCandle
                {
                    if open > close
                    {
                        shadowColor = dataSet.decreasingColor ?? dataSet.color(atIndex: j)
                    }
                    else if open < close
                    {
                        shadowColor = dataSet.increasingColor ?? dataSet.color(atIndex: j)
                    }
                    else
                    {
                        shadowColor = dataSet.neutralColor ?? dataSet.color(atIndex: j)
                    }
                }
                
                if shadowColor == nil
                {
                    shadowColor = dataSet.shadowColor ?? dataSet.color(atIndex: j)
                }
                
                context.setStrokeColor(shadowColor.cgColor)
                context.strokeLineSegments(between: _shadowPoints)
                
                // calculate the body
                
                _bodyRect.origin.x = xPos - 0.5 + barSpace
                _bodyRect.origin.y = close * phaseY
                _bodyRect.size.width = (xPos + 0.5 - barSpace) - _bodyRect.origin.x
                _bodyRect.size.height = (open * phaseY) - _bodyRect.origin.y
                
                trans.rectValueToPixel(&_bodyRect)
                
                // draw body differently for increasing and decreasing entry
                
                if open > close
                {
                    let color = dataSet.decreasingColor ?? dataSet.color(atIndex: j)
                    
                    if dataSet.isDecreasingFilled
                    {
                        context.setFillColor(color.cgColor)
                        context.fill(_bodyRect)
                    }
                    else
                    {
                        context.setStrokeColor(color.cgColor)
                        context.stroke(_bodyRect)
                    }
                }
                else if open < close
                {
                    let color = dataSet.increasingColor ?? dataSet.color(atIndex: j)
                    
                    if dataSet.isIncreasingFilled
                    {
                        context.setFillColor(color.cgColor)
                        context.fill(_bodyRect)
                    }
                    else
                    {
                        context.setStrokeColor(color.cgColor)
                        context.stroke(_bodyRect)
                    }
                }
                else
                {
                    let color = dataSet.neutralColor ?? dataSet.color(atIndex: j)
                    
                    context.setStrokeColor(color.cgColor)
                    context.stroke(_bodyRect)
                }
            }
            else
            {
                _rangePoints[0].x = xPos
                _rangePoints[0].y = high * phaseY
                _rangePoints[1].x = xPos
                _rangePoints[1].y = low * phaseY

                _openPoints[0].x = xPos - 0.5 + barSpace
                _openPoints[0].y = open * phaseY
                _openPoints[1].x = xPos
                _openPoints[1].y = open * phaseY

                _closePoints[0].x = xPos + 0.5 - barSpace
                _closePoints[0].y = close * phaseY
                _closePoints[1].x = xPos
                _closePoints[1].y = close * phaseY
                
                trans.pointValuesToPixel(&_rangePoints)
                trans.pointValuesToPixel(&_openPoints)
                trans.pointValuesToPixel(&_closePoints)
                
                // draw the ranges
                var barColor: NSUIColor! = nil
                
                if open > close
                {
                    barColor = dataSet.decreasingColor ?? dataSet.color(atIndex: j)
                }
                else if open < close
                {
                    barColor = dataSet.increasingColor ?? dataSet.color(atIndex: j)
                }
                else
                {
                    barColor = dataSet.neutralColor ?? dataSet.color(atIndex: j)
                }
                
                context.setStrokeColor(barColor.cgColor)
                context.strokeLineSegments(between: _rangePoints)
                context.strokeLineSegments(between: _openPoints)
                context.strokeLineSegments(between: _closePoints)
            }
        }
    }
    
    open override func drawValues(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let viewPortHandler = self.viewPortHandler,
            let candleData = dataProvider.candleData,
            let animator = animator,
            isDrawingValuesAllowed(dataProvider: dataProvider)
            else { return }

        var dataSets = candleData.dataSets

        let phaseY = animator.phaseY

        var pt = CGPoint()

        for i in 0..<dataSets.endIndex
        {
            guard let dataSet = dataSets[i] as? IBarLineScatterCandleBubbleChartDataSet,
                !shouldDrawValues(forDataSet: dataSet),
                let formatter = dataSet.valueFormatter
                else { continue }

            let valueFont = dataSet.valueFont
            let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
            let valueToPixelMatrix = trans.valueToPixelMatrix

            let iconsOffset = dataSet.iconsOffset

            _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)

            let lineHeight = valueFont.lineHeight
            let yOffset = lineHeight + 5.0

            for j in _xBounds.min...(_xBounds.range + _xBounds.min)
            {
                guard let e = dataSet.entryForIndex(j) as? CandleChartDataEntry else { break }

                pt.x = CGFloat(e.x)
                pt.y = CGFloat(e.high) * phaseY
                pt = pt.applying(valueToPixelMatrix)

                guard viewPortHandler.isInBoundsRight(pt.x) else { break }

                guard viewPortHandler.isInBoundsLeft(pt.x),
                    viewPortHandler.isInBoundsY(pt.y)
                    else { continue }

                if dataSet.isDrawValuesEnabled
                {
                    ChartUtils.drawText(
                        context: context,
                        text: formatter.stringForValue(
                            e.high,
                            entry: e,
                            dataSetIndex: i,
                            viewPortHandler: viewPortHandler),
                        point: CGPoint(
                            x: pt.x,
                            y: pt.y - yOffset),
                        align: .center,
                        attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)])
                }

                if let icon = e.icon, dataSet.isDrawIconsEnabled
                {
                    ChartUtils.drawImage(context: context,
                                         image: icon,
                                         x: pt.x + iconsOffset.x,
                                         y: pt.y + iconsOffset.y,
                                         size: icon.size)
                }
            }
        }
    }

    open override func drawExtras(context: CGContext)
    {
    }

    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard let dataProvider = dataProvider,
            let candleData = dataProvider.candleData,
            let animator = animator
            else { return }
        
        context.saveGState()
        defer { context.restoreGState() }

        for high in indices
        {
            guard let set = candleData.getDataSetByIndex(high.dataSetIndex) as? ICandleChartDataSet,
                set.isHighlightEnabled,
                let e = set.entryForXValue(high.x, closestToY: high.y) as? CandleChartDataEntry,
                isInBoundsX(entry: e, dataSet: set)
                else { continue }

            let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
            
            context.setStrokeColor(set.highlightColor.cgColor)
            context.setLineWidth(set.highlightLineWidth)
            
            if set.highlightLineDashLengths != nil
            {
                context.setLineDash(phase: set.highlightLineDashPhase, lengths: set.highlightLineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            let lowValue = e.low * Double(animator.phaseY)
            let highValue = e.high * Double(animator.phaseY)
            let y = (lowValue + highValue) / 2.0
            
            let pt = trans.pixelForValues(x: e.x, y: y)
            
            high.setDraw(pt: pt)
            
            // draw the lines
            drawHighlightLines(context: context, point: pt, set: set)
        }
    }
}
