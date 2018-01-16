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
open class XAxisRenderer: NSObject, AxisRenderer
{
    public let viewPortHandler: ViewPortHandler
    public let axis: XAxis
    public let transformer: Transformer?

    @objc public init(viewPortHandler: ViewPortHandler, axis: XAxis, transformer: Transformer?)
    {
        self.viewPortHandler = viewPortHandler
        self.axis = axis
        self.transformer = transformer

        super.init()
    }
    
    open func computeAxis(min: Double, max: Double, inverted: Bool)
    {
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
        
        computeAxisValues(min: min, max: max)
    }
    
    open func computeAxisValues(min: Double, max: Double)
    {
        let yMin = min
        let yMax = max

        let labelCount = axis.labelCount
        let range = abs(yMax - yMin)

        if labelCount == 0 || range <= 0 || range.isInfinite
        {
            axis.entries = [Double]()
            axis.centeredEntries = [Double]()
            return
        }

        // Find out how much spacing (in y value space) between axis values
        let rawInterval = range / Double(labelCount)
        var interval = rawInterval.roundedToNextSignificant()

        // If granularity is enabled, then do not allow the interval to go below specified granularity.
        // This is used to avoid repeated values when rounding values for display.
        if axis.granularityEnabled
        {
            interval = interval < axis.granularity ? axis.granularity : interval
        }

        // Normalize interval
        let intervalMagnitude = pow(10.0, Double(Int(log10(interval)))).roundedToNextSignificant()
        let intervalSigDigit = Int(interval / intervalMagnitude)
        if intervalSigDigit > 5
        {
            // Use one order of magnitude higher, to avoid intervals like 0.9 or 90
            interval = floor(10.0 * Double(intervalMagnitude))
        }

        var n = axis.centerAxisLabelsEnabled ? 1 : 0

        // force label count
        if axis.isForceLabelsEnabled
        {
            interval = Double(range) / Double(labelCount - 1)

            // Ensure stops contains at least n elements.
            axis.entries.removeAll(keepingCapacity: true)
            axis.entries.reserveCapacity(labelCount)

            var v = yMin

            for _ in 0 ..< labelCount
            {
                axis.entries.append(v)
                v += interval
            }

            n = labelCount
        }
        else
        {
            // no forced count

            var first = interval == 0.0 ? 0.0 : ceil(yMin / interval) * interval

            if axis.centerAxisLabelsEnabled
            {
                first -= interval
            }

            let last = interval == 0.0 ? 0.0 : (floor(yMax / interval) * interval).nextUp

            if interval != 0.0 && last != first
            {
                for _ in stride(from: first, through: last, by: interval)
                {
                    n += 1
                }
            }

            // Ensure stops contains at least n elements.
            axis.entries.removeAll(keepingCapacity: true)
            axis.entries.reserveCapacity(labelCount)

            var f = first
            var i = 0
            while i < n
            {
                if f == 0.0
                {
                    // Fix for IEEE negative zero case (Where value == -0.0, and 0.0 == -0.0)
                    f = 0.0
                }

                axis.entries.append(Double(f))

                f += interval
                i += 1
            }
        }

        // set decimals
        if interval < 1
        {
            axis.decimals = Int(ceil(-log10(interval)))
        }
        else
        {
            axis.decimals = 0
        }

        if axis.centerAxisLabelsEnabled
        {
            axis.centeredEntries.reserveCapacity(n)
            axis.centeredEntries.removeAll()

            let offset: Double = interval / 2.0

            for i in 0 ..< n
            {
                axis.centeredEntries.append(axis.entries[i] + offset)
            }
        }
        
        computeSize()
    }
    
    @objc open func computeSize()
    {
        let longest = axis.getLongestLabel()
        
        let labelSize = longest.size(withAttributes: [.font: axis.labelFont])

        let labelWidth = labelSize.width
        let labelHeight = labelSize.height
        
        let labelRotatedSize = labelSize.rotatedBy(degrees: axis.labelRotationAngle)
        
        axis.labelWidth = labelWidth
        axis.labelHeight = labelHeight
        axis.labelRotatedWidth = labelRotatedSize.width
        axis.labelRotatedHeight = labelRotatedSize.height
    }
    
    open func renderAxisLabels(context: CGContext)
    {
        if !axis.isEnabled || !axis.isDrawLabelsEnabled
        {
            return
        }
        
        let yOffset = axis.yOffset
        
        if axis.labelPosition == .top
        {
            drawLabels(context: context, pos: viewPortHandler.contentTop - yOffset, anchor: CGPoint(x: 0.5, y: 1.0))
        }
        else if axis.labelPosition == .topInside
        {
            drawLabels(context: context, pos: viewPortHandler.contentTop + yOffset + axis.labelRotatedHeight, anchor: CGPoint(x: 0.5, y: 1.0))
        }
        else if axis.labelPosition == .bottom
        {
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yOffset, anchor: CGPoint(x: 0.5, y: 0.0))
        }
        else if axis.labelPosition == .bottomInside
        {
            drawLabels(context: context, pos: viewPortHandler.contentBottom - yOffset - axis.labelRotatedHeight, anchor: CGPoint(x: 0.5, y: 0.0))
        }
        else
        { // BOTH SIDED
            drawLabels(context: context, pos: viewPortHandler.contentTop - yOffset, anchor: CGPoint(x: 0.5, y: 1.0))
            drawLabels(context: context, pos: viewPortHandler.contentBottom + yOffset, anchor: CGPoint(x: 0.5, y: 0.0))
        }
    }
    
    private var _axisLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open func renderAxisLine(context: CGContext)
    {        
        if !axis.isEnabled || !axis.isDrawAxisLineEnabled
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
        
        if axis.labelPosition == .top
            || axis.labelPosition == .topInside
            || axis.labelPosition == .bothSided
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentTop
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }
        
        if axis.labelPosition == .bottom
            || axis.labelPosition == .bottomInside
            || axis.labelPosition == .bothSided
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
    @objc open func drawLabels(context: CGContext, pos: CGFloat, anchor: CGPoint)
    {
        guard let transformer = self.transformer else { return }
        
        #if os(OSX)
            let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        #else
            let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        #endif
        paraStyle.alignment = .center
        
        let labelAttrs: [NSAttributedStringKey : Any] = [.font: axis.labelFont,
                                                         .foregroundColor: axis.labelTextColor,
                                                         .paragraphStyle: paraStyle]
        let labelRotationAngleRadians = axis.labelRotationAngle.DEG2RAD

        let centeringEnabled = axis.isCenterAxisLabelsEnabled

        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        var labelMaxSize = CGSize()
        
        if axis.isWordWrapEnabled
        {
            labelMaxSize.width = axis.wordWrapWidthPercent * valueToPixelMatrix.a
        }
        
        let entries = axis.entries
        
        for i in stride(from: 0, to: entries.count, by: 1)
        {
            if centeringEnabled
            {
                position.x = CGFloat(axis.centeredEntries[i])
            }
            else
            {
                position.x = CGFloat(entries[i])
            }
            
            position.y = 0.0
            position = position.applying(valueToPixelMatrix)
            
            if viewPortHandler.isInBoundsX(position.x)
            {
                let label = axis.valueFormatter?.stringForValue(axis.entries[i], axis: axis) ?? ""

                let labelns = label as NSString
                
                if axis.isAvoidFirstLastClippingEnabled
                {
                    // avoid clipping of the last
                    if i == axis.entryCount - 1 && axis.entryCount > 1
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
                          constrainedTo: labelMaxSize,
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
        attributes: [NSAttributedStringKey : Any],
        constrainedTo size: CGSize,
        anchor: CGPoint,
        angleRadians: CGFloat)
    {
        context.drawMultilineText(formattedLabel,
                                  at: CGPoint(x: x, y: y),
                                  constrainedTo: size,
                                  anchor: anchor,
                                  angleRadians: angleRadians,
                                  attributes: attributes)
    }
    
    open func renderGridLines(context: CGContext)
    {
        guard let transformer = self.transformer else { return }
        
        if !axis.isDrawGridLinesEnabled || !axis.isEnabled
        {
            return
        }
        
        context.saveGState()
        defer { context.restoreGState() }
        context.clip(to: self.gridClippingRect)
        
        context.setShouldAntialias(axis.gridAntialiasEnabled)
        context.setStrokeColor(axis.gridColor.cgColor)
        context.setLineWidth(axis.gridLineWidth)
        context.setLineCap(axis.gridLineCap)
        
        if axis.gridLineDashLengths != nil
        {
            context.setLineDash(phase: axis.gridLineDashPhase, lengths: axis.gridLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        let entries = axis.entries
        
        for i in stride(from: 0, to: entries.count, by: 1)
        {
            position.x = CGFloat(entries[i])
            position.y = position.x
            position = position.applying(valueToPixelMatrix)
            
            drawGridLine(context: context, x: position.x, y: position.y)
        }
    }
    
    @objc open var gridClippingRect: CGRect
    {
        var contentRect = viewPortHandler.contentRect
        let dx = self.axis.gridLineWidth
        contentRect.origin.x -= dx / 2.0
        contentRect.size.width += dx
        return contentRect
    }
    
    @objc open func drawGridLine(context: CGContext, x: CGFloat, y: CGFloat)
    {
        if x >= viewPortHandler.offsetLeft
            && x <= viewPortHandler.chartWidth
        {
            context.beginPath()
            context.move(to: CGPoint(x: x, y: viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x: x, y: viewPortHandler.contentBottom))
            context.strokePath()
        }
    }
    
    open func renderLimitLines(context: CGContext)
    {
        guard let transformer = self.transformer else { return }
        
        var limitLines = axis.limitLines
        
        if limitLines.count == 0
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
        if limitLine.drawLabelEnabled && label.count > 0
        {
            let labelLineHeight = limitLine.valueFont.lineHeight
            
            let xOffset: CGFloat = limitLine.lineWidth + limitLine.xOffset

            let align: NSTextAlignment
            let point: CGPoint

            switch limitLine.labelPosition
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
                             attributes: [.font: limitLine.valueFont,
                                          .foregroundColor: limitLine.valueTextColor])
        }
    }
}
