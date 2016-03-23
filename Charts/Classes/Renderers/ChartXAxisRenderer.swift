//
//  ChartXAxisRenderer.swift
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


public class ChartXAxisRenderer: ChartAxisRendererBase
{
    public var xAxis: ChartXAxis?
  
    public init(viewPortHandler: ChartViewPortHandler, xAxis: ChartXAxis, transformer: ChartTransformer!)
    {
        super.init(viewPortHandler: viewPortHandler, transformer: transformer)
        
        self.xAxis = xAxis
    }
    
    public func computeAxis(xValAverageLength xValAverageLength: Double, xValues: [String?])
    {
        guard let xAxis = xAxis else { return }
        
        var a = ""
        
        let max = Int(round(xValAverageLength + Double(xAxis.spaceBetweenLabels)))
        
        for _ in 0 ..< max
        {
            a += "h"
        }
        
        let widthText = a as NSString
        
        let labelSize = widthText.sizeWithAttributes([NSFontAttributeName: xAxis.labelFont])
        
        let labelWidth = labelSize.width
        let labelHeight = labelSize.height
        
        let labelRotatedSize = ChartUtils.sizeOfRotatedRectangle(labelSize, degrees: xAxis.labelRotationAngle)
        
        xAxis.labelWidth = labelWidth
        xAxis.labelHeight = labelHeight
        xAxis.labelRotatedWidth = labelRotatedSize.width
        xAxis.labelRotatedHeight = labelRotatedSize.height
        
        xAxis.values = xValues
    }
    
    public override func renderAxisLabels(context context: CGContext)
    {
        guard let xAxis = xAxis else { return }
        
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
        guard let xAxis = xAxis else { return }
        
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
        guard let xAxis = xAxis else { return }
        
        let paraStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paraStyle.alignment = .Center
        
        let labelAttrs = [NSFontAttributeName: xAxis.labelFont,
            NSForegroundColorAttributeName: xAxis.labelTextColor,
            NSParagraphStyleAttributeName: paraStyle]
        let labelRotationAngleRadians = xAxis.labelRotationAngle * ChartUtils.Math.FDEG2RAD
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        var labelMaxSize = CGSize()
        
        if (xAxis.isWordWrapEnabled)
        {
            labelMaxSize.width = xAxis.wordWrapWidthPercent * valueToPixelMatrix.a
        }
        
        for i in self.minX.stride(to: min(self.maxX + 1, xAxis.values.count), by: xAxis.axisLabelModulus)
        {
            let label = xAxis.values[i]
            if (label == nil)
            {
                continue
            }
            
            position.x = CGFloat(i)
            position.y = 0.0
            position = CGPointApplyAffineTransform(position, valueToPixelMatrix)
            
            if (viewPortHandler.isInBoundsX(position.x))
            {
                let labelns = label! as NSString
                
                if (xAxis.isAvoidFirstLastClippingEnabled)
                {
                    // avoid clipping of the last
                    if (i == xAxis.values.count - 1 && xAxis.values.count > 1)
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
                
                drawLabel(context: context, label: label!, xIndex: i, x: position.x, y: pos, attributes: labelAttrs, constrainedToSize: labelMaxSize, anchor: anchor, angleRadians: labelRotationAngleRadians)
            }
        }
    }
    
    public func drawLabel(context context: CGContext, label: String, xIndex: Int, x: CGFloat, y: CGFloat, attributes: [String: NSObject], constrainedToSize: CGSize, anchor: CGPoint, angleRadians: CGFloat)
    {
        guard let xAxis = xAxis else { return }
        
        let formattedLabel = xAxis.valueFormatter?.stringForXValue(xIndex, original: label, viewPortHandler: viewPortHandler) ?? label
        ChartUtils.drawMultilineText(context: context, text: formattedLabel, point: CGPoint(x: x, y: y), attributes: attributes, constrainedToSize: constrainedToSize, anchor: anchor, angleRadians: angleRadians)
    }
    
    private var _gridLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public override func renderGridLines(context context: CGContext)
    {
        guard let xAxis = xAxis else { return }
        
        if (!xAxis.isDrawGridLinesEnabled || !xAxis.isEnabled)
        {
            return
        }
        
        CGContextSaveGState(context)
        
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
        
        for i in self.minX.stride(to: self.maxX, by: xAxis.axisLabelModulus)
        {
            position.x = CGFloat(i)
            position.y = 0.0
            position = CGPointApplyAffineTransform(position, valueToPixelMatrix)
            
            if (position.x >= viewPortHandler.offsetLeft
                && position.x <= viewPortHandler.chartWidth)
            {
                _gridLineSegmentsBuffer[0].x = position.x
                _gridLineSegmentsBuffer[0].y = viewPortHandler.contentTop
                _gridLineSegmentsBuffer[1].x = position.x
                _gridLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
                CGContextStrokeLineSegments(context, _gridLineSegmentsBuffer, 2)
            }
        }
        
        CGContextRestoreGState(context)
    }
    
    public override func renderLimitLines(context context: CGContext)
    {
        guard let xAxis = xAxis else { return }
        
        var limitLines = xAxis.limitLines
        
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

            position.x = CGFloat(l.limit)
            position.y = 0.0
            position = CGPointApplyAffineTransform(position, trans)
            
            renderLimitLineLine(context: context, limitLine: l, position: position)
            renderLimitLineLabel(context: context, limitLine: l, position: position, yOffset: 2.0 + l.yOffset)
        }
        
        CGContextRestoreGState(context)
    }
    
    private var _limitLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public func renderLimitLineLine(context context: CGContext, limitLine: ChartLimitLine, position: CGPoint)
    {
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
        let label = limitLine.label
        
        // if drawing the limit-value label is enabled
        if (label.characters.count > 0)
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
