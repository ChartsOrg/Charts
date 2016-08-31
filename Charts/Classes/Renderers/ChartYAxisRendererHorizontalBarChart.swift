//
//  ChartYAxisRendererHorizontalBarChart.swift
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


open class ChartYAxisRendererHorizontalBarChart: ChartYAxisRenderer
{
    public override init(viewPortHandler: ChartViewPortHandler, yAxis: ChartYAxis, transformer: ChartTransformer!)
    {
        super.init(viewPortHandler: viewPortHandler, yAxis: yAxis, transformer: transformer)
    }

    /// Computes the axis values.
    open override func computeAxis(yMin: Double, yMax: Double)
    {
        guard let yAxis = yAxis else { return }
        
        var yMin = yMin, yMax = yMax
        
        // calculate the starting and entry point of the y-labels (depending on zoom / contentrect bounds)
        if (viewPortHandler.contentHeight > 10.0 && !viewPortHandler.isFullyZoomedOutX)
        {
            let p1 = transformer.getValueByTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            let p2 = transformer.getValueByTouchPoint(CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop))
            
            if (!yAxis.inverted)
            {
                yMin = Double(p1.x)
                yMax = Double(p2.x)
            }
            else
            {
                yMin = Double(p2.x)
                yMax = Double(p1.x)
            }
        }
        
        computeAxisValues(min: yMin, max: yMax)
    }

    /// draws the y-axis labels to the screen
    open override func renderAxisLabels(context: CGContext)
    {
        guard let yAxis = yAxis else { return }
        
        if (!yAxis.enabled || !yAxis.drawLabelsEnabled)
        {
            return
        }
        
        var positions = [CGPoint]()
        positions.reserveCapacity(yAxis.entries.count)
        
        for i in 0 ..< yAxis.entries.count
        {
            positions.append(CGPoint(x: CGFloat(yAxis.entries[i]), y: 0.0))
        }
        
        transformer.pointValuesToPixel(&positions)
        
        let lineHeight = yAxis.labelFont.lineHeight
        let baseYOffset: CGFloat = 2.5
        
        let dependency = yAxis.axisDependency
        let labelPosition = yAxis.labelPosition
        
        var yPos: CGFloat = 0.0
        
        if (dependency == .left)
        {
            if (labelPosition == .outsideChart)
            {
                yPos = viewPortHandler.contentTop - baseYOffset
            }
            else
            {
                yPos = viewPortHandler.contentTop - baseYOffset
            }
        }
        else
        {
            if (labelPosition == .outsideChart)
            {
                yPos = viewPortHandler.contentBottom + lineHeight + baseYOffset
            }
            else
            {
                yPos = viewPortHandler.contentBottom + lineHeight + baseYOffset
            }
        }
        
        // For compatibility with Android code, we keep above calculation the same,
        // And here we pull the line back up
        yPos -= lineHeight
        
        drawYLabels(context: context, fixedPosition: yPos, positions: positions, offset: yAxis.yOffset)
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
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentTop
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }
        else
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentBottom
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }
        
        context.restoreGState()
    }

    /// draws the y-labels on the specified x-position
    open func drawYLabels(context: CGContext, fixedPosition: CGFloat, positions: [CGPoint], offset: CGFloat)
    {
        guard let yAxis = yAxis else { return }
        
        let labelFont = yAxis.labelFont
        let labelTextColor = yAxis.labelTextColor
        
        for i in 0 ..< yAxis.entryCount
        {
            let text = yAxis.getFormattedLabel(i)
            
            if (!yAxis.drawTopYLabelEntryEnabled && i >= yAxis.entryCount - 1)
            {
                return
            }
            
            ChartUtils.drawText(context: context, text: text, point: CGPoint(x: positions[i].x, y: fixedPosition - offset), align: .center, attributes: [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: labelTextColor])
        }
    }

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
            
            // pre alloc
            var position = CGPoint()
            
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
            
            // draw the horizontal grid
            for i in 0 ..< yAxis.entryCount
            {
                position.x = CGFloat(yAxis.entries[i])
                position.y = 0.0
                transformer.pointValueToPixel(&position)
                
                context.beginPath()
                context.move(to: CGPoint(x: position.x, y: viewPortHandler.contentTop))
                context.addLine(to: CGPoint(x: position.x, y: viewPortHandler.contentBottom))
                context.strokePath()
            }
            
            context.restoreGState()
        }
        
        if yAxis.drawZeroLineEnabled
        {
            // draw zero line
            
            var position = CGPoint(x: 0.0, y: 0.0)
            transformer.pointValueToPixel(&position)
            
            drawZeroLine(context: context,
                x1: position.x,
                x2: position.x,
                y1: viewPortHandler.contentTop,
                y2: viewPortHandler.contentBottom);
        }
    }
    
    private var _limitLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderLimitLines(context: CGContext)
    {
        guard let yAxis = yAxis else { return }
        
        var limitLines = yAxis.limitLines

        if (limitLines.count <= 0)
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
            
            position.x = CGFloat(l.limit)
            position.y = 0.0
            position = position.applying(trans)
            
            _limitLineSegmentsBuffer[0].x = position.x
            _limitLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _limitLineSegmentsBuffer[1].x = position.x
            _limitLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            
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
                
                let xOffset: CGFloat = l.lineWidth + l.xOffset
                let yOffset: CGFloat = 2.0 + l.yOffset

                if (l.labelPosition == .rightTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: position.x + xOffset,
                            y: viewPortHandler.contentTop + yOffset),
                        align: .left,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else if (l.labelPosition == .rightBottom)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: position.x + xOffset,
                            y: viewPortHandler.contentBottom - labelLineHeight - yOffset),
                        align: .left,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else if (l.labelPosition == .leftTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: position.x - xOffset,
                            y: viewPortHandler.contentTop + yOffset),
                        align: .right,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: position.x - xOffset,
                            y: viewPortHandler.contentBottom - labelLineHeight - yOffset),
                        align: .right,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
            }
        }
        
        context.restoreGState()
    }
}
