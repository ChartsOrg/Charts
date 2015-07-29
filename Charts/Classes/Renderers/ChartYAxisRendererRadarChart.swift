//
//  ChartYAxisRendererRadarChart.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 3/3/15.
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

public class ChartYAxisRendererRadarChart: ChartYAxisRenderer
{
    private weak var _chart: RadarChartView!
    
    public init(viewPortHandler: ChartViewPortHandler, yAxis: ChartYAxis, chart: RadarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, yAxis: yAxis, transformer: nil)
        
        _chart = chart
    }
 
    public override func computeAxis(#yMin: Double, yMax: Double)
    {
        computeAxisValues(min: yMin, max: yMax)
    }
    
    internal override func computeAxisValues(min yMin: Double, max yMax: Double)
    {
        var labelCount = _yAxis.labelCount
        var range = abs(yMax - yMin)
        
        if (labelCount == 0 || range <= 0)
        {
            _yAxis.entries = [Double]()
            return
        }
        
        var rawInterval = range / Double(labelCount)
        var interval = ChartUtils.roundToNextSignificant(number: Double(rawInterval))
        var intervalMagnitude = pow(10.0, round(log10(interval)))
        var intervalSigDigit = Int(interval / intervalMagnitude)
        
        if (intervalSigDigit > 5)
        {
            // Use one order of magnitude higher, to avoid intervals like 0.9 or
            // 90
            interval = floor(10 * intervalMagnitude)
        }
        
        // force label count
        if _yAxis.isForceLabelsEnabled
        {
            let step = Double(range) / Double(labelCount - 1)
            
            if _yAxis.entries.count < labelCount
            {
                // Ensure stops contains at least numStops elements.
                _yAxis.entries.removeAll(keepCapacity: true)
            }
            else
            {
                _yAxis.entries = [Double]()
                _yAxis.entries.reserveCapacity(labelCount)
            }
            
            var v = yMin
            
            for (var i = 0; i < labelCount; i++)
            {
                _yAxis.entries.append(v)
                v += step
            }
            
        } else {
            // no forced count
            
            // clean old values
            if (_yAxis.entries.count > 0)
            {
                _yAxis.entries.removeAll(keepCapacity: false)
            }
            
            // if the labels should only show min and max
            if (_yAxis.isShowOnlyMinMaxEnabled)
            {
                _yAxis.entries = [Double]()
                _yAxis.entries.append(yMin)
                _yAxis.entries.append(yMax)
            }
            else
            {
                var first = ceil(Double(yMin) / interval) * interval
                
                if (first == 0.0)
                { // Fix for IEEE negative zero case (Where value == -0.0, and 0.0 == -0.0)
                    first = 0.0
                }
                
                var last = ChartUtils.nextUp(floor(Double(yMax) / interval) * interval)
                
                var f: Double
                var i: Int
                var n = 0
                for (f = first; f <= last; f += interval)
                {
                    ++n
                }
                
                if (isnan(_yAxis.customAxisMax))
                {
                    n += 1
                }
                
                if (_yAxis.entries.count < n)
                {
                    // Ensure stops contains at least numStops elements.
                    _yAxis.entries = [Double](count: n, repeatedValue: 0.0)
                }
                
                for (f = first, i = 0; i < n; f += interval, ++i)
                {
                    _yAxis.entries[i] = Double(f)
                }
            }
        }
        
        _yAxis.axisMaximum = _yAxis.entries[_yAxis.entryCount - 1]
        _yAxis.axisRange = abs(_yAxis.axisMaximum - _yAxis.axisMinimum)
    }
    
    public override func renderAxisLabels(#context: CGContext)
    {
        if (!_yAxis.isEnabled || !_yAxis.isDrawLabelsEnabled)
        {
            return
        }
        
        var labelFont = _yAxis.labelFont
        var labelTextColor = _yAxis.labelTextColor
        
        var center = _chart.centerOffsets
        var factor = _chart.factor
        
        var labelCount = _yAxis.entryCount
        
        var labelLineHeight = _yAxis.labelFont.lineHeight
        
        for (var j = 0; j < labelCount; j++)
        {
            if (j == labelCount - 1 && _yAxis.isDrawTopYLabelEntryEnabled == false)
            {
                break
            }
            
            var r = CGFloat(_yAxis.entries[j] - _yAxis.axisMinimum) * factor
            
            var p = ChartUtils.getPosition(center: center, dist: r, angle: _chart.rotationAngle)
            
            var label = _yAxis.getFormattedLabel(j)
            
            ChartUtils.drawText(context: context, text: label, point: CGPoint(x: p.x + 10.0, y: p.y - labelLineHeight), align: .Left, attributes: [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: labelTextColor])
        }
    }
    
    public override func renderLimitLines(#context: CGContext)
    {
        var limitLines = _yAxis.limitLines
        
        if (limitLines.count == 0)
        {
            return
        }
        
        CGContextSaveGState(context)
        
        var sliceangle = _chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        var factor = _chart.factor
        
        var center = _chart.centerOffsets
        
        for (var i = 0; i < limitLines.count; i++)
        {
            var l = limitLines[i]
            
            CGContextSetStrokeColorWithColor(context, l.lineColor.CGColor)
            CGContextSetLineWidth(context, l.lineWidth)
            if (l.lineDashLengths != nil)
            {
                CGContextSetLineDash(context, l.lineDashPhase, l.lineDashLengths!, l.lineDashLengths!.count)
            }
            else
            {
                CGContextSetLineDash(context, 0.0, nil, 0)
            }
            
            var r = CGFloat(l.limit - _chart.chartYMin) * factor
            
            CGContextBeginPath(context)
            
            for (var j = 0, count = _chart.data!.xValCount; j < count; j++)
            {
                var p = ChartUtils.getPosition(center: center, dist: r, angle: sliceangle * CGFloat(j) + _chart.rotationAngle)
                
                if (j == 0)
                {
                    CGContextMoveToPoint(context, p.x, p.y)
                }
                else
                {
                    CGContextAddLineToPoint(context, p.x, p.y)
                }
            }
            
            CGContextClosePath(context)
            
            CGContextStrokePath(context)
        }
        
        CGContextRestoreGState(context)
    }
}