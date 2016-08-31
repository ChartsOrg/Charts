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
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif


open class ChartYAxisRenderer: ChartAxisRendererBase
{
    open var yAxis: ChartYAxis?
    
    public init(viewPortHandler: ChartViewPortHandler, yAxis: ChartYAxis, transformer: ChartTransformer!)
    {
        super.init(viewPortHandler: viewPortHandler, transformer: transformer)
        
        self.yAxis = yAxis
    }
    
    /// Computes the axis values.
    open func computeAxis(yMin: Double, yMax: Double)
    {
        guard let yAxis = yAxis else { return }
        var yMin = yMin, yMax = yMax
        
        // calculate the starting and entry point of the y-labels (depending on
        // zoom / contentrect bounds)
        if (viewPortHandler.contentWidth > 10.0 && !viewPortHandler.isFullyZoomedOutY)
        {
            let p1 = transformer.getValueByTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            let p2 = transformer.getValueByTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
            
            if (!yAxis.inverted)
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
    open func computeAxisValues(min: Double, max: Double)
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
        let intervalMagnitude = ChartUtils.roundToNextSignificant(number: pow(10.0, Double(Int(log10(interval)))))
        let intervalSigDigit = Int(interval / intervalMagnitude)
        if (intervalSigDigit > 5)
        {
            // Use one order of magnitude higher, to avoid intervals like 0.9 or 90
            interval = floor(10.0 * Double(intervalMagnitude))
        }
        
        // force label count
        if yAxis.forceLabelsEnabled
        {
            let step = Double(range) / Double(labelCount - 1)
            
            if yAxis.entries.count < labelCount
            {
                // Ensure stops contains at least numStops elements.
                yAxis.entries.removeAll(keepingCapacity: true)
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
            if (yAxis.showOnlyMinMaxEnabled)
            {
                yAxis.entries = [yMin, yMax]
            }
            else
            {
                let first = interval == 0.0 ? 0.0 : ceil(Double(yMin) / interval) * interval
                let last = interval == 0.0 ? 0.0 : ChartUtils.nextUp(floor(Double(yMax) / interval) * interval)
                
                var n = 0
                if interval != 0.0 && last != first
                {
                    for _ in stride(from: first, through: last, by: interval)
                    {
                        n += 1
                    }
                }
                
                if (yAxis.entries.count < n)
                {
                    // Ensure stops contains at least numStops elements.
                    yAxis.entries = [Double](repeating: 0.0, count: n)
                }
                else if (yAxis.entries.count > n)
                {
                    yAxis.entries.removeSubrange(n..<yAxis.entries.count)
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
    open override func renderAxisLabels(context: CGContext)
    {
        guard let yAxis = yAxis else { return }
        
        if (!yAxis.enabled || !yAxis.drawLabelsEnabled)
        {
            return
        }
        
        let xoffset = yAxis.xOffset
        let yoffset = yAxis.labelFont.lineHeight / 2.5 + yAxis.yOffset
        
        let dependency = yAxis.axisDependency
        let labelPosition = yAxis.labelPosition
        
        var xPos = CGFloat(0.0)
        
        var textAlign: NSTextAlignment
        
        if (dependency == .left)
        {
            if (labelPosition == .outsideChart)
            {
                textAlign = .right
                xPos = viewPortHandler.offsetLeft - xoffset
            }
            else
            {
                textAlign = .left
                xPos = viewPortHandler.offsetLeft + xoffset
            }
            
        }
        else
        {
            if (labelPosition == .outsideChart)
            {
                textAlign = .left
                xPos = viewPortHandler.contentRight + xoffset
            }
            else
            {
                textAlign = .right
                xPos = viewPortHandler.contentRight - xoffset
            }
        }
        
        drawYLabels(context: context, fixedPosition: xPos, offset: yoffset - yAxis.labelFont.lineHeight, textAlign: textAlign)
    }
    
    private var _axisLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderAxisLine(context: CGContext)
    {
        guard let yAxis = yAxis else { return }
        
        if (!yAxis.enabled || !yAxis.drawAxisLineEnabled)
        {
            return
        }
        
        context.saveGState()
        
        context.setStrokeColor(yAxis.axisLineColor.cgColor)
        context.setLineWidth(yAxis.axisLineWidth)
        if (yAxis.axisLineDashLengths != nil)
        {
            context.setLineDash(phase: yAxis.axisLineDashPhase, lengths: yAxis.axisLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        if (yAxis.axisDependency == .left)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }
        else
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }
        
        context.restoreGState()
    }
    
    /// draws the y-labels on the specified x-position
    internal func drawYLabels(context: CGContext, fixedPosition: CGFloat, offset: CGFloat, textAlign: NSTextAlignment)
    {
        guard let yAxis = yAxis else { return }
        
        let labelFont = yAxis.labelFont
        let labelTextColor = yAxis.labelTextColor
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var pt = CGPoint()
        
        for i in 0 ..< yAxis.entryCount
        {
            let text = yAxis.getFormattedLabel(i)
            
            if (!yAxis.drawTopYLabelEntryEnabled && i >= yAxis.entryCount - 1)
            {
                break
            }
            
            pt.x = 0
            pt.y = CGFloat(yAxis.entries[i])
            pt = pt.applying(valueToPixelMatrix)
            
            pt.x = fixedPosition
            pt.y += offset
            
            ChartUtils.drawText(context: context, text: text, point: pt, align: textAlign, attributes: [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: labelTextColor])
        }
    }
    
    private var _gridLineBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderGridLines(context: CGContext)
    {
        guard let yAxis = yAxis else { return }
        
        if !yAxis.enabled
        {
            return
        }
        
        if yAxis.drawGridLinesEnabled
        {
            context.saveGState()
            
            context.setShouldAntialias(yAxis.gridAntialiasEnabled)
            context.setStrokeColor(yAxis.gridColor.cgColor)
            context.setLineWidth(yAxis.gridLineWidth)
            context.setLineCap(yAxis.gridLineCap)
            
            if (yAxis.gridLineDashLengths != nil)
            {
                context.setLineDash(phase: yAxis.gridLineDashPhase, lengths: yAxis.gridLineDashLengths)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            let valueToPixelMatrix = transformer.valueToPixelMatrix
            
            var position = CGPoint(x: 0.0, y: 0.0)
            
            // draw the horizontal grid
            for i in 0 ..< yAxis.entryCount
            {
                position.x = 0.0
                position.y = CGFloat(yAxis.entries[i])
                position = position.applying(valueToPixelMatrix)
                
                _gridLineBuffer[0].x = viewPortHandler.contentLeft
                _gridLineBuffer[0].y = position.y
                _gridLineBuffer[1].x = viewPortHandler.contentRight
                _gridLineBuffer[1].y = position.y
                context.strokeLineSegments(between: _gridLineBuffer)
            }
            
            context.restoreGState()
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
    open func drawZeroLine(
        context: CGContext,
        x1: CGFloat,
        x2: CGFloat,
        y1: CGFloat,
        y2: CGFloat)
    {
        guard let yAxis = yAxis,
              let zeroLineColor = yAxis.zeroLineColor
        else { return }
        
        context.saveGState()
        
        context.setStrokeColor(zeroLineColor.cgColor)
        context.setLineWidth(yAxis.zeroLineWidth)
        
        if (yAxis.zeroLineDashLengths != nil)
        {
            context.setLineDash(phase: yAxis.zeroLineDashPhase, lengths: yAxis.zeroLineDashLengths!)
        }
        else
        {
        context.setLineDash(phase: 0.0, lengths: [])
        }
        
        context.move(to: CGPoint(x: x1, y: y1))
        context.addLine(to: CGPoint(x: x2, y: y2))
        context.drawPath(using: CGPathDrawingMode.stroke)
        
        context.restoreGState()
    }
    
    private var _limitLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderLimitLines(context: CGContext)
    {
        guard let yAxis = yAxis else { return }
        
        var limitLines = yAxis.limitLines
        
        if (limitLines.count == 0)
        {
            return
        }
        
        context.saveGState()
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for i in 0 ..< limitLines.count
        {
            let l = limitLines[i]
            
            if !l.enabled
            {
                continue
            }
            
            position.x = 0.0
            position.y = CGFloat(l.limit)
            position = position.applying(trans)
            
            _limitLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _limitLineSegmentsBuffer[0].y = position.y
            _limitLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _limitLineSegmentsBuffer[1].y = position.y
            
            context.setStrokeColor(l.lineColor.cgColor)
            context.setLineWidth(l.lineWidth)
            if (l.lineDashLengths != nil)
            {
                context.setLineDash(phase: l.lineDashPhase, lengths: l.lineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            context.strokeLineSegments(between: _limitLineSegmentsBuffer)
            
            let label = l.label
            
            // if drawing the limit-value label is enabled
            if (l.drawLabelEnabled && label.characters.count > 0)
            {
                let labelLineHeight = l.valueFont.lineHeight
                
                let xOffset: CGFloat = 4.0 + l.xOffset
                let yOffset: CGFloat = l.lineWidth + labelLineHeight + l.yOffset
                
                if (l.labelPosition == .rightTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentRight - xOffset,
                            y: position.y - yOffset),
                        align: .right,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else if (l.labelPosition == .rightBottom)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentRight - xOffset,
                            y: position.y + yOffset - labelLineHeight),
                        align: .right,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else if (l.labelPosition == .leftTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentLeft + xOffset,
                            y: position.y - yOffset),
                        align: .left,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentLeft + xOffset,
                            y: position.y + yOffset - labelLineHeight),
                        align: .left,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
            }
        }
        
        context.restoreGState()
    }
}
