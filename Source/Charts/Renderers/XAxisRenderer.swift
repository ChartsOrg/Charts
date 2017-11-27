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

@objc(ChartXAxisRenderer)
open class XAxisRenderer: AxisRendererBase
{
    @objc public init(viewPortHandler: ViewPortHandler, xAxis: XAxis?, transformer: Transformer?)
    {
        super.init(viewPortHandler: viewPortHandler, transformer: transformer, axis: xAxis)
    }
    
    open override func computeAxis(min: Double, max: Double, inverted: Bool)
    {
        guard
            let transformer = self.transformer,
            viewPortHandler.contentWidth > 10,
            !viewPortHandler.isFullyZoomedOutX
            else { return computeAxisValues(min: min, max: max) }

        // calculate the starting and entry point of the y-labels
        // (depending on zoom / contentrect bounds)
        let p1 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
        let p2 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop))

        let min = inverted ? Double(p2.x) : Double(p1.x)
        let max = inverted ? Double(p1.x) : Double(p2.x)

        computeAxisValues(min: min, max: max)
    }
    
    open override func computeAxisValues(min: Double, max: Double)
    {
        super.computeAxisValues(min: min, max: max)
        
        computeSize()
    }
    
    @objc open func computeSize()
    {
        guard let xAxis = self.axis as? XAxis else { return }
        
        let longest = xAxis.getLongestLabel()
        
        let labelSize = longest.size(withAttributes: [NSAttributedStringKey.font: xAxis.labelFont])
        
        let labelWidth = labelSize.width
        let labelHeight = labelSize.height
        
        let labelRotatedSize = labelSize.rotatedBy(degrees: xAxis.labelRotationAngle)
        
        xAxis.labelWidth = labelWidth
        xAxis.labelHeight = labelHeight
        xAxis.labelRotatedWidth = labelRotatedSize.width
        xAxis.labelRotatedHeight = labelRotatedSize.height
    }
    
    open override func renderAxisLabels(context: CGContext)
    {
        guard
            let xAxis = self.axis as? XAxis,
            xAxis.isEnabled,
            xAxis.isDrawLabelsEnabled
            else { return }

        let yOffset = xAxis.yOffset

        switch xAxis.labelPosition {
        case .top:
            drawLabels(context: context, pos: viewPortHandler.contentTop - yOffset, anchor: CGPoint(x: 0.5, y: 1.0))

        case .topInside:
            drawLabels(context: context, pos: viewPortHandler.contentTop + yOffset + xAxis.labelRotatedHeight, anchor: CGPoint(x: 0.5, y: 1.0))

        case .bottom:
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yOffset, anchor: CGPoint(x: 0.5, y: 0.0))

        case .bottomInside:
            drawLabels(context: context, pos: viewPortHandler.contentBottom - yOffset - xAxis.labelRotatedHeight, anchor: CGPoint(x: 0.5, y: 0.0))

        case .bothSided:
            drawLabels(context: context, pos: viewPortHandler.contentTop - yOffset, anchor: CGPoint(x: 0.5, y: 1.0))
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yOffset, anchor: CGPoint(x: 0.5, y: 0.0))
        }
    }
    
    fileprivate var _axisLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderAxisLine(context: CGContext)
    {
        guard
            let xAxis = self.axis as? XAxis,
            xAxis.isEnabled,
            xAxis.isDrawAxisLineEnabled
            else { return }

        context.saveGState()
        defer { context.restoreGState() }

        context.setStrokeColor(xAxis.axisLineColor.cgColor)
        context.setLineWidth(xAxis.axisLineWidth)
        if xAxis.axisLineDashLengths != nil
        {
            context.setLineDash(phase: xAxis.axisLineDashPhase, lengths: xAxis.axisLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }

        if xAxis.labelPosition == .top
            || xAxis.labelPosition == .topInside
            || xAxis.labelPosition == .bothSided
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentTop
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }
        
        if xAxis.labelPosition == .bottom
            || xAxis.labelPosition == .bottomInside
            || xAxis.labelPosition == .bothSided
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentBottom
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }
    }
    
    /// draws the x-labels on the specified y-position
    @objc open func drawLabels(context: CGContext, pos: CGFloat, anchor: CGPoint)
    {
        guard
            let xAxis = self.axis as? XAxis,
            let transformer = self.transformer
            else { return }

        let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paraStyle.alignment = .center
        
        let labelAttrs: [NSAttributedStringKey : Any] = [.font: xAxis.labelFont,
                                                         .foregroundColor: xAxis.labelTextColor,
                                                         .paragraphStyle: paraStyle]
        let labelRotationAngleRadians = xAxis.labelRotationAngle * ChartUtils.Math.FDEG2RAD
        
        let centeringEnabled = xAxis.isCenterAxisLabelsEnabled

        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint.zero
        
        var labelMaxSize = CGSize()
        
        if xAxis.isWordWrapEnabled
        {
            labelMaxSize.width = xAxis.wordWrapWidthPercent * valueToPixelMatrix.a
        }
        
        let entries = xAxis.entries
        
        for i in entries.indices
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
            position = position.applying(valueToPixelMatrix)
            
            guard viewPortHandler.isInBoundsX(position.x) else { continue }
            let label = xAxis.valueFormatter?.stringForValue(entries[i], axis: xAxis) ?? ""

            let labelns = label as NSString

            if xAxis.isAvoidFirstLastClippingEnabled
            {
                // avoid clipping of the last
                if i == xAxis.entryCount - 1 && xAxis.entryCount > 1
                {
                    let width = labelns.boundingRect(with: labelMaxSize, options: .usesLineFragmentOrigin, attributes: labelAttrs, context: nil).size.width

                    if width > viewPortHandler.offsetRight * 2.0
                        && position.x + width > viewPortHandler.chartWidth
                    {
                        position.x -= width / 2.0
                    }
                }
                else if i == 0
                { // avoid clipping of the first
                    let width = labelns.boundingRect(with: labelMaxSize, options: .usesLineFragmentOrigin, attributes: labelAttrs, context: nil).size.width
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
    
    @objc open func drawLabel(
        context: CGContext,
        formattedLabel: String,
        x: CGFloat,
        y: CGFloat,
        attributes: [NSAttributedStringKey : Any],
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
    
    open override func renderGridLines(context: CGContext)
    {
        guard
            let xAxis = self.axis as? XAxis,
            let transformer = self.transformer,
            xAxis.isDrawGridLinesEnabled,
            xAxis.isEnabled
            else { return }

        context.saveGState()
        defer { context.restoreGState() }

        context.clip(to: self.gridClippingRect)
        context.setShouldAntialias(xAxis.gridAntialiasEnabled)
        context.setStrokeColor(xAxis.gridColor.cgColor)
        context.setLineWidth(xAxis.gridLineWidth)
        context.setLineCap(xAxis.gridLineCap)
        
        if xAxis.gridLineDashLengths != nil
        {
            context.setLineDash(phase: xAxis.gridLineDashPhase, lengths: xAxis.gridLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint.zero
        
        let entries = xAxis.entries
        
        for e in entries
        {
            position.x = CGFloat(e)
            position.y = position.x
            position = position.applying(valueToPixelMatrix)
            
            drawGridLine(context: context, x: position.x, y: position.y)
        }
    }
    
    @objc open var gridClippingRect: CGRect
    {
        var contentRect = viewPortHandler.contentRect
        let dx = self.axis?.gridLineWidth ?? 0.0
        contentRect.origin.x -= dx / 2.0
        contentRect.size.width += dx
        return contentRect
    }
    
    @objc open func drawGridLine(context: CGContext, x: CGFloat, y: CGFloat)
    {
        guard
            x >= viewPortHandler.offsetLeft,
            x <= viewPortHandler.chartWidth
            else { return }

        context.beginPath()
        context.move(to: CGPoint(x: x, y: viewPortHandler.contentTop))
        context.addLine(to: CGPoint(x: x, y: viewPortHandler.contentBottom))
        context.strokePath()
    }
    
    open override func renderLimitLines(context: CGContext)
    {
        guard
            let xAxis = self.axis as? XAxis,
            let transformer = self.transformer
            else { return }
        
        var limitLines = xAxis.limitLines
        
        guard !limitLines.isEmpty else { return }
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint.zero
        
        for l in limitLines where l.isEnabled
        {
            context.saveGState()
            defer { context.restoreGState() }
            
            var clippingRect = viewPortHandler.contentRect
            clippingRect.origin.x -= l.lineWidth / 2.0
            clippingRect.size.width += l.lineWidth
            context.clip(to: clippingRect)
            
            position.x = CGFloat(l.limit)
            position.y = 0.0
            position = position.applying(trans)
            
            renderLimitLineLine(context: context, limitLine: l, position: position)
            renderLimitLineLabel(context: context, limitLine: l, position: position, yOffset: 2.0 + l.yOffset)
        }
    }
    
    @objc open func renderLimitLineLine(context: CGContext, limitLine: ChartLimitLine, position: CGPoint)
    {
        
        context.beginPath()
        context.move(to: CGPoint(x: position.x, y: viewPortHandler.contentTop))
        context.addLine(to: CGPoint(x: position.x, y: viewPortHandler.contentBottom))
        
        context.setStrokeColor(limitLine.lineColor.cgColor)
        context.setLineWidth(limitLine.lineWidth)
        if limitLine.lineDashLengths != nil
        {
            context.setLineDash(phase: limitLine.lineDashPhase, lengths: limitLine.lineDashLengths!)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        context.strokePath()
    }
    
    @objc open func renderLimitLineLabel(context: CGContext, limitLine: ChartLimitLine, position: CGPoint, yOffset: CGFloat)
    {
        
        let label = limitLine.label
        // if drawing the limit-value label is enabled
        guard limitLine.drawLabelEnabled, !label.isEmpty else { return }

        let labelLineHeight = limitLine.valueFont.lineHeight
        let xOffset = limitLine.lineWidth + limitLine.xOffset

        switch limitLine.labelPosition {
        case .rightTop:
            ChartUtils.drawText(context: context,
                                text: label,
                                point: CGPoint(x: position.x + xOffset,
                                               y: viewPortHandler.contentTop + yOffset),
                                align: .left,
                                attributes: [.font: limitLine.valueFont,
                                             .foregroundColor: limitLine.valueTextColor])

        case .rightBottom:
            ChartUtils.drawText(context: context,
                                text: label,
                                point: CGPoint(x: position.x + xOffset,
                                               y: viewPortHandler.contentBottom - labelLineHeight - yOffset),
                                align: .left,
                                attributes: [.font: limitLine.valueFont,
                                             .foregroundColor: limitLine.valueTextColor])

        case .leftTop:
            ChartUtils.drawText(context: context,
                                text: label,
                                point: CGPoint(x: position.x - xOffset,
                                               y: viewPortHandler.contentTop + yOffset),
                                align: .right,
                                attributes: [.font: limitLine.valueFont,
                                             .foregroundColor: limitLine.valueTextColor])

        case .leftBottom:
            ChartUtils.drawText(context: context,
                                text: label,
                                point: CGPoint(x: position.x - xOffset,
                                               y: viewPortHandler.contentBottom - labelLineHeight - yOffset),
                                align: .right,
                                attributes: [.font: limitLine.valueFont,
                                             .foregroundColor: limitLine.valueTextColor])
        }
    }
}
