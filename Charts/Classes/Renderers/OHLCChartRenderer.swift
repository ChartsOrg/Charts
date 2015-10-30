//
//  OHLCChartRenderer.swift
//  Charts
//
//  Based on CandleStickChartRenderer by Daniel Cohen Gindi
//  Created by John Casley on 10/22/15.
//  Copyright © 2015 John Casley. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

public class OHLCChartRenderer: LineScatterCandleRadarChartRenderer
{
    public weak var dataProvider: OHLCChartDataProvider?
    
    public init(dataProvider: OHLCChartDataProvider?, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        self.dataProvider = dataProvider
    }
    
    public override func drawData(context context: CGContext)
    {
        guard let dataProvider = dataProvider, ohlcData = dataProvider.ohlcData else { return }
        
        for set in ohlcData.dataSets as! [OHLCChartDataSet]
        {
            if set.isVisible && set.entryCount > 0
            {
                drawDataSet(context: context, dataSet: set)
            }
        }
    }

    
    private var _rangePoints = [CGPoint](count: 2, repeatedValue: CGPoint())
    private var _openPoints = [CGPoint](count: 2, repeatedValue: CGPoint())
    private var _closePoints = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    internal func drawDataSet(context context: CGContext, dataSet: OHLCChartDataSet)
    {
        guard let trans = dataProvider?.getTransformer(dataSet.axisDependency) else { return }
        
        let phaseX = _animator.phaseX
        let phaseY = _animator.phaseY
        let barSpace = dataSet.barSpace
        
        var entries = dataSet.yVals as! [OHLCChartDataEntry]
        
        let minx = max(_minX, 0)
        let maxx = min(_maxX + 1, entries.count)
        
        CGContextSaveGState(context)
        
        CGContextSetLineWidth(context, dataSet.barWidth)
        
        for (var j = minx, count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))); j < count; j++)
        {
            let e = entries[j]
            
            if (e.xIndex < _minX || e.xIndex > _maxX)
            {
                continue
            }
            
            _rangePoints[0].x = CGFloat(e.xIndex)
            _rangePoints[0].y = CGFloat(e.high) * phaseY
            _rangePoints[1].x = CGFloat(e.xIndex)
            _rangePoints[1].y = CGFloat(e.low) * phaseY
            
            _openPoints[0].x = CGFloat(e.xIndex) - 0.5 + barSpace
            _openPoints[0].y = CGFloat(e.open) * phaseY
            _openPoints[1].x = CGFloat(e.xIndex)
            _openPoints[1].y = CGFloat(e.open) * phaseY
            
            _closePoints[0].x = CGFloat(e.xIndex) + 0.5 - barSpace
            _closePoints[0].y = CGFloat(e.close) * phaseY
            _closePoints[1].x = CGFloat(e.xIndex)
            _closePoints[1].y = CGFloat(e.close) * phaseY
            
            trans.pointValuesToPixel(&_rangePoints)
            trans.pointValuesToPixel(&_openPoints)
            trans.pointValuesToPixel(&_closePoints)
            
            // draw the ranges
            var barColor: UIColor! = nil
            if (e.open > e.close)
            {
                barColor = dataSet.decreasingColor ?? dataSet.colorAt(j)
            }
            else if (e.open < e.close)
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
        
        CGContextRestoreGState(context)
    }
    public override func drawValues(context context: CGContext)
    {
        guard let dataProvider = dataProvider, ohlcData = dataProvider.ohlcData else { return }
        
        // if values are drawn
        if (ohlcData.yValCount < Int(ceil(CGFloat(dataProvider.maxVisibleValueCount) * viewPortHandler.scaleX)))
        {
            var dataSets = ohlcData.dataSets
            
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
                
                var entries = dataSet.yVals as! [CandleChartDataEntry]
                
                let minx = max(_minX, 0)
                let maxx = min(_maxX + 1, entries.count)
                
                var positions = trans.generateTransformedValuesCandle(entries, phaseY: _animator.phaseY)
                
                let lineHeight = valueFont.lineHeight
                let yOffset: CGFloat = lineHeight + 5.0
                
                for (var j = minx, count = Int(ceil(CGFloat(maxx - minx) * _animator.phaseX + CGFloat(minx))); j < count; j++)
                {
                    let x = positions[j].x
                    let y = positions[j].y
                    
                    if (!viewPortHandler.isInBoundsRight(x))
                    {
                        break
                    }
                    
                    if (!viewPortHandler.isInBoundsLeft(x) || !viewPortHandler.isInBoundsY(y))
                    {
                        continue
                    }
                    
                    let val = entries[j].high
                    
                    ChartUtils.drawText(context: context, text: formatter!.stringFromNumber(val)!, point: CGPoint(x: x, y: y - yOffset), align: .Center, attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: valueTextColor])
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
        guard let dataProvider = dataProvider, ohlcData = dataProvider.ohlcData else { return }
        
        CGContextSaveGState(context)
        
        for (var i = 0; i < indices.count; i++)
        {
            let xIndex = indices[i].xIndex; // get the x-position
            
            let set = ohlcData.getDataSetByIndex(indices[i].dataSetIndex) as! OHLCChartDataSet!
            
            if (set === nil || !set.isHighlightEnabled)
            {
                continue
            }
            
            let e = set.entryForXIndex(xIndex) as! OHLCChartDataEntry!
            
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