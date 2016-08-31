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
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif


open class ChartXAxisRenderer: ChartAxisRendererBase
{
    open var xAxis: ChartXAxis?
  
    public init(viewPortHandler: ChartViewPortHandler, xAxis: ChartXAxis, transformer: ChartTransformer!)
    {
        super.init(viewPortHandler: viewPortHandler, transformer: transformer)
        
        self.xAxis = xAxis
    }
    
    open func computeAxis(xValAverageLength: Double, xValues: [String?])
    {
        guard let xAxis = xAxis else { return }
        
        var a = ""
        
        let max = Int(round(xValAverageLength + Double(xAxis.spaceBetweenLabels)))
        
        for _ in 0 ..< max
        {
            a += "h"
        }
        
        let widthText = a as NSString
        
        let labelSize = widthText.size(attributes: [NSFontAttributeName: xAxis.labelFont])
        
        let labelWidth = labelSize.width
        let labelHeight = labelSize.height
        
        let labelRotatedSize = ChartUtils.sizeOfRotatedRectangle(labelSize, degrees: xAxis.labelRotationAngle)
        
        xAxis.labelWidth = labelWidth
        xAxis.labelHeight = labelHeight
        xAxis.labelRotatedWidth = labelRotatedSize.width
        xAxis.labelRotatedHeight = labelRotatedSize.height
        
        xAxis.values = xValues
    }
    
    open override func renderAxisLabels(context: CGContext)
    {
        guard let xAxis = xAxis else { return }
        
        if (!xAxis.enabled || !xAxis.drawLabelsEnabled)
        {
            return
        }
        
        let yOffset = xAxis.yOffset
        
        if (xAxis.labelPosition == .top)
        {
            drawLabels(context: context, pos: viewPortHandler.contentTop - yOffset, anchor: CGPoint(x: 0.5, y: 1.0))
        }
        else if (xAxis.labelPosition == .topInside)
        {
            drawLabels(context: context, pos: viewPortHandler.contentTop + yOffset + xAxis.labelRotatedHeight, anchor: CGPoint(x: 0.5, y: 1.0))
        }
        else if (xAxis.labelPosition == .bottom)
        {
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yOffset, anchor: CGPoint(x: 0.5, y: 0.0))
        }
        else if (xAxis.labelPosition == .bottomInside)
        {
            drawLabels(context: context, pos: viewPortHandler.contentBottom - yOffset - xAxis.labelRotatedHeight, anchor: CGPoint(x: 0.5, y: 0.0))
        }
        else
        { // BOTH SIDED
            drawLabels(context: context, pos: viewPortHandler.contentTop - yOffset, anchor: CGPoint(x: 0.5, y: 1.0))
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yOffset, anchor: CGPoint(x: 0.5, y: 0.0))
        }
    }
    
    private var _axisLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderAxisLine(context: CGContext)
    {
        guard let xAxis = xAxis else { return }
        
        if (!xAxis.enabled || !xAxis.drawAxisLineEnabled)
        {
            return
        }
        
        context.saveGState()
        
        context.setStrokeColor(xAxis.axisLineColor.cgColor)
        context.setLineWidth(xAxis.axisLineWidth)
        if (xAxis.axisLineDashLengths != nil)
        {
            context.setLineDash(phase: xAxis.axisLineDashPhase, lengths: xAxis.axisLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }

        if (xAxis.labelPosition == .top
                || xAxis.labelPosition == .topInside
                || xAxis.labelPosition == .bothSided)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentTop
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }

        if (xAxis.labelPosition == .bottom
                || xAxis.labelPosition == .bottomInside
                || xAxis.labelPosition == .bothSided)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentBottom
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }
        
        context.restoreGState()
    }
    
    /// draws the x-labels on the specified y-position
    open func drawLabels(context: CGContext, pos: CGFloat, anchor: CGPoint)
    {
        guard let xAxis = xAxis else { return }
        
        let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paraStyle.alignment = .center
        
        let labelAttrs: [String : NSObject] = [NSFontAttributeName: xAxis.labelFont,
            NSForegroundColorAttributeName: xAxis.labelTextColor,
            NSParagraphStyleAttributeName: paraStyle]
        let labelRotationAngleRadians = xAxis.labelRotationAngle * ChartUtils.Math.FDEG2RAD
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        var labelMaxSize = CGSize()
        
        if (xAxis.wordWrapEnabled)
        {
            labelMaxSize.width = xAxis.wordWrapWidthPercent * valueToPixelMatrix.a
        }
        
		for i in stride(from: self.minX, to: min(self.maxX + 1, xAxis.values.count), by: xAxis.axisLabelModulus)
        {
            let label = xAxis.values[i]
            if (label == nil)
            {
                continue
            }
            
            position.x = CGFloat(i)
            position.y = 0.0
            position = position.applying(valueToPixelMatrix)
            
            if (viewPortHandler.isInBoundsX(position.x))
            {
                let labelns = label! as NSString
                
                if (xAxis.avoidFirstLastClippingEnabled)
                {
                    // avoid clipping of the last
                    if (i == xAxis.values.count - 1 && xAxis.values.count > 1)
                    {
                        let width = labelns.boundingRect(with: labelMaxSize, options: .usesLineFragmentOrigin, attributes: labelAttrs, context: nil).size.width
                        
                        if (width > viewPortHandler.offsetRight * 2.0
                            && position.x + width > viewPortHandler.chartWidth)
                        {
                            position.x -= width / 2.0
                        }
                    }
                    else if (i == 0)
                    { // avoid clipping of the first
                        let width = labelns.boundingRect(with: labelMaxSize, options: .usesLineFragmentOrigin, attributes: labelAttrs, context: nil).size.width
                        position.x += width / 2.0
                    }
                }
                
                drawLabel(context: context, label: label!, xIndex: i, x: position.x, y: pos, attributes: labelAttrs, constrainedToSize: labelMaxSize, anchor: anchor, angleRadians: labelRotationAngleRadians)
            }
        }
    }
    
    open func drawLabel(context: CGContext, label: String, xIndex: Int, x: CGFloat, y: CGFloat, attributes: [String: NSObject], constrainedToSize: CGSize, anchor: CGPoint, angleRadians: CGFloat)
    {
        guard let xAxis = xAxis else { return }
        
        let formattedLabel = xAxis.valueFormatter?.stringForXValue(xIndex, original: label, viewPortHandler: viewPortHandler) ?? label
        ChartUtils.drawMultilineText(context: context, text: formattedLabel, point: CGPoint(x: x, y: y), attributes: attributes, constrainedToSize: constrainedToSize, anchor: anchor, angleRadians: angleRadians)
    }
    
    private var _gridLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderGridLines(context: CGContext)
    {
        guard let xAxis = xAxis else { return }
        
        if (!xAxis.drawGridLinesEnabled || !xAxis.enabled)
        {
            return
        }
        
        context.saveGState()
        
        context.setShouldAntialias(xAxis.gridAntialiasEnabled)
        context.setStrokeColor(xAxis.gridColor.cgColor)
        context.setLineWidth(xAxis.gridLineWidth)
        context.setLineCap(xAxis.gridLineCap)
        
        if (xAxis.gridLineDashLengths != nil)
        {
            context.setLineDash(phase: xAxis.gridLineDashPhase, lengths: xAxis.gridLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
		for i in stride(from: self.minX, to: self.maxX, by: xAxis.axisLabelModulus)
        {
            position.x = CGFloat(i)
            position.y = 0.0
            position = position.applying(valueToPixelMatrix)
            
            if (position.x >= viewPortHandler.offsetLeft
                && position.x <= viewPortHandler.chartWidth)
            {
                _gridLineSegmentsBuffer[0].x = position.x
                _gridLineSegmentsBuffer[0].y = viewPortHandler.contentTop
                _gridLineSegmentsBuffer[1].x = position.x
                _gridLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
                context.strokeLineSegments(between: _gridLineSegmentsBuffer)
            }
        }
        
        context.restoreGState()
    }
    
    open override func renderLimitLines(context: CGContext)
    {
        guard let xAxis = xAxis else { return }
        
        var limitLines = xAxis.limitLines
        
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

            position.x = CGFloat(l.limit)
            position.y = 0.0
            position = position.applying(trans)
            
            renderLimitLineLine(context: context, limitLine: l, position: position)
            renderLimitLineLabel(context: context, limitLine: l, position: position, yOffset: 2.0 + l.yOffset)
        }
        
        context.restoreGState()
    }
    
    private var _limitLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open func renderLimitLineLine(context: CGContext, limitLine: ChartLimitLine, position: CGPoint)
    {
        _limitLineSegmentsBuffer[0].x = position.x
        _limitLineSegmentsBuffer[0].y = viewPortHandler.contentTop
        _limitLineSegmentsBuffer[1].x = position.x
        _limitLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
        
        context.setStrokeColor(limitLine.lineColor.cgColor)
        context.setLineWidth(limitLine.lineWidth)
        if (limitLine.lineDashLengths != nil)
        {
            context.setLineDash(phase: limitLine.lineDashPhase, lengths: limitLine.lineDashLengths!)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        context.strokeLineSegments(between: _limitLineSegmentsBuffer)
    }
    
    open func renderLimitLineLabel(context: CGContext, limitLine: ChartLimitLine, position: CGPoint, yOffset: CGFloat)
    {
        let label = limitLine.label
        
        // if drawing the limit-value label is enabled
        if (limitLine.drawLabelEnabled && label.characters.count > 0)
        {
            let labelLineHeight = limitLine.valueFont.lineHeight
            
            let xOffset: CGFloat = limitLine.lineWidth + limitLine.xOffset
            
            if (limitLine.labelPosition == .rightTop)
            {
                ChartUtils.drawText(context: context,
                    text: label,
                    point: CGPoint(
                        x: position.x + xOffset,
                        y: viewPortHandler.contentTop + yOffset),
                    align: .left,
                    attributes: [NSFontAttributeName: limitLine.valueFont, NSForegroundColorAttributeName: limitLine.valueTextColor])
            }
            else if (limitLine.labelPosition == .rightBottom)
            {
                ChartUtils.drawText(context: context,
                    text: label,
                    point: CGPoint(
                        x: position.x + xOffset,
                        y: viewPortHandler.contentBottom - labelLineHeight - yOffset),
                    align: .left,
                    attributes: [NSFontAttributeName: limitLine.valueFont, NSForegroundColorAttributeName: limitLine.valueTextColor])
            }
            else if (limitLine.labelPosition == .leftTop)
            {
                ChartUtils.drawText(context: context,
                    text: label,
                    point: CGPoint(
                        x: position.x - xOffset,
                        y: viewPortHandler.contentTop + yOffset),
                    align: .right,
                    attributes: [NSFontAttributeName: limitLine.valueFont, NSForegroundColorAttributeName: limitLine.valueTextColor])
            }
            else
            {
                ChartUtils.drawText(context: context,
                    text: label,
                    point: CGPoint(
                        x: position.x - xOffset,
                        y: viewPortHandler.contentBottom - labelLineHeight - yOffset),
                    align: .right,
                    attributes: [NSFontAttributeName: limitLine.valueFont, NSForegroundColorAttributeName: limitLine.valueTextColor])
            }
        }
    }

}
