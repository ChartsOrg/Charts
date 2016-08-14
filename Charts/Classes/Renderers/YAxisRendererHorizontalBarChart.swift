//
//  YAxisRendererHorizontalBarChart.swift
//  Charts
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

public class YAxisRendererHorizontalBarChart: YAxisRenderer
{
    public override init(viewPortHandler: ViewPortHandler?, yAxis: YAxis?, transformer: Transformer?)
    {
        super.init(viewPortHandler: viewPortHandler, yAxis: yAxis, transformer: transformer)
    }

    /// Computes the axis values.
    public override func computeAxis(min min: Double, max: Double, inverted: Bool)
    {
        guard let
            viewPortHandler = self.viewPortHandler,
            transformer = self.transformer
            else { return }
        
        var min = min, max = max
        
        // calculate the starting and entry point of the y-labels (depending on zoom / contentrect bounds)
        if viewPortHandler.contentHeight > 10.0 && !viewPortHandler.isFullyZoomedOutX
        {
            let p1 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            let p2 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop))
            
            if !inverted
            {
                min = Double(p1.x)
                max = Double(p2.x)
            }
            else
            {
                min = Double(p2.x)
                max = Double(p1.x)
            }
        }
        
        computeAxisValues(min: min, max: max)
    }

    /// draws the y-axis labels to the screen
    public override func renderAxisLabels(context context: CGContext)
    {
        guard let
            yAxis = axis as? YAxis,
            viewPortHandler = self.viewPortHandler
            else { return }
        
        if (!yAxis.isEnabled || !yAxis.isDrawLabelsEnabled)
        {
            return
        }
        
        let lineHeight = yAxis.labelFont.lineHeight
        let baseYOffset: CGFloat = 2.5
        
        let dependency = yAxis.axisDependency
        let labelPosition = yAxis.labelPosition
        
        var yPos: CGFloat = 0.0
        
        if dependency == .Left
        {
            if (labelPosition == .OutsideChart)
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
            if (labelPosition == .OutsideChart)
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
        
        drawYLabels(
            context: context,
            fixedPosition: yPos,
            positions: transformedPositions(),
            offset: yAxis.yOffset)
    }
    
    private var _axisLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public override func renderAxisLine(context context: CGContext)
    {
        guard let
            yAxis = axis as? YAxis,
            viewPortHandler = self.viewPortHandler
            else { return }
        
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
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentTop
            CGContextStrokeLineSegments(context, _axisLineSegmentsBuffer, 2)
        }
        else
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentBottom
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            CGContextStrokeLineSegments(context, _axisLineSegmentsBuffer, 2)
        }
        
        CGContextRestoreGState(context)
    }

    /// draws the y-labels on the specified x-position
    public func drawYLabels(
        context context: CGContext,
                fixedPosition: CGFloat,
                positions: [CGPoint],
                offset: CGFloat)
    {
        guard let
            yAxis = axis as? YAxis
            else { return }
        
        let labelFont = yAxis.labelFont
        let labelTextColor = yAxis.labelTextColor
        
        for i in 0 ..< yAxis.entryCount
        {
            let text = yAxis.getFormattedLabel(i)
            
            if (!yAxis.isDrawTopYLabelEntryEnabled && i >= yAxis.entryCount - 1)
            {
                return
            }
            
            ChartUtils.drawText(
                context: context,
                text: text,
                point: CGPoint(x: positions[i].x, y: fixedPosition - offset),
                align: .Center,
                attributes: [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: labelTextColor])
        }
    }
    
    public override var gridClippingRect: CGRect
    {
        var contentRect = viewPortHandler?.contentRect ?? CGRectZero
        contentRect.insetInPlace(dx: -(self.axis?.gridLineWidth ?? 0.0) / 2.0, dy: 0.0)
        return contentRect
    }
    
    private var _gridLineBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public override func drawGridLine(
        context context: CGContextRef,
                position: CGPoint)
    {
        guard let
            viewPortHandler = self.viewPortHandler
            else { return }
        
        _gridLineBuffer[0].x = position.x
        _gridLineBuffer[0].y = viewPortHandler.contentTop
        _gridLineBuffer[1].x = position.x
        _gridLineBuffer[1].y = viewPortHandler.contentBottom
        
        CGContextStrokeLineSegments(context, _gridLineBuffer, 2)
    }
    
    public override func transformedPositions() -> [CGPoint]
    {
        guard let
            yAxis = self.axis as? YAxis,
            transformer = self.transformer
            else { return [CGPoint]() }
        
        var positions = [CGPoint]()
        positions.reserveCapacity(yAxis.entryCount)
        
        let entries = yAxis.entries
        
        for i in 0.stride(to: yAxis.entryCount, by: 1)
        {
            positions.append(CGPoint(x: entries[i], y: 0.0))
        }
        
        transformer.pointValuesToPixel(&positions)
        
        return positions
    }
    
    /// Draws the zero line at the specified position.
    public override func drawZeroLine(context context: CGContext)
    {
        guard let
            yAxis = self.axis as? YAxis,
            viewPortHandler = self.viewPortHandler,
            transformer = self.transformer,
            zeroLineColor = yAxis.zeroLineColor
            else { return }
        
        CGContextSaveGState(context)
        defer { CGContextRestoreGState(context) }
        var clippingRect = viewPortHandler.contentRect
        clippingRect.insetInPlace(dx: yAxis.zeroLineWidth / 2.0, dy: 0.0)
        CGContextClipToRect(context, clippingRect)
        
        CGContextSetStrokeColorWithColor(context, zeroLineColor.CGColor)
        CGContextSetLineWidth(context, yAxis.zeroLineWidth)
        
        let pos = transformer.pixelForValues(x: 0.0, y: 0.0)
        
        if yAxis.zeroLineDashLengths != nil
        {
            CGContextSetLineDash(context, yAxis.zeroLineDashPhase, yAxis.zeroLineDashLengths!, yAxis.zeroLineDashLengths!.count)
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0)
        }
        
        CGContextMoveToPoint(context, pos.x - 1.0, viewPortHandler.contentTop)
        CGContextAddLineToPoint(context, pos.x - 1.0, viewPortHandler.contentBottom)
        CGContextDrawPath(context, CGPathDrawingMode.Stroke)
    }
    
    private var _limitLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public override func renderLimitLines(context context: CGContext)
    {
        guard let
            yAxis = axis as? YAxis,
            viewPortHandler = self.viewPortHandler,
            transformer = self.transformer
            else { return }
        
        var limitLines = yAxis.limitLines

        if (limitLines.count <= 0)
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
            
            CGContextSaveGState(context)
            defer { CGContextRestoreGState(context) }
            var clippingRect = viewPortHandler.contentRect
            clippingRect.insetInPlace(dx: -l.lineWidth / 2.0, dy: 0.0)
            CGContextClipToRect(context, clippingRect)
            
            position.x = CGFloat(l.limit)
            position.y = 0.0
            position = CGPointApplyAffineTransform(position, trans)
            
            _limitLineSegmentsBuffer[0].x = position.x
            _limitLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _limitLineSegmentsBuffer[1].x = position.x
            _limitLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            
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
            if (l.drawLabelEnabled && label.characters.count > 0)
            {
                let labelLineHeight = l.valueFont.lineHeight
                
                let xOffset: CGFloat = l.lineWidth + l.xOffset
                let yOffset: CGFloat = 2.0 + l.yOffset

                if (l.labelPosition == .RightTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: position.x + xOffset,
                            y: viewPortHandler.contentTop + yOffset),
                        align: .Left,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else if (l.labelPosition == .RightBottom)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: position.x + xOffset,
                            y: viewPortHandler.contentBottom - labelLineHeight - yOffset),
                        align: .Left,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else if (l.labelPosition == .LeftTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: position.x - xOffset,
                            y: viewPortHandler.contentTop + yOffset),
                        align: .Right,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: position.x - xOffset,
                            y: viewPortHandler.contentBottom - labelLineHeight - yOffset),
                        align: .Right,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
            }
        }
        
        CGContextRestoreGState(context)
    }
}