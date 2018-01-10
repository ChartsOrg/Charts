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
    @objc open weak var dataProvider: CandleChartDataProvider?
    
    @objc public init(dataProvider: CandleChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        self.dataProvider = dataProvider

        super.init(animator: animator, viewPortHandler: viewPortHandler)
    }
    
    open override func drawData(context: CGContext)
    {
        guard let dataProvider = dataProvider, let candleData = dataProvider.candleData else { return }

        for set in candleData.dataSets as! [CandleChartDataSetProtocol] where set.isVisible
        {
            drawDataSet(context: context, dataSet: set)
        }
    }
    
    @objc open func drawDataSet(context: CGContext, dataSet: CandleChartDataSetProtocol)
    {
        guard let dataProvider = dataProvider else { return }

        var shadowPoints = [CGPoint](repeating: .zero, count: 4)
        var rangePoints = [CGPoint](repeating: .zero, count: 2)
        var openPoints = [CGPoint](repeating: .zero, count: 2)
        var closePoints = [CGPoint](repeating: .zero, count: 2)
        var bodyRect = CGRect.zero
        var lineSegments = [CGPoint](repeating: .zero, count: 2)

        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = CGFloat(animator.phaseY)
        let barSpace = dataSet.barSpace
        let showCandleBar = dataSet.showCandleBar
        
        xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        context.saveGState()
        defer { context.restoreGState() }
        context.setLineWidth(dataSet.shadowWidth)

        // Helper functions
        func drawWithCandleBars(xPos: CGFloat, high: CGFloat, low: CGFloat, open: CGFloat, close: CGFloat, atIndex j: Int, in context: CGContext) {
            // calculate the shadow
            shadowPoints[0].x = xPos
            shadowPoints[1].x = xPos
            shadowPoints[2].x = xPos
            shadowPoints[3].x = xPos

            shadowPoints[0].y = high * phaseY
            shadowPoints[2].y = low * phaseY

            if open > close
            {
                shadowPoints[1].y = open * phaseY
                shadowPoints[3].y = close * phaseY
            }
            else if open < close
            {
                shadowPoints[1].y = close * phaseY
                shadowPoints[3].y = open * phaseY
            }
            else
            {
                shadowPoints[1].y = open * phaseY
                shadowPoints[3].y = shadowPoints[1].y
            }

            trans.pointValuesToPixel(&shadowPoints)

            // draw the shadows

            let shadowColor: NSUIColor
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
            else
            {
                shadowColor = dataSet.shadowColor ?? dataSet.color(atIndex: j)
            }

            context.setStrokeColor(shadowColor.cgColor)
            context.strokeLineSegments(between: shadowPoints)

            // calculate the body
            bodyRect.origin.x = xPos - 0.5 + barSpace
            bodyRect.origin.y = close * phaseY
            bodyRect.size.width = (xPos + 0.5 - barSpace) - bodyRect.origin.x
            bodyRect.size.height = open * phaseY - bodyRect.origin.y

            trans.rectValueToPixel(&bodyRect)

            // draw body differently for increasing and decreasing entry
            if open > close
            {
                let color = dataSet.decreasingColor ?? dataSet.color(atIndex: j)

                if dataSet.isDecreasingFilled
                {
                    context.setFillColor(color.cgColor)
                    context.fill(bodyRect)
                }
                else
                {
                    context.setStrokeColor(color.cgColor)
                    context.stroke(bodyRect)
                }
            }
            else if open < close
            {
                let color = dataSet.increasingColor ?? dataSet.color(atIndex: j)

                if dataSet.isIncreasingFilled
                {
                    context.setFillColor(color.cgColor)
                    context.fill(bodyRect)
                }
                else
                {
                    context.setStrokeColor(color.cgColor)
                    context.stroke(bodyRect)
                }
            }
            else
            {
                let color = dataSet.neutralColor ?? dataSet.color(atIndex: j)

                context.setStrokeColor(color.cgColor)
                context.stroke(bodyRect)
            }
        }

        func drawWithoutCandleBars(xPos: CGFloat, high: CGFloat, low: CGFloat, open: CGFloat, close: CGFloat, atIndex j: Int, in context: CGContext) {
            rangePoints[0].x = xPos
            rangePoints[0].y = high * phaseY
            rangePoints[1].x = xPos
            rangePoints[1].y = low * phaseY

            openPoints[0].x = xPos - 0.5 + barSpace
            openPoints[0].y = open * phaseY
            openPoints[1].x = xPos
            openPoints[1].y = open * phaseY

            closePoints[0].x = xPos + 0.5 - barSpace
            closePoints[0].y = close * phaseY
            closePoints[1].x = xPos
            closePoints[1].y = close * phaseY

            trans.pointValuesToPixel(&rangePoints)
            trans.pointValuesToPixel(&openPoints)
            trans.pointValuesToPixel(&closePoints)

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
            context.strokeLineSegments(between: rangePoints)
            context.strokeLineSegments(between: openPoints)
            context.strokeLineSegments(between: closePoints)
        }

        for j in xBounds.min...(xBounds.range + xBounds.min)
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
                drawWithCandleBars(xPos: xPos,
                                   high: high,
                                   low: low,
                                   open: open,
                                   close: close,
                                   atIndex: j,
                                   in: context)
            }
            else
            {
                drawWithoutCandleBars(xPos: xPos,
                                      high: high,
                                      low: low,
                                      open: open,
                                      close: close,
                                      atIndex: j,
                                      in: context)
            }
        }
    }
    
    open override func drawValues(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let candleData = dataProvider.candleData,
            isDrawingValuesAllowed(dataProvider: dataProvider)
            else { return }
        
        var dataSets = candleData.dataSets

        let phaseY = animator.phaseY

        var pt = CGPoint()

        for i in 0 ..< dataSets.count
        {
            guard
                let dataSet = dataSets[i] as? BarLineScatterCandleBubbleChartDataSetProtocol,
                shouldDrawValues(forDataSet: dataSet)
                else { continue }

            let valueFont = dataSet.valueFont

            guard let formatter = dataSet.valueFormatter else { continue }

            let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
            let valueToPixelMatrix = trans.valueToPixelMatrix

            let iconsOffset = dataSet.iconsOffset

            xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)

            let lineHeight = valueFont.lineHeight
            let yOffset: CGFloat = lineHeight + 5.0

            for j in xBounds.min...(xBounds.range + xBounds.min)
            {
                guard let e = dataSet.entryForIndex(j) as? CandleChartDataEntry else { break }

                pt.x = CGFloat(e.x)
                pt.y = CGFloat(e.high * phaseY)
                pt = pt.applying(valueToPixelMatrix)

                guard viewPortHandler.isInBoundsRight(pt.x) else { break }

                guard
                    viewPortHandler.isInBoundsLeft(pt.x),
                    viewPortHandler.isInBoundsY(pt.y)
                    else { continue }

                if dataSet.isDrawValuesEnabled
                {
                    context.drawText(formatter.stringForValue(e.high,
                                                              entry: e,
                                                              dataSetIndex: i,
                                                              viewPortHandler: viewPortHandler),
                                     at: CGPoint(x: pt.x,
                                                 y: pt.y - yOffset),
                                     align: .center,
                                     attributes: [.font: valueFont,
                                                  .foregroundColor: dataSet.valueTextColorAt(j)])
                }

                if let icon = e.icon, dataSet.isDrawIconsEnabled
                {
                    context.drawImage(icon,
                                      atCenter: CGPoint(x: pt.x + iconsOffset.x,
                                                        y: pt.y + iconsOffset.y),
                                      size: icon.size)
                }
            }
        }
    }
    
    open override func drawExtras(context: CGContext) { }
    
    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let dataProvider = dataProvider,
            let candleData = dataProvider.candleData
            else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        for high in indices
        {
            guard
                let set = candleData.getDataSetByIndex(high.dataSetIndex) as? CandleChartDataSetProtocol,
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
            
            let lowValue = e.low * animator.phaseY
            let highValue = e.high * animator.phaseY
            let y = (lowValue + highValue) / 2.0
            
            let pt = trans.pixelForValues(x: e.x, y: y)
            
            high.setDraw(pt: pt)
            
            // draw the lines
            drawHighlightLines(context: context, point: pt, set: set)
        }
    }
}
