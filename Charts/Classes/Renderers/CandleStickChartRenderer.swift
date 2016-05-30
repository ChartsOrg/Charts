//
//  CandleStickChartRenderer.swift
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

#if !os(OSX)
    import UIKit
#endif


public class CandleStickChartRenderer: LineScatterCandleRadarChartRenderer
{
    public weak var dataProvider: CandleChartDataProvider?
    
    public init(dataProvider: CandleChartDataProvider?, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    public override func drawData(context context: CGContext)
    {
        guard let dataProvider = dataProvider, candleData = dataProvider.candleData else { return }

        for set in candleData.dataSets as! [ICandleChartDataSet]
        {
            if set.isVisible && set.entryCount > 0
            {
                drawDataSet(context: context, dataSet: set)
            }
        }
    }
    
    private var _shadowPoints = [CGPoint](count: 4, repeatedValue: CGPoint())
    private var _rangePoints = [CGPoint](count: 2, repeatedValue: CGPoint())
    private var _openPoints = [CGPoint](count: 2, repeatedValue: CGPoint())
    private var _closePoints = [CGPoint](count: 2, repeatedValue: CGPoint())
    private var _bodyRect = CGRect()
    private var _lineSegments = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public func drawDataSet(context context: CGContext, dataSet: ICandleChartDataSet)
    {
        guard let
            trans = dataProvider?.getTransformer(dataSet.axisDependency),
            animator = animator
            else { return }
        
        let phaseX = max(0.0, min(1.0, animator.phaseX))
        let phaseY = animator.phaseY
        let barSpace = dataSet.barSpace
        let showCandleBar = dataSet.showCandleBar
        
        let entryCount = dataSet.entryCount
        
        let minx = max(self.minX, 0)
        let maxx = min(self.maxX + 1, entryCount)
        
        CGContextSaveGState(context)
        
        CGContextSetLineWidth(context, dataSet.shadowWidth)
        
        for j in minx.stride(to: Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))), by: 1)
        {
            // get the entry
            guard let e = dataSet.entryForIndex(j) as? CandleChartDataEntry else { continue }
            
            let xIndex = e.xIndex
            
            if (xIndex < minx || xIndex >= maxx)
            {
                continue
            }
            
            let open = e.open
            let close = e.close
            let high = e.high
            let low = e.low
            
            if (showCandleBar)
            {
                // calculate the shadow
                
                _shadowPoints[0].x = CGFloat(xIndex)
                _shadowPoints[1].x = CGFloat(xIndex)
                _shadowPoints[2].x = CGFloat(xIndex)
                _shadowPoints[3].x = CGFloat(xIndex)
                
                if (open > close)
                {
                    _shadowPoints[0].y = CGFloat(high) * phaseY
                    _shadowPoints[1].y = CGFloat(open) * phaseY
                    _shadowPoints[2].y = CGFloat(low) * phaseY
                    _shadowPoints[3].y = CGFloat(close) * phaseY
                }
                else if (open < close)
                {
                    _shadowPoints[0].y = CGFloat(high) * phaseY
                    _shadowPoints[1].y = CGFloat(close) * phaseY
                    _shadowPoints[2].y = CGFloat(low) * phaseY
                    _shadowPoints[3].y = CGFloat(open) * phaseY
                }
                else
                {
                    _shadowPoints[0].y = CGFloat(high) * phaseY
                    _shadowPoints[1].y = CGFloat(open) * phaseY
                    _shadowPoints[2].y = CGFloat(low) * phaseY
                    _shadowPoints[3].y = _shadowPoints[1].y
                }
                
                trans.pointValuesToPixel(&_shadowPoints)
                
                // draw the shadows
                
                var shadowColor: NSUIColor! = nil
                if (dataSet.shadowColorSameAsCandle)
                {
                    if (open > close)
                    {
                        shadowColor = dataSet.decreasingColor ?? dataSet.colorAt(j)
                    }
                    else if (open < close)
                    {
                        shadowColor = dataSet.increasingColor ?? dataSet.colorAt(j)
                    }
                    else
                    {
                        shadowColor = dataSet.neutralColor ?? dataSet.colorAt(j)
                    }
                }
                
                if (shadowColor === nil)
                {
                    shadowColor = dataSet.shadowColor ?? dataSet.colorAt(j);
                }
                
                CGContextSetStrokeColorWithColor(context, shadowColor.CGColor)
                CGContextStrokeLineSegments(context, _shadowPoints, 4)
                
                // calculate the body
                
                _bodyRect.origin.x = CGFloat(xIndex) - 0.5 + barSpace
                _bodyRect.origin.y = CGFloat(close) * phaseY
                _bodyRect.size.width = (CGFloat(xIndex) + 0.5 - barSpace) - _bodyRect.origin.x
                _bodyRect.size.height = (CGFloat(open) * phaseY) - _bodyRect.origin.y
                
                trans.rectValueToPixel(&_bodyRect)
                
                // draw body differently for increasing and decreasing entry
                
                if (open > close)
                {
                    let color = dataSet.decreasingColor ?? dataSet.colorAt(j)
                    
                    if (dataSet.isDecreasingFilled)
                    {
                        CGContextSetFillColorWithColor(context, color.CGColor)
                        CGContextFillRect(context, _bodyRect)
                    }
                    else
                    {
                        CGContextSetStrokeColorWithColor(context, color.CGColor)
                        CGContextStrokeRect(context, _bodyRect)
                    }
                }
                else if (open < close)
                {
                    let color = dataSet.increasingColor ?? dataSet.colorAt(j)
                    
                    if (dataSet.isIncreasingFilled)
                    {
                        CGContextSetFillColorWithColor(context, color.CGColor)
                        CGContextFillRect(context, _bodyRect)
                    }
                    else
                    {
                        CGContextSetStrokeColorWithColor(context, color.CGColor)
                        CGContextStrokeRect(context, _bodyRect)
                    }
                }
                else
                {
                    let color = dataSet.neutralColor ?? dataSet.colorAt(j)
                    
                    CGContextSetStrokeColorWithColor(context, color.CGColor)
                    CGContextStrokeRect(context, _bodyRect)
                }
            }
            else
            {
                _rangePoints[0].x = CGFloat(xIndex)
                _rangePoints[0].y = CGFloat(high) * phaseY
                _rangePoints[1].x = CGFloat(xIndex)
                _rangePoints[1].y = CGFloat(low) * phaseY

                _openPoints[0].x = CGFloat(xIndex) - 0.5 + barSpace
                _openPoints[0].y = CGFloat(open) * phaseY
                _openPoints[1].x = CGFloat(xIndex)
                _openPoints[1].y = CGFloat(open) * phaseY

                _closePoints[0].x = CGFloat(xIndex) + 0.5 - barSpace
                _closePoints[0].y = CGFloat(close) * phaseY
                _closePoints[1].x = CGFloat(xIndex)
                _closePoints[1].y = CGFloat(close) * phaseY
                
                trans.pointValuesToPixel(&_rangePoints)
                trans.pointValuesToPixel(&_openPoints)
                trans.pointValuesToPixel(&_closePoints)
                
                // draw the ranges
                var barColor: NSUIColor! = nil
                
                if (open > close)
                {
                    barColor = dataSet.decreasingColor ?? dataSet.colorAt(j)
                }
                else if (open < close)
                {
                    barColor = dataSet.increasingColor ?? dataSet.colorAt(j)
                }
                else
                {
                    barColor = dataSet.neutralColor ?? dataSet.colorAt(j)
                }
                
                CGContextSetStrokeColorWithColor(context, barColor.CGColor)
                CGContextStrokeLineSegments(context, _rangePoints, 2)
                CGContextStrokeLineSegments(context, _openPoints, 2)
                CGContextStrokeLineSegments(context, _closePoints, 2)
            }
        }
        
        CGContextRestoreGState(context)
    }
    
    public override func drawValues(context context: CGContext)
    {
        guard let
            dataProvider = dataProvider,
            candleData = dataProvider.candleData,
            animator = animator
            else { return }
        
        // if values are drawn
        if (candleData.yValCount < Int(ceil(CGFloat(dataProvider.maxVisibleValueCount) * viewPortHandler.scaleX)))
        {
            var dataSets = candleData.dataSets
            
            let phaseX = max(0.0, min(1.0, animator.phaseX))
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for i in 0 ..< dataSets.count
            {
                let dataSet = dataSets[i]
                
                if !dataSet.isDrawValuesEnabled || dataSet.entryCount == 0
                {
                    continue
                }
                
                let valueFont = dataSet.valueFont
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                let trans = dataProvider.getTransformer(dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                let entryCount = dataSet.entryCount
                
                let minx = max(self.minX, 0)
                let maxx = min(self.maxX + 1, entryCount)
                
                let lineHeight = valueFont.lineHeight
                let yOffset: CGFloat = lineHeight + 5.0
                
                for j in minx.stride(to: Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))), by: 1)
                {
                    guard let e = dataSet.entryForIndex(j) as? CandleChartDataEntry else { break }
                    
                    pt.x = CGFloat(e.xIndex)
                    pt.y = CGFloat(e.high) * phaseY
                    pt = CGPointApplyAffineTransform(pt, valueToPixelMatrix)
                    
                    if (!viewPortHandler.isInBoundsRight(pt.x))
                    {
                        break
                    }
                    
                    if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y))
                    {
                        continue
                    }
                    
                    ChartUtils.drawText(
                        context: context,
                        text: formatter.stringFromNumber(e.high)!,
                        point: CGPoint(
                            x: pt.x,
                            y: pt.y - yOffset),
                        align: .Center,
                        attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)])
                }
            }
        }
    }
    
    public override func drawExtras(context context: CGContext)
    {
    }
    
    private var _highlightPointBuffer = CGPoint()
    
    public override func drawHighlighted(context context: CGContext, indices: [ChartHighlight])
    {
        guard let
            dataProvider = dataProvider,
            candleData = dataProvider.candleData,
            animator = animator
            else { return }
        
        CGContextSaveGState(context)
        
        for high in indices
        {
            let minDataSetIndex = high.dataSetIndex == -1 ? 0 : high.dataSetIndex
            let maxDataSetIndex = high.dataSetIndex == -1 ? candleData.dataSetCount : (high.dataSetIndex + 1)
            if maxDataSetIndex - minDataSetIndex < 1 { continue }
            
            for dataSetIndex in minDataSetIndex..<maxDataSetIndex
            {
                guard let set = candleData.getDataSetByIndex(dataSetIndex) as? ICandleChartDataSet else { continue }
                
                if (!set.isHighlightEnabled)
                {
                    continue
                }
                
                let xIndex = high.xIndex; // get the x-position
                
                guard let e = set.entryForXIndex(xIndex) as? CandleChartDataEntry else { continue }
                
                if e.xIndex != xIndex
                {
                    continue
                }
                
                let trans = dataProvider.getTransformer(set.axisDependency)
                
                CGContextSetStrokeColorWithColor(context, set.highlightColor.CGColor)
                CGContextSetLineWidth(context, set.highlightLineWidth)
                if (set.highlightLineDashLengths != nil)
                {
                    CGContextSetLineDash(context, set.highlightLineDashPhase, set.highlightLineDashLengths!, set.highlightLineDashLengths!.count)
                }
                else
                {
                    CGContextSetLineDash(context, 0.0, nil, 0)
                }
                
                let lowValue = CGFloat(e.low) * animator.phaseY
                let highValue = CGFloat(e.high) * animator.phaseY
                let y = (lowValue + highValue) / 2.0
                
                _highlightPointBuffer.x = CGFloat(xIndex)
                _highlightPointBuffer.y = y
                
                trans.pointValueToPixel(&_highlightPointBuffer)
                
                // draw the lines
                drawHighlightLines(context: context, point: _highlightPointBuffer, set: set)
            }
        }
        
        CGContextRestoreGState(context)
    }
}