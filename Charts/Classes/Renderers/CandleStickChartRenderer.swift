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

@objc
public protocol CandleStickChartRendererDelegate
{
    func candleStickChartRendererCandleData(renderer: CandleStickChartRenderer) -> CandleChartData!
    func candleStickChartRenderer(renderer: CandleStickChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!
    func candleStickChartDefaultRendererValueFormatter(renderer: CandleStickChartRenderer) -> NSNumberFormatter!
    func candleStickChartRendererChartYMax(renderer: CandleStickChartRenderer) -> Double
    func candleStickChartRendererChartYMin(renderer: CandleStickChartRenderer) -> Double
    func candleStickChartRendererChartXMax(renderer: CandleStickChartRenderer) -> Double
    func candleStickChartRendererChartXMin(renderer: CandleStickChartRenderer) -> Double
    func candleStickChartRendererMaxVisibleValueCount(renderer: CandleStickChartRenderer) -> Int
}

public class CandleStickChartRenderer: LineScatterCandleRadarChartRenderer
{
    public weak var delegate: CandleStickChartRendererDelegate?
    
    public init(delegate: CandleStickChartRendererDelegate?, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.delegate = delegate
    }
    
    public override func drawData(#context: CGContext)
    {
        var candleData = delegate!.candleStickChartRendererCandleData(self)

        for set in candleData.dataSets as! [CandleChartDataSet]
        {
            if (set.isVisible)
            {
                drawDataSet(context: context, dataSet: set)
            }
        }
    }
    
    private var _shadowPoints = [CGPoint](count: 2, repeatedValue: CGPoint())
    private var _bodyRect = CGRect()
    private var _lineSegments = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    internal func drawDataSet(#context: CGContext, dataSet: CandleChartDataSet)
    {
        
        var trans = delegate!.candleStickChartRenderer(self, transformerForAxis: dataSet.axisDependency)
        
        var phaseX = _animator.phaseX
        var phaseY = _animator.phaseY
        var bodySpace = dataSet.bodySpace
        
        var entries = dataSet.yVals as! [CandleChartDataEntry]
        
        var entryFrom = dataSet.entryForXIndex(_minX)
        var entryTo = dataSet.entryForXIndex(_maxX)
        
        var minx = max(dataSet.entryIndex(entry: entryFrom!, isEqual: true), 0)
        var maxx = min(dataSet.entryIndex(entry: entryTo!, isEqual: true) + 1, entries.count)
        
        CGContextSaveGState(context)
        
        CGContextSetLineWidth(context, dataSet.shadowWidth)
        
        for (var j = minx, count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))); j < count; j++)
        {
            // get the entry
            var e = entries[j]
            
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
                var color = dataSet.decreasingColor ?? dataSet.colorAt(j)
                
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
                
                var color = dataSet.increasingColor ?? dataSet.colorAt(j)
                
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
    
    public override func drawValues(#context: CGContext)
    {
        var candleData = delegate!.candleStickChartRendererCandleData(self)
        if (candleData === nil)
        {
            return
        }
        
        var defaultValueFormatter = delegate!.candleStickChartDefaultRendererValueFormatter(self)
        
        // if values are drawn
        if (candleData.yValCount < Int(ceil(CGFloat(delegate!.candleStickChartRendererMaxVisibleValueCount(self)) * viewPortHandler.scaleX)))
        {
            var dataSets = candleData.dataSets
            
            for (var i = 0; i < dataSets.count; i++)
            {
                var dataSet = dataSets[i]
                
                if (!dataSet.isDrawValuesEnabled)
                {
                    continue
                }
                
                var valueFont = dataSet.valueFont
                var valueTextColor = dataSet.valueTextColor
                
                var formatter = dataSet.valueFormatter
                if (formatter === nil)
                {
                    formatter = defaultValueFormatter
                }
                
                var trans = delegate!.candleStickChartRenderer(self, transformerForAxis: dataSet.axisDependency)
                
                var entries = dataSet.yVals as! [CandleChartDataEntry]
                
                var entryFrom = dataSet.entryForXIndex(_minX)
                var entryTo = dataSet.entryForXIndex(_maxX)
                
                var minx = max(dataSet.entryIndex(entry: entryFrom!, isEqual: true), 0)
                var maxx = min(dataSet.entryIndex(entry: entryTo!, isEqual: true) + 1, entries.count)
                
                var positions = trans.generateTransformedValuesCandle(entries, phaseY: _animator.phaseY)
                
                var lineHeight = valueFont.lineHeight
                var yOffset: CGFloat = lineHeight + 5.0
                
                for (var j = minx, count = Int(ceil(CGFloat(maxx - minx) * _animator.phaseX + CGFloat(minx))); j < count; j++)
                {
                    var x = positions[j].x
                    var y = positions[j].y
                    
                    if (!viewPortHandler.isInBoundsRight(x))
                    {
                        break
                    }
                    
                    if (!viewPortHandler.isInBoundsLeft(x) || !viewPortHandler.isInBoundsY(y))
                    {
                        continue
                    }
                    
                    var val = entries[j].high
                    
                    ChartUtils.drawText(context: context, text: formatter!.stringFromNumber(val)!, point: CGPoint(x: x, y: y - yOffset), align: .Center, attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: valueTextColor])
                }
            }
        }
    }
    
    public override func drawExtras(#context: CGContext)
    {
    }
    
    private var _highlightPtsBuffer = [CGPoint](count: 4, repeatedValue: CGPoint())
    public override func drawHighlighted(#context: CGContext, indices: [ChartHighlight])
    {
        var candleData = delegate!.candleStickChartRendererCandleData(self)
        if (candleData === nil)
        {
            return
        }
        
        for (var i = 0; i < indices.count; i++)
        {
            var xIndex = indices[i].xIndex; // get the x-position
            
            var set = candleData.getDataSetByIndex(indices[i].dataSetIndex) as! CandleChartDataSet!
            
            if (set === nil || !set.isHighlightEnabled)
            {
                continue
            }
            
            var e = set.entryForXIndex(xIndex) as! CandleChartDataEntry!
            
            if (e === nil || e.xIndex != xIndex)
            {
                continue
            }
            
            var trans = delegate!.candleStickChartRenderer(self, transformerForAxis: set.axisDependency)
            
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
            
            var low = CGFloat(e.low) * _animator.phaseY
            var high = CGFloat(e.high) * _animator.phaseY
            var y = (low + high) / 2.0
            
            _highlightPtsBuffer[0] = CGPoint(x: CGFloat(xIndex), y: CGFloat(delegate!.candleStickChartRendererChartYMax(self)))
            _highlightPtsBuffer[1] = CGPoint(x: CGFloat(xIndex), y: CGFloat(delegate!.candleStickChartRendererChartYMin(self)))
            _highlightPtsBuffer[2] = CGPoint(x: CGFloat(delegate!.candleStickChartRendererChartXMin(self)), y: y)
            _highlightPtsBuffer[3] = CGPoint(x: CGFloat(delegate!.candleStickChartRendererChartXMax(self)), y: y)
            
            trans.pointValuesToPixel(&_highlightPtsBuffer)
            
            // draw the lines
            drawHighlightLines(context: context, points: _highlightPtsBuffer,
                horizontal: set.isHorizontalHighlightIndicatorEnabled, vertical: set.isVerticalHighlightIndicatorEnabled)
        }
    }
}