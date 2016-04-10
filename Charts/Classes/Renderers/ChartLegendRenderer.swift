//
//  ChartLegendRenderer.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 4/3/15.
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


public class ChartLegendRenderer: ChartRendererBase
{
    /// the legend object this renderer renders
    public var legend: ChartLegend?

    public init(viewPortHandler: ChartViewPortHandler, legend: ChartLegend?)
    {
        super.init(viewPortHandler: viewPortHandler)
        
        self.legend = legend
    }

    /// Prepares the legend and calculates all needed forms, labels and colors.
    public func computeLegend(data: ChartData)
    {
        guard let legend = legend else { return }
        
        if (!legend.isLegendCustom)
        {
            var labels = [String?]()
            var colors = [NSUIColor?]()
            
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
                        labels.append(sLabels[j % sLabels.count])
                        colors.append(clrs[j])
                    }
                    
                    if (bds.label != nil)
                    {
                        // add the legend description label
                        colors.append(nil)
                        labels.append(bds.label)
                    }
                }
                else if (dataSet is IPieChartDataSet)
                {
                    var xVals = data.xVals
                    let pds = dataSet as! IPieChartDataSet
                    
                    for j in 0..<min(clrs.count, entryCount, xVals.count)
                    {
                        labels.append(xVals[j])
                        colors.append(clrs[j])
                    }
                    
                    if (pds.label != nil)
                    {
                        // add the legend description label
                        colors.append(nil)
                        labels.append(pds.label)
                    }
                }
                else if (dataSet is ICandleChartDataSet
                    && (dataSet as! ICandleChartDataSet).decreasingColor != nil)
                {
                    colors.append((dataSet as! ICandleChartDataSet).decreasingColor)
                    colors.append((dataSet as! ICandleChartDataSet).increasingColor)
                    labels.append(nil)
                    labels.append(dataSet.label)
                }
                else
                { // all others
                    
                    for j in 0..<min(clrs.count, entryCount)
                    {
                        // if multiple colors are set for a DataSet, group them
                        if (j < clrs.count - 1 && j < entryCount - 1)
                        {
                            labels.append(nil)
                        }
                        else
                        { // add label to the last entry
                            labels.append(dataSet.label)
                        }
                        
                        colors.append(clrs[j])
                    }
                }
            }
            
            legend.colors = colors + legend._extraColors
            legend.labels = labels + legend._extraLabels
        }
        
        // calculate all dimensions of the legend
        legend.calculateDimensions(labelFont: legend.font, viewPortHandler: viewPortHandler)
    }
    
    public func renderLegend(context context: CGContext)
    {
        guard let legend = legend else { return }
        
        if !legend.enabled
        {
            return
        }
        
        let labelFont = legend.font
        let labelTextColor = legend.textColor
        let labelLineHeight = labelFont.lineHeight
        let formYOffset = labelLineHeight / 2.0

        var labels = legend.labels
        var colors = legend.colors
        
        let formSize = legend.formSize
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
            
            for i in 0..<labels.count
            {
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
                
                let drawingForm = colors[i] != nil
                let isStacked = labels[i] == nil // grouped forms have null labels
                
                if (drawingForm)
                {
                    if (direction == .RightToLeft)
                    {
                        posX -= formSize
                    }
                    
                    drawForm(context: context, x: posX, y: posY + formYOffset, colorIndex: i, legend: legend)
                    
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
                    
                    drawLabel(context: context, x: posX, y: posY, label: labels[i]!, font: labelFont, textColor: labelTextColor)
                    
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
            
            for i in 0..<labels.count
            {
                let drawingForm = colors[i] != nil
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
                    
                    drawForm(context: context, x: posX, y: posY + formYOffset, colorIndex: i, legend: legend)
                    
                    if (direction == .LeftToRight)
                    {
                        posX += formSize
                    }
                }
                
                if (labels[i] != nil)
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
                        posX -= (labels[i] as NSString!).sizeWithAttributes([NSFontAttributeName: labelFont]).width
                    }
                    
                    if (!wasStacked)
                    {
                        drawLabel(context: context, x: posX, y: posY, label: labels[i]!, font: labelFont, textColor: labelTextColor)
                    }
                    else
                    {
                        posY += labelLineHeight + yEntrySpace
                        drawLabel(context: context, x: posX, y: posY, label: labels[i]!, font: labelFont, textColor: labelTextColor)
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
    public func drawForm(context context: CGContext, x: CGFloat, y: CGFloat, colorIndex: Int, legend: ChartLegend)
    {
        guard let formColor = legend.colors[colorIndex] where formColor != NSUIColor.clearColor() else {
            return
        }
        
        let formsize = legend.formSize
        
        CGContextSaveGState(context)
        defer { CGContextRestoreGState(context) }
        
        switch (legend.form)
        {
        case .Circle:
            CGContextSetFillColorWithColor(context, formColor.CGColor)
            CGContextFillEllipseInRect(context, CGRect(x: x, y: y - formsize / 2.0, width: formsize, height: formsize))
        case .Square:
            CGContextSetFillColorWithColor(context, formColor.CGColor)
            CGContextFillRect(context, CGRect(x: x, y: y - formsize / 2.0, width: formsize, height: formsize))
        case .Line:
            
            CGContextSetLineWidth(context, legend.formLineWidth)
            CGContextSetStrokeColorWithColor(context, formColor.CGColor)
            
            _formLineSegmentsBuffer[0].x = x
            _formLineSegmentsBuffer[0].y = y
            _formLineSegmentsBuffer[1].x = x + formsize
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