//
//  XAxisRendererHorizontalBarChart.swift
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

open class XAxisRendererHorizontalBarChart: XAxisRenderer
{
    internal weak var chart: BarChartView?
    
    @objc public init(viewPortHandler: ViewPortHandler, axis: XAxis, transformer: Transformer?, chart: BarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, axis: axis, transformer: transformer)
        
        self.chart = chart
    }
    
    open override func computeAxis(min: Double, max: Double, inverted: Bool)
    {
        var min = min, max = max
        
        if let transformer = self.transformer,
            viewPortHandler.contentWidth > 10,
            !viewPortHandler.isFullyZoomedOutY
        {
            // calculate the starting and entry point of the y-labels (depending on
            // zoom / contentrect bounds)
            let p1 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
            let p2 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))

            min = inverted ? Double(p2.y) : Double(p1.y)
            max = inverted ? Double(p1.y) : Double(p2.y)
        }
        
        computeAxisValues(min: min, max: max)
    }
    
    open override func computeSize()
    {
        let longest = axis.getLongestLabel() as NSString
        
        let labelSize = longest.size(withAttributes: [.font: axis.labelFont])

        let labelWidth = floor(labelSize.width + axis.xOffset * 3.5)
        let labelHeight = labelSize.height
        let labelRotatedSize = CGSize(width: labelSize.width, height: labelHeight).rotatedBy(degrees: axis.labelRotationAngle)

        axis.labelWidth = labelWidth
        axis.labelHeight = labelHeight
        axis.labelRotatedWidth = round(labelRotatedSize.width + axis.xOffset * 3.5)
        axis.labelRotatedHeight = round(labelRotatedSize.height)
    }

    open override func renderAxisLabels(context: CGContext)
    {
        guard
            axis.isEnabled,
            axis.isDrawLabelsEnabled,
            chart?.data != nil
            else { return }
        
        let xoffset = axis.xOffset

        switch axis.labelPosition {
        case .top:
            drawLabels(context: context, pos: viewPortHandler.contentRight + xoffset, anchor: CGPoint(x: 0.0, y: 0.5))

        case .topInside:
            drawLabels(context: context, pos: viewPortHandler.contentRight - xoffset, anchor: CGPoint(x: 1.0, y: 0.5))

        case .bottom:
            drawLabels(context: context, pos: viewPortHandler.contentLeft - xoffset, anchor: CGPoint(x: 1.0, y: 0.5))

        case .bottomInside:
            drawLabels(context: context, pos: viewPortHandler.contentLeft + xoffset, anchor: CGPoint(x: 0.0, y: 0.5))

        case .bothSided:
            drawLabels(context: context, pos: viewPortHandler.contentRight + xoffset, anchor: CGPoint(x: 0.0, y: 0.5))
            drawLabels(context: context, pos: viewPortHandler.contentLeft - xoffset, anchor: CGPoint(x: 1.0, y: 0.5))
        }
    }

    /// draws the x-labels on the specified y-position
    open override func drawLabels(context: CGContext, pos: CGFloat, anchor: CGPoint)
    {
        guard let transformer = self.transformer else { return }
        
        let labelFont = axis.labelFont
        let labelTextColor = axis.labelTextColor
        let labelRotationAngleRadians = axis.labelRotationAngle.DEG2RAD
        
        let centeringEnabled = axis.isCenterAxisLabelsEnabled
        
        // pre allocate to save performance (dont allocate in loop)
        var position = CGPoint.zero
        
        for i in 0..<axis.entryCount
        {
            // only fill x values
            position.x = 0.0
            position.y = centeringEnabled ? CGFloat(axis.centeredEntries[i]) : CGFloat(axis.entries[i])

            transformer.pointValueToPixel(&position)
            
            if viewPortHandler.isInBoundsY(position.y),
                let label = axis.valueFormatter?.stringForValue(axis.entries[i], axis: axis)
            {
                drawLabel(context: context,
                          formattedLabel: label,
                          x: pos,
                          y: position.y,
                          attributes: [.font: labelFont, .foregroundColor: labelTextColor],
                          anchor: anchor,
                          angleRadians: labelRotationAngleRadians)
            }
        }
    }
    
    @objc open func drawLabel(
        context: CGContext,
        formattedLabel: String,
        x: CGFloat,
        y: CGFloat,
        attributes: [NSAttributedString.Key : Any],
        anchor: CGPoint,
        angleRadians: CGFloat)
    {
        context.drawText(formattedLabel,
                         at: CGPoint(x: x, y: y),
                         anchor: anchor,
                         angleRadians: angleRadians,
                         attributes: attributes)
    }
    
    open override var gridClippingRect: CGRect
    {
        var contentRect = viewPortHandler.contentRect
        let dy = self.axis.gridLineWidth
        contentRect.origin.y -= dy / 2.0
        contentRect.size.height += dy
        return contentRect
    }

    open override func drawGridLine(context: CGContext, x: CGFloat, y: CGFloat)
    {
        guard viewPortHandler.isInBoundsY(y) else { return }

        context.beginPath()
        context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: y))
        context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: y))
        context.strokePath()
    }
    
    open override func renderAxisLine(context: CGContext)
    {
        guard
            axis.isEnabled,
            axis.isDrawAxisLineEnabled
            else { return }

        context.saveGState()
        defer { context.restoreGState() }

        context.setStrokeColor(axis.axisLineColor.cgColor)
        context.setLineWidth(axis.axisLineWidth)
        if axis.axisLineDashLengths != nil
        {
            context.setLineDash(phase: axis.axisLineDashPhase, lengths: axis.axisLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        if axis.labelPosition == .top ||
            axis.labelPosition == .topInside ||
            axis.labelPosition == .bothSided
        {
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentBottom))
            context.strokePath()
        }
        
        if axis.labelPosition == .bottom ||
            axis.labelPosition == .bottomInside ||
            axis.labelPosition == .bothSided
        {
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
            context.strokePath()
        }
    }
    
    open override func renderLimitLines(context: CGContext)
    {
        guard let transformer = self.transformer else { return }
        
        let limitLines = axis.limitLines
        
        guard !limitLines.isEmpty else { return }

        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint.zero
        
        for l in limitLines where l.isEnabled
        {
            context.saveGState()
            defer { context.restoreGState() }
            
            var clippingRect = viewPortHandler.contentRect
            clippingRect.origin.y -= l.lineWidth / 2.0
            clippingRect.size.height += l.lineWidth
            context.clip(to: clippingRect)

            position.x = 0.0
            position.y = CGFloat(l.limit)
            position = position.applying(trans)
            
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: position.y))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: position.y))
            
            context.setStrokeColor(l.lineColor.cgColor)
            context.setLineWidth(l.lineWidth)
            if l.lineDashLengths != nil
            {
                context.setLineDash(phase: l.lineDashPhase, lengths: l.lineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            context.strokePath()
            
            let label = l.label
            
            // if drawing the limit-value label is enabled
            if l.drawLabelEnabled, !label.isEmpty
            {

                let labelLineSize = label.size(withAttributes: [.font: l.valueFont])
                let labelLineRotatedSize = labelLineSize.rotatedBy(degrees: l.labelRotationAngle)
                let labelLineRotatedWidth = labelLineRotatedSize.width
                let labelLineRotatedHeight = labelLineRotatedSize.height

                let xOffset = 4.0 + l.xOffset
                let yOffset = l.lineWidth + labelLineRotatedHeight + l.yOffset
                let labelRotationAngleRadians = l.labelRotationAngle.DEG2RAD

                let point: CGPoint
                let anchor = CGPoint(x: 0.0, y: 0.0)

                switch l.labelPosition
                {
                case .rightTop:
                    point = CGPoint(x: viewPortHandler.contentRight - labelLineRotatedWidth - xOffset,
                                    y: position.y - yOffset)

                case .rightBottom:
                    point = CGPoint(x: viewPortHandler.contentRight - labelLineRotatedWidth - xOffset,
                                    y: position.y - labelLineRotatedHeight + yOffset)

                case .leftTop:
                    point = CGPoint(x: viewPortHandler.contentLeft + xOffset,
                                    y: position.y - yOffset)

                case .leftBottom:
                    point = CGPoint(x: viewPortHandler.contentLeft + xOffset,
                                    y: position.y - labelLineRotatedHeight + yOffset)
                }

                let attributes: [NSAttributedString.Key : Any] = [
                    .font: l.valueFont,
                    .foregroundColor: l.valueTextColor
                ]

                context.drawText(label,
                                 at: point,
                                 anchor: anchor,
                                 angleRadians: labelRotationAngleRadians,
                                 attributes: attributes)
            }
        }
    }
}
