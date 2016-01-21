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
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics
import UIKit

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
    
    private var _shadowPoints = [CGPoint](count: 2, repeatedValue: CGPoint())
    private var _bodyRect = CGRect()
    private var _lineSegments = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    internal func drawDataSet(context context: CGContext, dataSet: ICandleChartDataSet)
    {
        guard let trans = dataProvider?.getTransformer(dataSet.axisDependency) else { return }
        
        let phaseX = _animator.phaseX
        let phaseY = _animator.phaseY
        let bodySpace = dataSet.bodySpace
        
        let entryCount = dataSet.entryCount
        
        let minx = max(_minX, 0)
        let maxx = min(_maxX + 1, entryCount)
        
        CGContextSaveGState(context)
        
        CGContextSetLineWidth(context, dataSet.shadowWidth)
        
        for (var j = minx, count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))); j < count; j++)
        {
            // get the entry
            guard let e = dataSet.entryForIndex(j) as? CandleChartDataEntry else { continue }
            
            if (e.xIndex < _minX || e.xIndex > _maxX)
            {
                continue
            }
            
            // calculate the shadow
            
            _shadowPoints[0].x = CGFloat(e.xIndex)
            _shadowPoints[0].y = CGFloat(e.high) * phaseY
            _shadowPoints[1].x = CGFloat(e.xIndex)
            _shadowPoints[1].y = CGFloat(e.low) * phaseY
            
            trans.pointValuesToPixel(&_shadowPoints)
            
            // draw the shadow
            
            var shadowColor: UIColor! = nil
            if (dataSet.shadowColorSameAsCandle)
            {
                if (e.open > e.close)
                {
                    shadowColor = dataSet.decreasingColor ?? dataSet.colorAt(j)
                }
                else if (e.open < e.close)
                {
                    shadowColor = dataSet.increasingColor ?? dataSet.colorAt(j)
                }
            }
            
            if (shadowColor === nil)
            {
                shadowColor = dataSet.shadowColor ?? dataSet.colorAt(j);
            }
            
            CGContextSetStrokeColorWithColor(context, shadowColor.CGColor)
            CGContextStrokeLineSegments(context, _shadowPoints, 2)
            
            // calculate the body
            
            _bodyRect.origin.x = CGFloat(e.xIndex) - 0.5 + bodySpace
            _bodyRect.origin.y = CGFloat(e.close) * phaseY
            _bodyRect.size.width = (CGFloat(e.xIndex) + 0.5 - bodySpace) - _bodyRect.origin.x
            _bodyRect.size.height = (CGFloat(e.open) * phaseY) - _bodyRect.origin.y
            
            trans.rectValueToPixel(&_bodyRect)
            
            // draw body differently for increasing and decreasing entry
            
            if (e.open > e.close)
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
            else if (e.open < e.close)
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
                CGContextSetStrokeColorWithColor(context, shadowColor.CGColor)
                CGContextStrokeRect(context, _bodyRect)
            }
        }
        
        CGContextRestoreGState(context)
    }
    
    public override func drawValues(context context: CGContext)
    {
        guard let dataProvider = dataProvider, candleData = dataProvider.candleData else { return }
        
        // if values are drawn
        if (candleData.yValCount < Int(ceil(CGFloat(dataProvider.maxVisibleValueCount) * viewPortHandler.scaleX)))
        {
            var dataSets = candleData.dataSets
            
            let phaseX = _animator.phaseX
            let phaseY = _animator.phaseY
            
            var pt = CGPoint()
            
            for (var i = 0; i < dataSets.count; i++)
            {
                let dataSet = dataSets[i]
                
                if !dataSet.isDrawValuesEnabled || dataSet.entryCount == 0
                {
                    continue
                }
                
                let valueFont = dataSet.valueFont
                let valueTextColor = dataSet.valueTextColor
                
                let formatter = dataSet.valueFormatter
                
                let trans = dataProvider.getTransformer(dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                let entryCount = dataSet.entryCount
                
                let minx = max(_minX, 0)
                let maxx = min(_maxX + 1, entryCount)
                
                let lineHeight = valueFont.lineHeight
                let yOffset: CGFloat = lineHeight + 5.0
                
                for (var j = minx, count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))); j < count; j++)
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
                        text: formatter!.stringFromNumber(e.high)!,
                        point: CGPoint(
                            x: pt.x,
                            y: pt.y - yOffset),
                        align: .Center,
                        attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: valueTextColor])
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
        guard let dataProvider = dataProvider, candleData = dataProvider.candleData else { return }
        
        CGContextSaveGState(context)
        
        for (var i = 0; i < indices.count; i++)
        {
            let xIndex = indices[i].xIndex; // get the x-position
            
            let set = candleData.getDataSetByIndex(indices[i].dataSetIndex) as! ICandleChartDataSet!
            
            if (set === nil || !set.isHighlightEnabled)
            {
                continue
            }
            
            let e = set.entryForXIndex(xIndex) as! CandleChartDataEntry!
            
            if (e === nil || e.xIndex != xIndex)
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
            
            let low = CGFloat(e.low) * _animator.phaseY
            let high = CGFloat(e.high) * _animator.phaseY
            let y = (low + high) / 2.0
            
            _highlightPointBuffer.x = CGFloat(xIndex)
            _highlightPointBuffer.y = y
            
            trans.pointValueToPixel(&_highlightPointBuffer)
            
            // draw the lines
            drawHighlightLines(context: context, point: _highlightPointBuffer, set: set)
        }
        
        CGContextRestoreGState(context)
    }
}