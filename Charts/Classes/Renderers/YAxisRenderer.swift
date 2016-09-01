//
//  YAxisRenderer.swift
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

@objc(ChartYAxisRenderer)
public class YAxisRenderer: AxisRendererBase
{
    public init(viewPortHandler: ViewPortHandler?, yAxis: YAxis?, transformer: Transformer?)
    {
        super.init(viewPortHandler: viewPortHandler, transformer: transformer, axis: yAxis)
    }
    
    /// draws the y-axis labels to the screen
    public override func renderAxisLabels(context context: CGContext)
    {
        guard let
            yAxis = self.axis as? YAxis,
            viewPortHandler = self.viewPortHandler
            else { return }
        
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
        
        drawYLabels(
            context: context,
            fixedPosition: xPos,
            positions: transformedPositions(),
            offset: yoffset - yAxis.labelFont.lineHeight,
            textAlign: textAlign)
    }
    
    private var _axisLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public override func renderAxisLine(context context: CGContext)
    {
        guard let
            yAxis = self.axis as? YAxis,
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
    internal func drawYLabels(
        context context: CGContext,
                fixedPosition: CGFloat,
                positions: [CGPoint],
                offset: CGFloat,
                textAlign: NSTextAlignment)
    {
        guard let
            yAxis = self.axis as? YAxis
            else { return }
        
        let labelFont = yAxis.labelFont
        let labelTextColor = yAxis.labelTextColor
        
        for i in 0 ..< yAxis.entryCount
        {
            let text = yAxis.getFormattedLabel(i)
            
            if (!yAxis.isDrawTopYLabelEntryEnabled && i >= yAxis.entryCount - 1)
            {
                break
            }
            
            ChartUtils.drawText(
                context: context,
                text: text,
                point: CGPoint(x: fixedPosition, y: positions[i].y + offset),
                align: textAlign,
                attributes: [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: labelTextColor])
        }
    }
    
    public override func renderGridLines(context context: CGContext)
    {
        guard let
            yAxis = self.axis as? YAxis
            else { return }
        
        if !yAxis.isEnabled
        {
            return
        }
        
        if yAxis.drawGridLinesEnabled
        {
            let positions = transformedPositions()
            
            CGContextSaveGState(context)
            defer { CGContextRestoreGState(context) }
            CGContextClipToRect(context, self.gridClippingRect)
            
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
            
            // draw the grid
            for i in 0 ..< positions.count
            {
                drawGridLine(context: context, position: positions[i])
            }
        }

        if yAxis.drawZeroLineEnabled
        {
            // draw zero line
            drawZeroLine(context: context);
        }
    }
    
    public var gridClippingRect: CGRect
    {
        var contentRect = viewPortHandler?.contentRect ?? CGRectZero
        contentRect.insetInPlace(dx: 0.0, dy: -(self.axis?.gridLineWidth ?? 0.0) / 2.0)
        return contentRect
    }
    
    private var _gridLineBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public func drawGridLine(
        context context: CGContextRef,
                position: CGPoint)
    {
        guard let
            viewPortHandler = self.viewPortHandler
            else { return }
        
        _gridLineBuffer[0].x = viewPortHandler.contentLeft
        _gridLineBuffer[0].y = position.y
        _gridLineBuffer[1].x = viewPortHandler.contentRight
        _gridLineBuffer[1].y = position.y
        
        CGContextStrokeLineSegments(context, _gridLineBuffer, 2)
    }
    
    public func transformedPositions() -> [CGPoint]
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
            positions.append(CGPoint(x: 0.0, y: entries[i]))
        }

        transformer.pointValuesToPixel(&positions)
        
        return positions
    }

    /// Draws the zero line at the specified position.
    public func drawZeroLine(context context: CGContext)
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
        clippingRect.insetInPlace(dx: 0.0, dy: yAxis.zeroLineWidth / 2.0)
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
        
        CGContextMoveToPoint(context, viewPortHandler.contentLeft, pos.y - 1.0)
        CGContextAddLineToPoint(context, viewPortHandler.contentRight, pos.y - 1.0)
        CGContextDrawPath(context, CGPathDrawingMode.Stroke)
    }
    
    private var _limitLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public override func renderLimitLines(context context: CGContext)
    {
        guard let
            yAxis = self.axis as? YAxis,
            viewPortHandler = self.viewPortHandler,
            transformer = self.transformer
            else { return }
        
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
            
            CGContextSaveGState(context)
            defer { CGContextRestoreGState(context) }
            var clippingRect = viewPortHandler.contentRect
            clippingRect.insetInPlace(dx: 0.0, dy: -l.lineWidth / 2.0)
            CGContextClipToRect(context, clippingRect)
            
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
            if (l.drawLabelEnabled && label.characters.count > 0)
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
