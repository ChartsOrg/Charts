//
//  LegendRenderer.swift
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

@objc(ChartLegendRenderer)
public class LegendRenderer: Renderer
{
    /// the legend object this renderer renders
    public var legend: Legend?

    public init(viewPortHandler: ViewPortHandler?, legend: Legend?)
    {
        super.init(viewPortHandler: viewPortHandler)
        
        self.legend = legend
    }

    /// Prepares the legend and calculates all needed forms, labels and colors.
    public func computeLegend(data: ChartData)
    {
        guard let
            legend = legend,
            viewPortHandler = self.viewPortHandler
            else { return }
        
        if (!legend.isLegendCustom)
        {
            var entries: [LegendEntry] = []
            
            // loop for building up the colors and labels used in the legend
            for i in 0..<data.dataSetCount
            {
                let dataSet = data.getDataSetByIndex(i)!
                
                var clrs: [NSUIColor] = dataSet.colors
                let entryCount = dataSet.entryCount
                
                // if we have a barchart with stacked bars
                if (dataSet is IBarChartDataSet && (dataSet as! IBarChartDataSet).isStacked)
                {
                    let bds = dataSet as! IBarChartDataSet
                    var sLabels = bds.stackLabels
                    
                    for j in 0..<min(clrs.count, bds.stackSize)
                    {
                        entries.append(
                            LegendEntry(
                                label: sLabels[j % sLabels.count],
                                form: dataSet.form,
                                formSize: dataSet.formSize,
                                formLineWidth: dataSet.formLineWidth,
                                formLineDashPhase: dataSet.formLineDashPhase,
                                formLineDashLengths: dataSet.formLineDashLengths,
                                formColor: clrs[j]
                            )
                        )
                    }
                    
                    if dataSet.label != nil
                    {
                        // add the legend description label
                        
                        entries.append(
                            LegendEntry(
                                label: dataSet.label,
                                form: .None,
                                formSize: CGFloat.NaN,
                                formLineWidth: CGFloat.NaN,
                                formLineDashPhase: 0.0,
                                formLineDashLengths: nil,
                                formColor: nil
                            )
                        )
                    }
                }
                else if (dataSet is IPieChartDataSet)
                {
                    let pds = dataSet as! IPieChartDataSet
                    
                    for j in 0..<min(clrs.count, entryCount)
                    {
                        entries.append(
                            LegendEntry(
                                label: (pds.entryForIndex(j) as? PieChartDataEntry)?.label,
                                form: dataSet.form,
                                formSize: dataSet.formSize,
                                formLineWidth: dataSet.formLineWidth,
                                formLineDashPhase: dataSet.formLineDashPhase,
                                formLineDashLengths: dataSet.formLineDashLengths,
                                formColor: clrs[j]
                            )
                        )
                    }
                    
                    if dataSet.label != nil
                    {
                        // add the legend description label
                        
                        entries.append(
                            LegendEntry(
                                label: dataSet.label,
                                form: .None,
                                formSize: CGFloat.NaN,
                                formLineWidth: CGFloat.NaN,
                                formLineDashPhase: 0.0,
                                formLineDashLengths: nil,
                                formColor: nil
                            )
                        )
                    }
                }
                else if (dataSet is ICandleChartDataSet
                    && (dataSet as! ICandleChartDataSet).decreasingColor != nil)
                {
                    let candleDataSet = dataSet as! ICandleChartDataSet
                    
                    entries.append(
                        LegendEntry(
                            label: nil,
                            form: dataSet.form,
                            formSize: dataSet.formSize,
                            formLineWidth: dataSet.formLineWidth,
                            formLineDashPhase: dataSet.formLineDashPhase,
                            formLineDashLengths: dataSet.formLineDashLengths,
                            formColor: candleDataSet.decreasingColor
                        )
                    )
                    
                    entries.append(
                        LegendEntry(
                            label: dataSet.label,
                            form: dataSet.form,
                            formSize: dataSet.formSize,
                            formLineWidth: dataSet.formLineWidth,
                            formLineDashPhase: dataSet.formLineDashPhase,
                            formLineDashLengths: dataSet.formLineDashLengths,
                            formColor: candleDataSet.increasingColor
                        )
                    )
                }
                else
                { // all others
                    
                    for j in 0..<min(clrs.count, entryCount)
                    {
                        let label: String?
                        
                        // if multiple colors are set for a DataSet, group them
                        if (j < clrs.count - 1 && j < entryCount - 1)
                        {
                            label = nil
                        }
                        else
                        { // add label to the last entry
                            label = dataSet.label
                        }
                        
                        entries.append(
                            LegendEntry(
                                label: label,
                                form: dataSet.form,
                                formSize: dataSet.formSize,
                                formLineWidth: dataSet.formLineWidth,
                                formLineDashPhase: dataSet.formLineDashPhase,
                                formLineDashLengths: dataSet.formLineDashLengths,
                                formColor: clrs[j]
                            )
                        )
                    }
                }
            }
            
            legend.entries = entries + legend.extraEntries
        }
        
        // calculate all dimensions of the legend
        legend.calculateDimensions(labelFont: legend.font, viewPortHandler: viewPortHandler)
    }
    
    public func renderLegend(context context: CGContext)
    {
        guard let
            legend = legend,
            viewPortHandler = self.viewPortHandler
            else { return }
        
        if !legend.enabled
        {
            return
        }
        
        let labelFont = legend.font
        let labelTextColor = legend.textColor
        let labelLineHeight = labelFont.lineHeight
        let formYOffset = labelLineHeight / 2.0

        var entries = legend.entries
        
        let defaultFormSize = legend.formSize
        let formToTextSpace = legend.formToTextSpace
        let xEntrySpace = legend.xEntrySpace
        let yEntrySpace = legend.yEntrySpace
        
        let orientation = legend.orientation
        let horizontalAlignment = legend.horizontalAlignment
        let verticalAlignment = legend.verticalAlignment
        let direction = legend.direction

        // space between the entries
        let stackSpace = legend.stackSpace

        let yoffset = legend.yOffset
        let xoffset = legend.xOffset
        var originPosX: CGFloat = 0.0
        
        switch horizontalAlignment
        {
        case .Left:
            
            if orientation == .Vertical
            {
                originPosX = xoffset
            }
            else
            {
                originPosX = viewPortHandler.contentLeft + xoffset
            }
            
            if (direction == .RightToLeft)
            {
                originPosX += legend.neededWidth
            }
            
        case .Right:
            
            if orientation == .Vertical
            {
                originPosX = viewPortHandler.chartWidth - xoffset
            }
            else
            {
                originPosX = viewPortHandler.contentRight - xoffset
            }
            
            if (direction == .LeftToRight)
            {
                originPosX -= legend.neededWidth
            }
            
        case .Center:
            
            if orientation == .Vertical
            {
                originPosX = viewPortHandler.chartWidth / 2.0
            }
            else
            {
                originPosX = viewPortHandler.contentLeft
                    + viewPortHandler.contentWidth / 2.0
            }
            
            originPosX += (direction == .LeftToRight
                    ? +xoffset
                    : -xoffset)
            
            // Horizontally layed out legends do the center offset on a line basis,
            // So here we offset the vertical ones only.
            if orientation == .Vertical
            {
                originPosX += (direction == .LeftToRight
                    ? -legend.neededWidth / 2.0 + xoffset
                    : legend.neededWidth / 2.0 - xoffset)
            }
        }
        
        switch orientation
        {
        case .Horizontal:
            
            var calculatedLineSizes = legend.calculatedLineSizes
            var calculatedLabelSizes = legend.calculatedLabelSizes
            var calculatedLabelBreakPoints = legend.calculatedLabelBreakPoints
            
            var posX: CGFloat = originPosX
            var posY: CGFloat
            
            switch verticalAlignment
            {
            case .Top:
                posY = yoffset
                
            case .Bottom:
                posY = viewPortHandler.chartHeight - yoffset - legend.neededHeight
                
            case .Center:
                posY = (viewPortHandler.chartHeight - legend.neededHeight) / 2.0 + yoffset
            }
            
            var lineIndex: Int = 0
            
            for i in 0 ..< entries.count
            {
                let e = entries[i]
                let drawingForm = e.form != .None
                let formSize = isnan(e.formSize) ? defaultFormSize : e.formSize
                
                if (i < calculatedLabelBreakPoints.count && calculatedLabelBreakPoints[i])
                {
                    posX = originPosX
                    posY += labelLineHeight + yEntrySpace
                }
                
                if (posX == originPosX &&
                    horizontalAlignment == .Center &&
                    lineIndex < calculatedLineSizes.count)
                {
                    posX += (direction == .RightToLeft
                        ? calculatedLineSizes[lineIndex].width
                        : -calculatedLineSizes[lineIndex].width) / 2.0
                    lineIndex += 1
                }
                
                let isStacked = e.label == nil // grouped forms have null labels
                
                if drawingForm
                {
                    if (direction == .RightToLeft)
                    {
                        posX -= formSize
                    }
                    
                    drawForm(
                        context: context,
                        x: posX,
                        y: posY + formYOffset,
                        entry: e,
                        legend: legend)
                    
                    if (direction == .LeftToRight)
                    {
                        posX += formSize
                    }
                }
                
                if (!isStacked)
                {
                    if (drawingForm)
                    {
                        posX += direction == .RightToLeft ? -formToTextSpace : formToTextSpace
                    }
                    
                    if (direction == .RightToLeft)
                    {
                        posX -= calculatedLabelSizes[i].width
                    }
                    
                    drawLabel(
                        context: context,
                        x: posX,
                        y: posY,
                        label: e.label!,
                        font: labelFont,
                        textColor: labelTextColor)
                    
                    if (direction == .LeftToRight)
                    {
                        posX += calculatedLabelSizes[i].width
                    }
                    
                    posX += direction == .RightToLeft ? -xEntrySpace : xEntrySpace
                }
                else
                {
                    posX += direction == .RightToLeft ? -stackSpace : stackSpace
                }
            }
            
        case .Vertical:
            
            // contains the stacked legend size in pixels
            var stack = CGFloat(0.0)
            var wasStacked = false
            
            var posY: CGFloat = 0.0
            
            switch verticalAlignment
            {
            case .Top:
                posY = (horizontalAlignment == .Center
                    ? 0.0
                    : viewPortHandler.contentTop)
                posY += yoffset
                
            case .Bottom:
                posY = (horizontalAlignment == .Center
                    ? viewPortHandler.chartHeight
                    : viewPortHandler.contentBottom)
                posY -= legend.neededHeight + yoffset
                
            case .Center:
                
                posY = viewPortHandler.chartHeight / 2.0 - legend.neededHeight / 2.0 + legend.yOffset
            }
            
            for i in 0 ..< entries.count
            {
                let e = entries[i]
                let drawingForm = e.form != .None
                let formSize = isnan(e.formSize) ? defaultFormSize : e.formSize
                
                var posX = originPosX
                
                if (drawingForm)
                {
                    if (direction == .LeftToRight)
                    {
                        posX += stack
                    }
                    else
                    {
                        posX -= formSize - stack
                    }
                    
                    drawForm(
                        context: context,
                        x: posX,
                        y: posY + formYOffset,
                        entry: e,
                        legend: legend)
                    
                    if (direction == .LeftToRight)
                    {
                        posX += formSize
                    }
                }
                
                if (e.label != nil)
                {
                    if (drawingForm && !wasStacked)
                    {
                        posX += direction == .LeftToRight ? formToTextSpace : -formToTextSpace
                    }
                    else if (wasStacked)
                    {
                        posX = originPosX
                    }
                    
                    if (direction == .RightToLeft)
                    {
                        posX -= (e.label as NSString!).sizeWithAttributes([NSFontAttributeName: labelFont]).width
                    }
                    
                    if (!wasStacked)
                    {
                        drawLabel(context: context, x: posX, y: posY, label: e.label!, font: labelFont, textColor: labelTextColor)
                    }
                    else
                    {
                        posY += labelLineHeight + yEntrySpace
                        drawLabel(context: context, x: posX, y: posY, label: e.label!, font: labelFont, textColor: labelTextColor)
                    }
                    
                    // make a step down
                    posY += labelLineHeight + yEntrySpace
                    stack = 0.0
                }
                else
                {
                    stack += formSize + stackSpace
                    wasStacked = true
                }
            }
        }
    }

    private var _formLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    /// Draws the Legend-form at the given position with the color at the given index.
    public func drawForm(
        context context: CGContext,
                x: CGFloat,
                y: CGFloat,
                entry: LegendEntry,
                legend: Legend)
    {
        guard let formColor = entry.formColor
            where formColor != NSUIColor.clearColor()
            else { return }
        
        var form = entry.form
        if form == .Default
        {
            form = legend.form
        }
        
        let formSize = isnan(entry.formSize) ? legend.formSize : entry.formSize
        
        CGContextSaveGState(context)
        defer { CGContextRestoreGState(context) }
        
        switch form
        {
        case .None:
            // Do nothing
            break
            
        case .Empty:
            // Do not draw, but keep space for the form
            break
            
        case .Default: fallthrough
        case .Circle:
            
            CGContextSetFillColorWithColor(context, formColor.CGColor)
            CGContextFillEllipseInRect(context, CGRect(x: x, y: y - formSize / 2.0, width: formSize, height: formSize))
            
        case .Square:
            
            CGContextSetFillColorWithColor(context, formColor.CGColor)
            CGContextFillRect(context, CGRect(x: x, y: y - formSize / 2.0, width: formSize, height: formSize))
            
        case .Line:
            
            let formLineWidth = isnan(entry.formLineWidth) ? legend.formLineWidth : entry.formLineWidth
            let formLineDashPhase = isnan(entry.formLineDashPhase) ? legend.formLineDashPhase : entry.formLineDashPhase
            let formLineDashLengths = entry.formLineDashLengths == nil ? legend.formLineDashLengths : entry.formLineDashLengths
            
            CGContextSetLineWidth(context, formLineWidth)
            
            if formLineDashLengths != nil && formLineDashLengths!.count > 0
            {
                CGContextSetLineDash(context, formLineDashPhase, formLineDashLengths!, formLineDashLengths!.count)
            }
            else
            {
                CGContextSetLineDash(context, 0.0, nil, 0)
            }
            
            CGContextSetStrokeColorWithColor(context, formColor.CGColor)
            
            _formLineSegmentsBuffer[0].x = x
            _formLineSegmentsBuffer[0].y = y
            _formLineSegmentsBuffer[1].x = x + formSize
            _formLineSegmentsBuffer[1].y = y
            CGContextStrokeLineSegments(context, _formLineSegmentsBuffer, 2)
        }
    }

    /// Draws the provided label at the given position.
    public func drawLabel(context context: CGContext, x: CGFloat, y: CGFloat, label: String, font: NSUIFont, textColor: NSUIColor)
    {
        ChartUtils.drawText(context: context, text: label, point: CGPoint(x: x, y: y), align: .Left, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor])
    }
}