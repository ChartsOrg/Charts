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
    private weak var chart: RadarChartView?
    
    public init(viewPortHandler: ChartViewPortHandler, yAxis: ChartYAxis, chart: RadarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, yAxis: yAxis, transformer: nil)
        
        self.chart = chart
    }
    
    public override func computeAxis(yMin yMin: Double, yMax: Double)
    {
        computeAxisValues(min: yMin, max: yMax)
    }
    
    public override func computeAxisValues(min yMin: Double, max yMax: Double)
    {
        guard let yAxis = yAxis else { return }
        
        let labelCount = yAxis.labelCount
        let range = abs(yMax - yMin)
        
        if (labelCount == 0 || range <= 0)
        {
            yAxis.entries = [Double]()
            return
        }
        
        let rawInterval = range / Double(labelCount)
        var interval = ChartUtils.roundToNextSignificant(number: Double(rawInterval))
        let intervalMagnitude = pow(10.0, round(log10(interval)))
        let intervalSigDigit = Int(interval / intervalMagnitude)
        
        if (intervalSigDigit > 5)
        {
            // Use one order of magnitude higher, to avoid intervals like 0.9 or
            // 90
            interval = floor(10 * intervalMagnitude)
        }
        
        // force label count
        if yAxis.isForceLabelsEnabled
        {
            let step = Double(range) / Double(labelCount - 1)
            
            if yAxis.entries.count < labelCount
            {
                // Ensure stops contains at least numStops elements.
                yAxis.entries.removeAll(keepCapacity: true)
            }
            else
            {
                yAxis.entries = [Double]()
                yAxis.entries.reserveCapacity(labelCount)
            }
            
            var v = yMin
            
            for (var i = 0; i < labelCount; i++)
            {
                yAxis.entries.append(v)
                v += step
            }
            
        }
        else
        {
            // no forced count
            
            // clean old values
            if (yAxis.entries.count > 0)
            {
                yAxis.entries.removeAll(keepCapacity: false)
            }
            
            // if the labels should only show min and max
            if (yAxis.isShowOnlyMinMaxEnabled)
            {
                yAxis.entries = [Double]()
                yAxis.entries.append(yMin)
                yAxis.entries.append(yMax)
            }
            else
            {
                let rawCount = Double(yMin) / interval
                var first = rawCount < 0.0 ? floor(rawCount) * interval : ceil(rawCount) * interval;
                
                if (first < yMin && yAxis.isStartAtZeroEnabled)
                { // Force the first label to be at the 0 (or smallest negative value)
                    first = yMin
                }
                
                if (first == 0.0)
                { // Fix for IEEE negative zero case (Where value == -0.0, and 0.0 == -0.0)
                    first = 0.0
                }
                
                let last = ChartUtils.nextUp(floor(Double(yMax) / interval) * interval)
                
                var f: Double
                var i: Int
                var n = 0
                for (f = first; f <= last; f += interval)
                {
                    ++n
                }
                
                if (isnan(yAxis.customAxisMax))
                {
                    n += 1
                }
                
                if (yAxis.entries.count < n)
                {
                    // Ensure stops contains at least numStops elements.
                    yAxis.entries = [Double](count: n, repeatedValue: 0.0)
                }
                
                for (f = first, i = 0; i < n; f += interval, ++i)
                {
                    yAxis.entries[i] = Double(f)
                }
            }
        }
        
        if !yAxis.isStartAtZeroEnabled && yAxis.entries[0] < yMin
        {
            // If startAtZero is disabled, and the first label is lower that the axis minimum,
            // Then adjust the axis minimum
            yAxis.axisMinimum = yAxis.entries[0]
        }
        yAxis.axisMaximum = yAxis.entries[yAxis.entryCount - 1]
        yAxis.axisRange = abs(yAxis.axisMaximum - yAxis.axisMinimum)
    }
    
    public override func renderAxisLabels(context context: CGContext)
    {
        guard let
            yAxis = yAxis,
            chart = chart
            else { return }
        
        if (!yAxis.isEnabled || !yAxis.isDrawLabelsEnabled)
        {
            return
        }
        
        let labelFont = yAxis.labelFont
        let labelTextColor = yAxis.labelTextColor
        
        let center = chart.centerOffsets
        let factor = chart.factor
        
        let labelCount = yAxis.entryCount
        
        let labelLineHeight = yAxis.labelFont.lineHeight
        
        for (var j = 0; j < labelCount; j++)
        {
            if (j == labelCount - 1 && yAxis.isDrawTopYLabelEntryEnabled == false)
            {
                break
            }
            
            let r = CGFloat(yAxis.entries[j] - yAxis.axisMinimum) * factor
            
            let p = ChartUtils.getPosition(center: center, dist: r, angle: chart.rotationAngle)
            
            let label = yAxis.getFormattedLabel(j)
            
            ChartUtils.drawText(context: context, text: label, point: CGPoint(x: p.x + 10.0, y: p.y - labelLineHeight), align: .Left, attributes: [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: labelTextColor])
        }
    }
    
    public override func renderLimitLines(context context: CGContext)
    {
        guard let
            yAxis = yAxis,
            chart = chart
            else { return }
        
        var limitLines = yAxis.limitLines
        
        if (limitLines.count == 0)
        {
            return
        }
        
        CGContextSaveGState(context)
        
        let sliceangle = chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        let factor = chart.factor
        
        let center = chart.centerOffsets
        
        for (var i = 0; i < limitLines.count; i++)
        {
            let l = limitLines[i]
            
            if !l.isEnabled
            {
                continue
            }
            
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
            
            let r = CGFloat(l.limit - chart.chartYMin) * factor
            
            CGContextBeginPath(context)
            
            for (var j = 0, count = chart.data!.xValCount; j < count; j++)
            {
                let p = ChartUtils.getPosition(center: center, dist: r, angle: sliceangle * CGFloat(j) + chart.rotationAngle)
                
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