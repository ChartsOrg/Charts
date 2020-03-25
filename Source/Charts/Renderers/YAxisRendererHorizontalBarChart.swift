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

open class YAxisRendererHorizontalBarChart: YAxisRenderer
{
    public override init(viewPortHandler: ViewPortHandler, axis: YAxis, transformer: Transformer?)
    {
        super.init(viewPortHandler: viewPortHandler, axis: axis, transformer: transformer)
    }

    /// Computes the axis values.
    open override func computeAxis(min: Double, max: Double, inverted: Bool)
    {
        guard let transformer = self.transformer else { return }
        
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
    open override func renderAxisLabels(context: CGContext)
    {
        if !axis.isEnabled || !axis.isDrawLabelsEnabled
        {
            return
        }
        
        let lineHeight = axis.labelFont.lineHeight
        let baseYOffset: CGFloat = 2.5
        
        let dependency = axis.axisDependency
        let labelPosition = axis.labelPosition
        
        var yPos: CGFloat = 0.0
        
        if dependency == .left
        {
            if labelPosition == .outsideChart
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
            if labelPosition == .outsideChart
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
            offset: axis.yOffset)
    }
    
    open override func renderAxisLine(context: CGContext)
    {
        if !axis.isEnabled || !axis.drawAxisLineEnabled
        {
            return
        }
        
        context.saveGState()
        
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

        if axis.axisDependency == .left
        {
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentTop))
            context.strokePath()
        }
        else
        {
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: viewPortHandler.contentBottom))
            context.strokePath()        }
        
        context.restoreGState()
    }

    /// draws the y-labels on the specified x-position
    @objc open func drawYLabels(
        context: CGContext,
        fixedPosition: CGFloat,
        positions: [CGPoint],
        offset: CGFloat)
    {
        let labelFont = axis.labelFont
        let labelTextColor = axis.labelTextColor
        
        let from = axis.isDrawBottomYLabelEntryEnabled ? 0 : 1
        let to = axis.isDrawTopYLabelEntryEnabled ? axis.entryCount : (axis.entryCount - 1)
        
        for i in stride(from: from, to: to, by: 1)
        {
            let text = axis.getFormattedLabel(i)
            
            context.drawText(text,
                             at: CGPoint(x: positions[i].x, y: fixedPosition - offset),
                             align: .center,
                             attributes: [.font: labelFont, .foregroundColor: labelTextColor])
        }
    }
    
    open override var gridClippingRect: CGRect
    {
        var contentRect = viewPortHandler.contentRect
        let dx = self.axis.gridLineWidth
        contentRect.origin.x -= dx / 2.0
        contentRect.size.width += dx
        return contentRect
    }
    
    open override func drawGridLine(
        context: CGContext,
        position: CGPoint)
    {
        context.beginPath()
        context.move(to: CGPoint(x: position.x, y: viewPortHandler.contentTop))
        context.addLine(to: CGPoint(x: position.x, y: viewPortHandler.contentBottom))
        context.strokePath()
    }
    
    open override func transformedPositions() -> [CGPoint]
    {
        guard let transformer = self.transformer else { return [] }
        
        var positions = [CGPoint]()
        positions.reserveCapacity(axis.entryCount)
        
        let entries = axis.entries
        
        for i in stride(from: 0, to: axis.entryCount, by: 1)
        {
            positions.append(CGPoint(x: entries[i], y: 0.0))
        }
        
        transformer.pointValuesToPixel(&positions)
        
        return positions
    }
    
    /// Draws the zero line at the specified position.
    open override func drawZeroLine(context: CGContext)
    {
        guard
            let transformer = self.transformer,
            let zeroLineColor = axis.zeroLineColor
            else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
        var clippingRect = viewPortHandler.contentRect
        clippingRect.origin.x -= axis.zeroLineWidth / 2.0
        clippingRect.size.width += axis.zeroLineWidth
        context.clip(to: clippingRect)
        
        context.setStrokeColor(zeroLineColor.cgColor)
        context.setLineWidth(axis.zeroLineWidth)
        
        let pos = transformer.pixelForValues(x: 0.0, y: 0.0)
        
        if axis.zeroLineDashLengths != nil
        {
            context.setLineDash(phase: axis.zeroLineDashPhase, lengths: axis.zeroLineDashLengths!)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        context.move(to: CGPoint(x: pos.x - 1.0, y: viewPortHandler.contentTop))
        context.addLine(to: CGPoint(x: pos.x - 1.0, y: viewPortHandler.contentBottom))
        context.drawPath(using: CGPathDrawingMode.stroke)
    }
    
    private var _limitLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderLimitLines(context: CGContext)
    {
        guard let transformer = self.transformer else { return }
        
        var limitLines = axis.limitLines

        if limitLines.count <= 0
        {
            return
        }
        
        context.saveGState()
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for i in 0 ..< limitLines.count
        {
            let l = limitLines[i]
            
            if !l.isEnabled
            {
                continue
            }
            
            context.saveGState()
            defer { context.restoreGState() }

            var clippingRect = viewPortHandler.contentRect
            clippingRect.origin.x -= l.lineWidth / 2.0
            clippingRect.size.width += l.lineWidth
            context.clip(to: clippingRect)
            
            position.x = CGFloat(l.limit)
            position.y = 0.0
            position = position.applying(trans)
            
            context.beginPath()
            context.move(to: CGPoint(x: position.x, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: position.x, y: viewPortHandler.contentBottom))
            
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
            if l.drawLabelEnabled && label.count > 0
            {
                let labelLineHeight = l.valueFont.lineHeight
                
                let xOffset: CGFloat = l.lineWidth + l.xOffset
                let yOffset: CGFloat = 2.0 + l.yOffset

                let align: NSTextAlignment
                let point: CGPoint

                switch l.labelPosition
                {
                case .rightTop:
                    align = .left
                    point = CGPoint(x: position.x + xOffset,
                                    y: viewPortHandler.contentTop + yOffset)

                case .rightBottom:
                    align = .left
                    point = CGPoint(x: position.x + xOffset,
                                    y: viewPortHandler.contentBottom - labelLineHeight - yOffset)

                case .leftTop:
                    align = .right
                    point = CGPoint(x: position.x - xOffset,
                                    y: viewPortHandler.contentTop + yOffset)

                case .leftBottom:
                    align = .right
                    point = CGPoint(x: position.x - xOffset,
                                    y: viewPortHandler.contentBottom - labelLineHeight - yOffset)
                }

                context.drawText(label,
                                 at: point,
                                 align: align,
                                 attributes: [.font: l.valueFont, .foregroundColor: l.valueTextColor])
            }
        }
        
        context.restoreGState()
    }
}
