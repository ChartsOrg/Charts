//
//  ChartYAxisRenderer.swift
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

#if !os(OSX)
    import UIKit
#endif


public class ChartYAxisRenderer: ChartAxisRendererBase
{
    public var yAxis: ChartYAxis?
    
    public init(viewPortHandler: ChartViewPortHandler, yAxis: ChartYAxis, transformer: ChartTransformer!)
    {
        super.init(viewPortHandler: viewPortHandler, transformer: transformer)
        
        self.yAxis = yAxis
    }
    
    /// Computes the axis values.
    public func computeAxis(yMin yMin: Double, yMax: Double)
    {
        guard let yAxis = yAxis else { return }
        var yMin = yMin, yMax = yMax
        
        // calculate the starting and entry point of the y-labels (depending on
        // zoom / contentrect bounds)
        if (viewPortHandler.contentWidth > 10.0 && !viewPortHandler.isFullyZoomedOutY)
        {
            let p1 = transformer.getValueByTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            let p2 = transformer.getValueByTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
            
            if (!yAxis.isInverted)
            {
                yMin = Double(p2.y)
                yMax = Double(p1.y)
            }
            else
            {
                yMin = Double(p1.y)
                yMax = Double(p2.y)
            }
        }
        
        computeAxisValues(min: yMin, max: yMax)
    }
    
    /// Sets up the y-axis labels. Computes the desired number of labels between
    /// the two given extremes. Unlike the papareXLabels() method, this method
    /// needs to be called upon every refresh of the view.
    public func computeAxisValues(min min: Double, max: Double)
    {
        guard let yAxis = yAxis else { return }
        
        let yMin = min
        let yMax = max
        
        let labelCount = yAxis.labelCount
        let range = abs(yMax - yMin)
    
        if (labelCount == 0 || range <= 0)
        {
            yAxis.entries = [Double]()
            return
        }
        
        // Find out how much spacing (in y value space) between axis values
        let rawInterval = range / Double(labelCount)
        var interval = ChartUtils.roundToNextSignificant(number: Double(rawInterval))
        
        // If granularity is enabled, then do not allow the interval to go below specified granularity.
        // This is used to avoid repeated values when rounding values for display.
        if yAxis.granularityEnabled
        {
            interval = interval < yAxis.granularity ? yAxis.granularity : interval
        }
        
        // Normalize interval
        let intervalMagnitude = ChartUtils.roundToNextSignificant(number: pow(10.0, floor(log10(interval))))
        let intervalSigDigit = (interval / intervalMagnitude)
        if (intervalSigDigit > 5)
        {
            // Use one order of magnitude higher, to avoid intervals like 0.9 or 90
            interval = floor(10.0 * intervalMagnitude)
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
            
            for _ in 0 ..< labelCount
            {
                yAxis.entries.append(v)
                v += step
            }
            
        }
        else
        {
            // no forced count
            
            // if the labels should only show min and max
            if (yAxis.isShowOnlyMinMaxEnabled)
            {
                yAxis.entries = [yMin, yMax]
            }
            else
            {
                let first = ceil(Double(yMin) / interval) * interval
                let last = ChartUtils.nextUp(floor(Double(yMax) / interval) * interval)
                
                var n = 0
                for _ in first.stride(through: last, by: interval)
                {
                    n += 1
                }
                
                if (yAxis.entries.count < n)
                {
                    // Ensure stops contains at least numStops elements.
                    yAxis.entries = [Double](count: n, repeatedValue: 0.0)
                }
                else if (yAxis.entries.count > n)
                {
                    yAxis.entries.removeRange(n..<yAxis.entries.count)
                }
                
                var f = first
                var i = 0
                while (i < n)
                {
                    if (f == 0.0)
                    { // Fix for IEEE negative zero case (Where value == -0.0, and 0.0 == -0.0)
                        f = 0.0
                    }
                    
                    yAxis.entries[i] = Double(f)
                    
                    f += interval
                    i += 1
                }
            }
        }
    }
    
    /// draws the y-axis labels to the screen
    public override func renderAxisLabels(context context: CGContext)
    {
        guard let yAxis = yAxis else { return }
        
        if (!yAxis.isEnabled || !yAxis.isDrawLabelsEnabled)
        {
            return
        }
        
        let xoffset = yAxis.xOffset
        let yoffset = yAxis.labelFont.lineHeight / 2.5 + yAxis.yOffset
        
        let dependency = yAxis.axisDependency
        let labelPosition = yAxis.labelPosition
        
        var xPos = CGFloat(0.0)
        
        var textAlign: NSTextAlignment
        
        if (dependency == .Left)
        {
            if (labelPosition == .OutsideChart)
            {
                textAlign = .Right
                xPos = viewPortHandler.offsetLeft - xoffset
            }
            else
            {
                textAlign = .Left
                xPos = viewPortHandler.offsetLeft + xoffset
            }
            
        }
        else
        {
            if (labelPosition == .OutsideChart)
            {
                textAlign = .Left
                xPos = viewPortHandler.contentRight + xoffset
            }
            else
            {
                textAlign = .Right
                xPos = viewPortHandler.contentRight - xoffset
            }
        }
        
        drawYLabels(context: context, fixedPosition: xPos, offset: yoffset - yAxis.labelFont.lineHeight, textAlign: textAlign)
    }
    
    private var _axisLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public override func renderAxisLine(context context: CGContext)
    {
        guard let yAxis = yAxis else { return }
        
        if (!yAxis.isEnabled || !yAxis.drawAxisLineEnabled)
        {
            return
        }
        
        CGContextSaveGState(context)
        
        CGContextSetStrokeColorWithColor(context, yAxis.axisLineColor.CGColor)
        CGContextSetLineWidth(context, yAxis.axisLineWidth)
        if (yAxis.axisLineDashLengths != nil)
        {
            CGContextSetLineDash(context, yAxis.axisLineDashPhase, yAxis.axisLineDashLengths, yAxis.axisLineDashLengths.count)
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0)
        }
        
        if (yAxis.axisDependency == .Left)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            CGContextStrokeLineSegments(context, _axisLineSegmentsBuffer, 2)
        }
        else
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            CGContextStrokeLineSegments(context, _axisLineSegmentsBuffer, 2)
        }
        
        CGContextRestoreGState(context)
    }
    
    /// draws the y-labels on the specified x-position
    internal func drawYLabels(context context: CGContext, fixedPosition: CGFloat, offset: CGFloat, textAlign: NSTextAlignment)
    {
        guard let yAxis = yAxis else { return }
        
        let labelFont = yAxis.labelFont
        let labelTextColor = yAxis.labelTextColor
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var pt = CGPoint()
        
        for i in 0 ..< yAxis.entryCount
        {
            let text = yAxis.getFormattedLabel(i)
            
            if (!yAxis.isDrawTopYLabelEntryEnabled && i >= yAxis.entryCount - 1)
            {
                break
            }
            
            pt.x = 0
            pt.y = CGFloat(yAxis.entries[i])
            pt = CGPointApplyAffineTransform(pt, valueToPixelMatrix)
            
            pt.x = fixedPosition
            pt.y += offset
            
            ChartUtils.drawText(context: context, text: text, point: pt, align: textAlign, attributes: [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: labelTextColor])
        }
    }
    
    private var _gridLineBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public override func renderGridLines(context context: CGContext)
    {
        guard let yAxis = yAxis else { return }
        
        if !yAxis.isEnabled
        {
            return
        }
        
        if yAxis.drawGridLinesEnabled
        {
            CGContextSaveGState(context)
            
            CGContextSetShouldAntialias(context, yAxis.gridAntialiasEnabled)
            CGContextSetStrokeColorWithColor(context, yAxis.gridColor.CGColor)
            CGContextSetLineWidth(context, yAxis.gridLineWidth)
            CGContextSetLineCap(context, yAxis.gridLineCap)
            
            if (yAxis.gridLineDashLengths != nil)
            {
                CGContextSetLineDash(context, yAxis.gridLineDashPhase, yAxis.gridLineDashLengths, yAxis.gridLineDashLengths.count)
            }
            else
            {
                CGContextSetLineDash(context, 0.0, nil, 0)
            }
            
            let valueToPixelMatrix = transformer.valueToPixelMatrix
            
            var position = CGPoint(x: 0.0, y: 0.0)
            
            // draw the horizontal grid
            for i in 0 ..< yAxis.entryCount
            {
                position.x = 0.0
                position.y = CGFloat(yAxis.entries[i])
                position = CGPointApplyAffineTransform(position, valueToPixelMatrix)
                
                _gridLineBuffer[0].x = viewPortHandler.contentLeft
                _gridLineBuffer[0].y = position.y
                _gridLineBuffer[1].x = viewPortHandler.contentRight
                _gridLineBuffer[1].y = position.y
                CGContextStrokeLineSegments(context, _gridLineBuffer, 2)
            }
            
            CGContextRestoreGState(context)
        }

        if yAxis.drawZeroLineEnabled
        {
            // draw zero line
            
            var position = CGPoint(x: 0.0, y: 0.0)
            transformer.pointValueToPixel(&position)
                
            drawZeroLine(context: context,
                x1: viewPortHandler.contentLeft,
                x2: viewPortHandler.contentRight,
                y1: position.y,
                y2: position.y);
        }
    }
    
    /// Draws the zero line at the specified position.
    public func drawZeroLine(
        context context: CGContext,
        x1: CGFloat,
        x2: CGFloat,
        y1: CGFloat,
        y2: CGFloat)
    {
        guard let
            yAxis = yAxis,
            zeroLineColor = yAxis.zeroLineColor
            else { return }
        
        CGContextSaveGState(context)
        
        CGContextSetStrokeColorWithColor(context, zeroLineColor.CGColor)
        CGContextSetLineWidth(context, yAxis.zeroLineWidth)
        
        if (yAxis.zeroLineDashLengths != nil)
        {
            CGContextSetLineDash(context, yAxis.zeroLineDashPhase, yAxis.zeroLineDashLengths!, yAxis.zeroLineDashLengths!.count)
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0)
        }
        
        CGContextMoveToPoint(context, x1, y1)
        CGContextAddLineToPoint(context, x2, y2)
        CGContextDrawPath(context, CGPathDrawingMode.Stroke)
        
        CGContextRestoreGState(context)
    }
    
    private var _limitLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public override func renderLimitLines(context context: CGContext)
    {
        guard let yAxis = yAxis else { return }
        
        var limitLines = yAxis.limitLines
        
        if (limitLines.count == 0)
        {
            return
        }
        
        CGContextSaveGState(context)
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for i in 0 ..< limitLines.count
        {
            let l = limitLines[i]
            
            if !l.isEnabled
            {
                continue
            }
            
            position.x = 0.0
            position.y = CGFloat(l.limit)
            position = CGPointApplyAffineTransform(position, trans)
            
            _limitLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _limitLineSegmentsBuffer[0].y = position.y
            _limitLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _limitLineSegmentsBuffer[1].y = position.y
            
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
            
            CGContextStrokeLineSegments(context, _limitLineSegmentsBuffer, 2)
            
            let label = l.label
            
            // if drawing the limit-value label is enabled
            if (label.characters.count > 0)
            {
                let labelLineHeight = l.valueFont.lineHeight
                
                let xOffset: CGFloat = 4.0 + l.xOffset
                let yOffset: CGFloat = l.lineWidth + labelLineHeight + l.yOffset
                
                if (l.labelPosition == .RightTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentRight - xOffset,
                            y: position.y - yOffset),
                        align: .Right,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else if (l.labelPosition == .RightBottom)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentRight - xOffset,
                            y: position.y + yOffset - labelLineHeight),
                        align: .Right,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else if (l.labelPosition == .LeftTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentLeft + xOffset,
                            y: position.y - yOffset),
                        align: .Left,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentLeft + xOffset,
                            y: position.y + yOffset - labelLineHeight),
                        align: .Left,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
            }
        }
        
        CGContextRestoreGState(context)
    }
}