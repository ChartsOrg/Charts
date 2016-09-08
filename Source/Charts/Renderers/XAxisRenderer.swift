//
//  XAxisRenderer.swift
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

@objc(ChartXAxisRenderer)
public class XAxisRenderer: AxisRendererBase
{
    public init(viewPortHandler: ViewPortHandler?, xAxis: XAxis?, transformer: Transformer?)
    {
        super.init(viewPortHandler: viewPortHandler, transformer: transformer, axis: xAxis)
    }
    
    public override func computeAxis(min min: Double, max: Double, inverted: Bool)
    {
        guard let
            viewPortHandler = self.viewPortHandler
            else { return }
        
        var min = min, max = max
        
        if let transformer = self.transformer
        {
            // calculate the starting and entry point of the y-labels (depending on
            // zoom / contentrect bounds)
            if viewPortHandler.contentWidth > 10 && !viewPortHandler.isFullyZoomedOutX
            {
                let p1 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
                let p2 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop))
                
                if inverted
                {
                    min = Double(p2.x)
                    max = Double(p1.x)
                }
                else
                {
                    min = Double(p1.x)
                    max = Double(p2.x)
                }
            }
        }
        
        computeAxisValues(min: min, max: max);
    }
    
    public override func computeAxisValues(min min: Double, max: Double)
    {
        super.computeAxisValues(min: min, max: max)
        
        computeSize()
    }
    
    public func computeSize()
    {
        guard let
            xAxis = self.axis as? XAxis
            else { return }
        
        let longest = xAxis.getLongestLabel()
        
        let labelSize = longest.sizeWithAttributes([NSFontAttributeName: xAxis.labelFont])
        
        let labelWidth = labelSize.width
        let labelHeight = labelSize.height
        
        let labelRotatedSize = ChartUtils.sizeOfRotatedRectangle(labelSize, degrees: xAxis.labelRotationAngle)
        
        xAxis.labelWidth = labelWidth
        xAxis.labelHeight = labelHeight
        xAxis.labelRotatedWidth = labelRotatedSize.width
        xAxis.labelRotatedHeight = labelRotatedSize.height
    }
    
    public override func renderAxisLabels(context context: CGContext)
    {
        guard let
            xAxis = self.axis as? XAxis,
            viewPortHandler = self.viewPortHandler
            else { return }
        
        if (!xAxis.isEnabled || !xAxis.isDrawLabelsEnabled)
        {
            return
        }
        
        let yOffset = xAxis.yOffset
        
        if (xAxis.labelPosition == .Top)
        {
            drawLabels(context: context, pos: viewPortHandler.contentTop - yOffset, anchor: CGPoint(x: 0.5, y: 1.0))
        }
        else if (xAxis.labelPosition == .TopInside)
        {
            drawLabels(context: context, pos: viewPortHandler.contentTop + yOffset + xAxis.labelRotatedHeight, anchor: CGPoint(x: 0.5, y: 1.0))
        }
        else if (xAxis.labelPosition == .Bottom)
        {
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yOffset, anchor: CGPoint(x: 0.5, y: 0.0))
        }
        else if (xAxis.labelPosition == .BottomInside)
        {
            drawLabels(context: context, pos: viewPortHandler.contentBottom - yOffset - xAxis.labelRotatedHeight, anchor: CGPoint(x: 0.5, y: 0.0))
        }
        else
        { // BOTH SIDED
            drawLabels(context: context, pos: viewPortHandler.contentTop - yOffset, anchor: CGPoint(x: 0.5, y: 1.0))
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yOffset, anchor: CGPoint(x: 0.5, y: 0.0))
        }
    }
    
    private var _axisLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public override func renderAxisLine(context context: CGContext)
    {
        guard let
            xAxis = self.axis as? XAxis,
            viewPortHandler = self.viewPortHandler
            else { return }
        
        if (!xAxis.isEnabled || !xAxis.isDrawAxisLineEnabled)
        {
            return
        }
        
        CGContextSaveGState(context)
        
        CGContextSetStrokeColorWithColor(context, xAxis.axisLineColor.CGColor)
        CGContextSetLineWidth(context, xAxis.axisLineWidth)
        if (xAxis.axisLineDashLengths != nil)
        {
            CGContextSetLineDash(context, xAxis.axisLineDashPhase, xAxis.axisLineDashLengths, xAxis.axisLineDashLengths.count)
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0)
        }

        if (xAxis.labelPosition == .Top
                || xAxis.labelPosition == .TopInside
                || xAxis.labelPosition == .BothSided)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentTop
            CGContextStrokeLineSegments(context, _axisLineSegmentsBuffer, 2)
        }

        if (xAxis.labelPosition == .Bottom
                || xAxis.labelPosition == .BottomInside
                || xAxis.labelPosition == .BothSided)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentBottom
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            CGContextStrokeLineSegments(context, _axisLineSegmentsBuffer, 2)
        }
        
        CGContextRestoreGState(context)
    }
    
    /// draws the x-labels on the specified y-position
    public func drawLabels(context context: CGContext, pos: CGFloat, anchor: CGPoint)
    {
        guard let
            xAxis = self.axis as? XAxis,
            viewPortHandler = self.viewPortHandler,
            transformer = self.transformer
            else { return }
        
        let paraStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paraStyle.alignment = .Center
        
        let labelAttrs = [NSFontAttributeName: xAxis.labelFont,
            NSForegroundColorAttributeName: xAxis.labelTextColor,
            NSParagraphStyleAttributeName: paraStyle]
        let labelRotationAngleRadians = xAxis.labelRotationAngle * ChartUtils.Math.FDEG2RAD
        
        let centeringEnabled = xAxis.isCenterAxisLabelsEnabled

        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        var labelMaxSize = CGSize()
        
        if (xAxis.isWordWrapEnabled)
        {
            labelMaxSize.width = xAxis.wordWrapWidthPercent * valueToPixelMatrix.a
        }
        
        let entries = xAxis.entries;
        
        for i in 0.stride(to: entries.count, by: 1)
        {
            if centeringEnabled
            {
                position.x = CGFloat(xAxis.centeredEntries[i])
            }
            else
            {
                position.x = CGFloat(entries[i])
            }
            
            position.y = 0.0
            position = CGPointApplyAffineTransform(position, valueToPixelMatrix)
            
            if (viewPortHandler.isInBoundsX(position.x))
            {
                let label = xAxis.valueFormatter?.stringForValue(xAxis.entries[i], axis: xAxis) ?? ""

                let labelns = label as NSString
                
                if (xAxis.isAvoidFirstLastClippingEnabled)
                {
                    // avoid clipping of the last
                    if (i == xAxis.entryCount - 1 && xAxis.entryCount > 1)
                    {
                        let width = labelns.boundingRectWithSize(labelMaxSize, options: .UsesLineFragmentOrigin, attributes: labelAttrs, context: nil).size.width
                        
                        if (width > viewPortHandler.offsetRight * 2.0
                            && position.x + width > viewPortHandler.chartWidth)
                        {
                            position.x -= width / 2.0
                        }
                    }
                    else if (i == 0)
                    { // avoid clipping of the first
                        let width = labelns.boundingRectWithSize(labelMaxSize, options: .UsesLineFragmentOrigin, attributes: labelAttrs, context: nil).size.width
                        position.x += width / 2.0
                    }
                }
                
                drawLabel(context: context,
                          formattedLabel: label,
                          x: position.x,
                          y: pos,
                          attributes: labelAttrs,
                          constrainedToSize: labelMaxSize,
                          anchor: anchor,
                          angleRadians: labelRotationAngleRadians)
            }
        }
    }
    
    public func drawLabel(
        context context: CGContext,
                formattedLabel: String,
                x: CGFloat,
                y: CGFloat,
                attributes: [String: NSObject],
                constrainedToSize: CGSize,
                anchor: CGPoint,
                angleRadians: CGFloat)
    {
        ChartUtils.drawMultilineText(
            context: context,
            text: formattedLabel,
            point: CGPoint(x: x, y: y),
            attributes: attributes,
            constrainedToSize: constrainedToSize,
            anchor: anchor,
            angleRadians: angleRadians)
    }
    
    private var _gridLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public override func renderGridLines(context context: CGContext)
    {
        guard let
            xAxis = self.axis as? XAxis,
            transformer = self.transformer
            else { return }
        
        if (!xAxis.isDrawGridLinesEnabled || !xAxis.isEnabled)
        {
            return
        }
        
        CGContextSaveGState(context)
        defer { CGContextRestoreGState(context) }
        CGContextClipToRect(context, self.gridClippingRect)
        
        CGContextSetShouldAntialias(context, xAxis.gridAntialiasEnabled)
        CGContextSetStrokeColorWithColor(context, xAxis.gridColor.CGColor)
        CGContextSetLineWidth(context, xAxis.gridLineWidth)
        CGContextSetLineCap(context, xAxis.gridLineCap)
        
        if (xAxis.gridLineDashLengths != nil)
        {
            CGContextSetLineDash(context, xAxis.gridLineDashPhase, xAxis.gridLineDashLengths, xAxis.gridLineDashLengths.count)
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0)
        }
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        let entries = xAxis.entries;
        
        for i in 0.stride(to: entries.count, by: 1)
        {
            position.x = CGFloat(entries[i])
            position.y = position.x
            position = CGPointApplyAffineTransform(position, valueToPixelMatrix)
            
            drawGridLine(context: context, x: position.x, y: position.y)
        }
    }
    
    public var gridClippingRect: CGRect
    {
        var contentRect = viewPortHandler?.contentRect ?? CGRectZero
        contentRect.insetInPlace(dx: -(self.axis?.gridLineWidth ?? 0.0) / 2.0, dy: 0.0)
        return contentRect
    }
    
    public func drawGridLine(context context: CGContext, x: CGFloat, y: CGFloat)
    {
        guard let
            viewPortHandler = self.viewPortHandler
            else { return }
        
        if x >= viewPortHandler.offsetLeft
            && x <= viewPortHandler.chartWidth
        {
            _gridLineSegmentsBuffer[0].x = x
            _gridLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _gridLineSegmentsBuffer[1].x = x
            _gridLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            CGContextStrokeLineSegments(context, _gridLineSegmentsBuffer, 2)
        }
    }
    
    public override func renderLimitLines(context context: CGContext)
    {
        guard let
            xAxis = self.axis as? XAxis,
            viewPortHandler = self.viewPortHandler,
            transformer = self.transformer
            else { return }
        
        var limitLines = xAxis.limitLines
        
        if (limitLines.count == 0)
        {
            return
        }
        
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
            
            renderLimitLineLine(context: context, limitLine: l, position: position)
            renderLimitLineLabel(context: context, limitLine: l, position: position, yOffset: 2.0 + l.yOffset)
        }
    }
    
    private var _limitLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public func renderLimitLineLine(context context: CGContext, limitLine: ChartLimitLine, position: CGPoint)
    {
        guard let
            viewPortHandler = self.viewPortHandler
            else { return }
        
        _limitLineSegmentsBuffer[0].x = position.x
        _limitLineSegmentsBuffer[0].y = viewPortHandler.contentTop
        _limitLineSegmentsBuffer[1].x = position.x
        _limitLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
        
        CGContextSetStrokeColorWithColor(context, limitLine.lineColor.CGColor)
        CGContextSetLineWidth(context, limitLine.lineWidth)
        if (limitLine.lineDashLengths != nil)
        {
            CGContextSetLineDash(context, limitLine.lineDashPhase, limitLine.lineDashLengths!, limitLine.lineDashLengths!.count)
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0)
        }
        
        CGContextStrokeLineSegments(context, _limitLineSegmentsBuffer, 2)
    }
    
    public func renderLimitLineLabel(context context: CGContext, limitLine: ChartLimitLine, position: CGPoint, yOffset: CGFloat)
    {
        guard let
            viewPortHandler = self.viewPortHandler
            else { return }
        
        let label = limitLine.label
        
        // if drawing the limit-value label is enabled
        if (limitLine.drawLabelEnabled && label.characters.count > 0)
        {
            let labelLineHeight = limitLine.valueFont.lineHeight
            
            let xOffset: CGFloat = limitLine.lineWidth + limitLine.xOffset
            
            if (limitLine.labelPosition == .RightTop)
            {
                ChartUtils.drawText(context: context,
                    text: label,
                    point: CGPoint(
                        x: position.x + xOffset,
                        y: viewPortHandler.contentTop + yOffset),
                    align: .Left,
                    attributes: [NSFontAttributeName: limitLine.valueFont, NSForegroundColorAttributeName: limitLine.valueTextColor])
            }
            else if (limitLine.labelPosition == .RightBottom)
            {
                ChartUtils.drawText(context: context,
                    text: label,
                    point: CGPoint(
                        x: position.x + xOffset,
                        y: viewPortHandler.contentBottom - labelLineHeight - yOffset),
                    align: .Left,
                    attributes: [NSFontAttributeName: limitLine.valueFont, NSForegroundColorAttributeName: limitLine.valueTextColor])
            }
            else if (limitLine.labelPosition == .LeftTop)
            {
                ChartUtils.drawText(context: context,
                    text: label,
                    point: CGPoint(
                        x: position.x - xOffset,
                        y: viewPortHandler.contentTop + yOffset),
                    align: .Right,
                    attributes: [NSFontAttributeName: limitLine.valueFont, NSForegroundColorAttributeName: limitLine.valueTextColor])
            }
            else
            {
                ChartUtils.drawText(context: context,
                    text: label,
                    point: CGPoint(
                        x: position.x - xOffset,
                        y: viewPortHandler.contentBottom - labelLineHeight - yOffset),
                    align: .Right,
                    attributes: [NSFontAttributeName: limitLine.valueFont, NSForegroundColorAttributeName: limitLine.valueTextColor])
            }
        }
    }

}
