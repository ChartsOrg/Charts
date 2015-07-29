//
//  RadarChartRenderer.swift
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

public class RadarChartRenderer: LineScatterCandleRadarChartRenderer
{
    internal weak var _chart: RadarChartView!

    public init(chart: RadarChartView, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        _chart = chart
    }
    
    public override func drawData(#context: CGContext)
    {
        if (_chart !== nil)
        {
            var radarData = _chart.data
            
            if (radarData != nil)
            {
                for set in radarData!.dataSets as! [RadarChartDataSet]
                {
                    if (set.isVisible)
                    {
                        drawDataSet(context: context, dataSet: set)
                    }
                }
            }
        }
    }
    
    internal func drawDataSet(#context: CGContext, dataSet: RadarChartDataSet)
    {
        CGContextSaveGState(context)
        
        var sliceangle = _chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        var factor = _chart.factor
        
        var center = _chart.centerOffsets
        var entries = dataSet.yVals
        var path = CGPathCreateMutable()
        var hasMovedToPoint = false
        
        for (var j = 0; j < entries.count; j++)
        {
            var e = entries[j]
            
            var p = ChartUtils.getPosition(center: center, dist: CGFloat(e.value - _chart.chartYMin) * factor, angle: sliceangle * CGFloat(j) + _chart.rotationAngle)
            
            if (p.x.isNaN)
            {
                continue
            }
            
            if (!hasMovedToPoint)
            {
                CGPathMoveToPoint(path, nil, p.x, p.y)
                hasMovedToPoint = true
            }
            else
            {
                CGPathAddLineToPoint(path, nil, p.x, p.y)
            }
        }
        
        CGPathCloseSubpath(path)
        
        // draw filled
        if (dataSet.isDrawFilledEnabled)
        {
            CGContextSetFillColorWithColor(context, dataSet.colorAt(0).CGColor)
            CGContextSetAlpha(context, dataSet.fillAlpha)
            
            CGContextBeginPath(context)
            CGContextAddPath(context, path)
            CGContextFillPath(context)
        }
        
        // draw the line (only if filled is disabled or alpha is below 255)
        if (!dataSet.isDrawFilledEnabled || dataSet.fillAlpha < 1.0)
        {
            CGContextSetStrokeColorWithColor(context, dataSet.colorAt(0).CGColor)
            CGContextSetLineWidth(context, dataSet.lineWidth)
            CGContextSetAlpha(context, 1.0)
            
            CGContextBeginPath(context)
            CGContextAddPath(context, path)
            CGContextStrokePath(context)
        }
        
        CGContextRestoreGState(context)
    }
    
    public override func drawValues(#context: CGContext)
    {
        if (_chart.data === nil)
        {
            return
        }
        
        var data = _chart.data!
        
        var defaultValueFormatter = _chart.valueFormatter
        
        var sliceangle = _chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        var factor = _chart.factor
        
        var center = _chart.centerOffsets
        
        var yoffset = CGFloat(5.0)
        
        for (var i = 0, count = data.dataSetCount; i < count; i++)
        {
            var dataSet = data.getDataSetByIndex(i) as! RadarChartDataSet
            
            if (!dataSet.isDrawValuesEnabled)
            {
                continue
            }
            
            var entries = dataSet.yVals
            
            for (var j = 0; j < entries.count; j++)
            {
                var e = entries[j]
                
                var p = ChartUtils.getPosition(center: center, dist: CGFloat(e.value) * factor, angle: sliceangle * CGFloat(j) + _chart.rotationAngle)
                
                var valueFont = dataSet.valueFont
                var valueTextColor = dataSet.valueTextColor
                
                var formatter = dataSet.valueFormatter
                if (formatter === nil)
                {
                    formatter = defaultValueFormatter
                }
                
                ChartUtils.drawText(context: context, text: formatter!.stringFromNumber(e.value)!, point: CGPoint(x: p.x, y: p.y - yoffset - valueFont.lineHeight), align: .Center, attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: valueTextColor])
            }
        }
    }
    
    public override func drawExtras(#context: CGContext)
    {
        drawWeb(context: context)
    }
    
    private var _webLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    internal func drawWeb(#context: CGContext)
    {
        var sliceangle = _chart.sliceAngle
        
        CGContextSaveGState(context)
        
        // calculate the factor that is needed for transforming the value to
        // pixels
        var factor = _chart.factor
        var rotationangle = _chart.rotationAngle
        
        var center = _chart.centerOffsets
        
        // draw the web lines that come from the center
        CGContextSetLineWidth(context, _chart.webLineWidth)
        CGContextSetStrokeColorWithColor(context, _chart.webColor.CGColor)
        CGContextSetAlpha(context, _chart.webAlpha)
        
        for (var i = 0, xValCount = _chart.data!.xValCount; i < xValCount; i++)
        {
            var p = ChartUtils.getPosition(center: center, dist: CGFloat(_chart.yRange) * factor, angle: sliceangle * CGFloat(i) + rotationangle)
            
            _webLineSegmentsBuffer[0].x = center.x
            _webLineSegmentsBuffer[0].y = center.y
            _webLineSegmentsBuffer[1].x = p.x
            _webLineSegmentsBuffer[1].y = p.y
            
            CGContextStrokeLineSegments(context, _webLineSegmentsBuffer, 2)
        }
        
        // draw the inner-web
        CGContextSetLineWidth(context, _chart.innerWebLineWidth)
        CGContextSetStrokeColorWithColor(context, _chart.innerWebColor.CGColor)
        CGContextSetAlpha(context, _chart.webAlpha)
        
        var labelCount = _chart.yAxis.entryCount
        
        for (var j = 0; j < labelCount; j++)
        {
            for (var i = 0, xValCount = _chart.data!.xValCount; i < xValCount; i++)
            {
                var r = CGFloat(_chart.yAxis.entries[j] - _chart.chartYMin) * factor

                var p1 = ChartUtils.getPosition(center: center, dist: r, angle: sliceangle * CGFloat(i) + rotationangle)
                var p2 = ChartUtils.getPosition(center: center, dist: r, angle: sliceangle * CGFloat(i + 1) + rotationangle)
                
                _webLineSegmentsBuffer[0].x = p1.x
                _webLineSegmentsBuffer[0].y = p1.y
                _webLineSegmentsBuffer[1].x = p2.x
                _webLineSegmentsBuffer[1].y = p2.y
                
                CGContextStrokeLineSegments(context, _webLineSegmentsBuffer, 2)
            }
        }
        
        CGContextRestoreGState(context)
    }
    
    private var _highlightPtsBuffer = [CGPoint](count: 4, repeatedValue: CGPoint())

    public override func drawHighlighted(#context: CGContext, indices: [ChartHighlight])
    {
        if (_chart.data === nil)
        {
            return
        }
        
        var data = _chart.data as! RadarChartData
        
        CGContextSaveGState(context)
        CGContextSetLineWidth(context, data.highlightLineWidth)
        if (data.highlightLineDashLengths != nil)
        {
            CGContextSetLineDash(context, data.highlightLineDashPhase, data.highlightLineDashLengths!, data.highlightLineDashLengths!.count)
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0)
        }
        
        var sliceangle = _chart.sliceAngle
        var factor = _chart.factor
        
        var center = _chart.centerOffsets
        
        for (var i = 0; i < indices.count; i++)
        {
            var set = _chart.data?.getDataSetByIndex(indices[i].dataSetIndex) as! RadarChartDataSet!
            
            if (set === nil || !set.isHighlightEnabled)
            {
                continue
            }
            
            CGContextSetStrokeColorWithColor(context, set.highlightColor.CGColor)
            
            // get the index to highlight
            var xIndex = indices[i].xIndex
            
            var e = set.entryForXIndex(xIndex)
            if (e === nil || e!.xIndex != xIndex)
            {
                continue
            }
            
            var j = set.entryIndex(entry: e!, isEqual: true)
            var y = (e!.value - _chart.chartYMin)
            
            if (y.isNaN)
            {
                continue
            }
            
            var p = ChartUtils.getPosition(center: center, dist: CGFloat(y) * factor,
                angle: sliceangle * CGFloat(j) + _chart.rotationAngle)
            
            _highlightPtsBuffer[0] = CGPoint(x: p.x, y: 0.0)
            _highlightPtsBuffer[1] = CGPoint(x: p.x, y: viewPortHandler.chartHeight)
            _highlightPtsBuffer[2] = CGPoint(x: 0.0, y: p.y)
            _highlightPtsBuffer[3] = CGPoint(x: viewPortHandler.chartWidth, y: p.y)
            
            // draw the lines
            drawHighlightLines(context: context, points: _highlightPtsBuffer,
                horizontal: set.isHorizontalHighlightIndicatorEnabled, vertical: set.isVerticalHighlightIndicatorEnabled)
        }
        
        CGContextRestoreGState(context)
    }
}