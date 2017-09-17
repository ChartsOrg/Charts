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

#if !os(OSX)
    import UIKit
#endif

open class XAxisRendererHorizontalBarChart: XAxisRenderer
{
    internal var chart: BarChartView?
    
    public init(viewPortHandler: ViewPortHandler?, xAxis: XAxis?, transformer: Transformer?, chart: BarChartView?)
    {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: transformer)
        
        self.chart = chart
    }
    
    open override func computeAxis(min: Double, max: Double, isInverted inverted: Bool)
    {
        guard let viewPortHandler = self.viewPortHandler else { return }
        
        var min = min, max = max
        
        if let transformer = self.transformer
        {
            // calculate the starting and entry point of the y-labels (depending on
            // zoom / contentrect bounds)
            if viewPortHandler.contentWidth > 10 && !viewPortHandler.isFullyZoomedOutX
            {
                let p1 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
                let p2 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))

                min = inverted ? Double(p2.y) : Double(p1.y)
                max = inverted ? Double(p1.y) : Double(p2.y)
            }
        }
        
        computeAxisValues(min: min, max: max)
    }
    
    open override func computeSize()
    {
        guard let xAxis = self.axis as? XAxis else { return }
       
        let longest = xAxis.getLongestLabel() as NSString
        
        let labelSize = longest.size(attributes: [NSFontAttributeName: xAxis.labelFont])
        
        let labelWidth = floor(labelSize.width + xAxis.xOffset * 3.5)
        let labelHeight = labelSize.height
        
        let labelRotatedSize = ChartUtils.sizeOfRotatedRectangle(rectangleWidth: labelSize.width, rectangleHeight:  labelHeight, degrees: xAxis.labelRotationAngle)
        
        xAxis.labelWidth = labelWidth
        xAxis.labelHeight = labelHeight
        xAxis.labelRotatedWidth = round(labelRotatedSize.width + xAxis.xOffset * 3.5)
        xAxis.labelRotatedHeight = round(labelRotatedSize.height)
    }

    open override func renderAxisLabels(context: CGContext)
    {
        guard let xAxis = self.axis as? XAxis,
            let viewPortHandler = self.viewPortHandler,
            xAxis.isEnabled,
            xAxis.isDrawLabelsEnabled,
            chart?.data != nil
            else { return }

        let xoffset = xAxis.xOffset
        
        switch xAxis.labelPosition {
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
        guard let xAxis = self.axis as? XAxis,
            let transformer = self.transformer,
            let viewPortHandler = self.viewPortHandler
            else { return }
        
        let labelFont = xAxis.labelFont
        let labelTextColor = xAxis.labelTextColor
        let labelRotationAngleRadians = xAxis.labelRotationAngle * ChartUtils.Math.FDEG2RAD
        
        let centeringEnabled = xAxis.isCenterAxisLabelsEnabled
        
        // pre allocate to save performance (dont allocate in loop)
        var position = CGPoint()
        
        for i in 0..<xAxis.entryCount
        {
            // only fill x values
            position.x = 0.0
            position.y = centeringEnabled ? CGFloat(xAxis.centeredEntries[i]) : CGFloat(xAxis.entries[i])

            transformer.pointValueToPixel(&position)
            
            guard viewPortHandler.isInBoundsY(position.y),
                let label = xAxis.valueFormatter?.stringForValue(xAxis.entries[i], axis: xAxis)
                else { return }
            drawLabel(
                context: context,
                formattedLabel: label,
                x: pos,
                y: position.y,
                attributes: [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: labelTextColor],
                anchor: anchor,
                angleRadians: labelRotationAngleRadians)
        }
    }

    open func drawLabel(
        context: CGContext,
        formattedLabel: String,
        x: CGFloat,
        y: CGFloat,
        attributes: [String: NSObject],
        anchor: CGPoint,
        angleRadians: CGFloat)
    {
        ChartUtils.drawText(
            context: context,
            text: formattedLabel,
            point: CGPoint(x: x, y: y),
            attributes: attributes,
            anchor: anchor,
            angleRadians: angleRadians)
    }
    
    open override var gridClippingRect: CGRect
    {
        var contentRect = viewPortHandler?.contentRect ?? CGRect.zero
        let dy = self.axis?.gridLineWidth ?? 0.0
        contentRect.origin.y -= dy / 2.0
        contentRect.size.height += dy
        return contentRect
    }
    
    fileprivate var _gridLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func drawGridLine(context: CGContext, x: CGFloat, y: CGFloat)
    {
        guard let viewPortHandler = self.viewPortHandler,
            viewPortHandler.isInBoundsY(y)
            else { return }
        context.beginPath()
        context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: y))
        context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: y))
        context.strokePath()
    }

    open override func renderAxisLine(context: CGContext)
    {
        guard let xAxis = self.axis as? XAxis,
            let viewPortHandler = self.viewPortHandler,
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
        
        if xAxis.labelPosition == .top ||
            xAxis.labelPosition == .topInside ||
            xAxis.labelPosition == .bothSided
        {
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentBottom))
            context.strokePath()
        }
        
        if xAxis.labelPosition == .bottom ||
            xAxis.labelPosition == .bottomInside ||
            xAxis.labelPosition == .bothSided
        {
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
            context.strokePath()
        }
    }
    
    open override func renderLimitLines(context: CGContext)
    {
        guard let xAxis = self.axis as? XAxis,
            let viewPortHandler = self.viewPortHandler,
            let transformer = self.transformer
            else { return }
        
        var limitLines = xAxis.limitLines
        
        guard !limitLines.isEmpty else { return }
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
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
            guard l.drawLabelEnabled && label.characters.count > 0 else { continue }
            let labelLineHeight = l.valueFont.lineHeight

            let xOffset: CGFloat = 4.0 + l.xOffset
            let yOffset: CGFloat = l.lineWidth + labelLineHeight + l.yOffset

            switch l.labelPosition {
            case .rightTop:
                ChartUtils.drawText(context: context,
                                    text: label,
                                    point: CGPoint(x: viewPortHandler.contentRight - xOffset,
                                                   y: position.y - yOffset),
                                    align: .right,
                                    attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
            case .rightBottom:
                ChartUtils.drawText(context: context,
                                    text: label,
                                    point: CGPoint(x: viewPortHandler.contentRight - xOffset,
                                                   y: position.y + yOffset - labelLineHeight),
                                    align: .right,
                                    attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])

            case .leftTop:
                ChartUtils.drawText(context: context,
                                    text: label,
                                    point: CGPoint(x: viewPortHandler.contentLeft + xOffset,
                                                   y: position.y - yOffset),
                                    align: .left,
                                    attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])

            case .leftBottom:
                ChartUtils.drawText(context: context,
                                    text: label,
                                    point: CGPoint(x: viewPortHandler.contentLeft + xOffset,
                                                   y: position.y + yOffset - labelLineHeight),
                                    align: .left,
                                    attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
            }
        }
    }
}
