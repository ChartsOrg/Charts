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
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics
import UIKit

public class ChartLegendRenderer: ChartRendererBase
{
    /// the legend object this renderer renders
    internal var _legend: ChartLegend!

    public init(viewPortHandler: ChartViewPortHandler, legend: ChartLegend?)
    {
        super.init(viewPortHandler: viewPortHandler)
        _legend = legend
    }

    /// Prepares the legend and calculates all needed forms, labels and colors.
    public func computeLegend(data: ChartData)
    {
        if (!_legend.isLegendCustom)
        {
            var labels = [String?]()
            var colors = [UIColor?]()
            
            // loop for building up the colors and labels used in the legend
            for i in 0..<data.dataSetCount
            {
                let dataSet = data.getDataSetByIndex(i)!
                
                var clrs: [UIColor] = dataSet.colors
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
            
            _legend.colors = colors + _legend._extraColors
            _legend.labels = labels + _legend._extraLabels
        }
        
        // calculate all dimensions of the legend
        _legend.calculateDimensions(labelFont: _legend.font, viewPortHandler: viewPortHandler)
    }
    
    public func renderLegend(context context: CGContext)
    {
        if (_legend === nil || !_legend.enabled)
        {
            return
        }
        
        let labelFont = _legend.font
        let labelTextColor = _legend.textColor
        let labelLineHeight = labelFont.lineHeight
        let formYOffset = labelLineHeight / 2.0

        var labels = _legend.labels
        var colors = _legend.colors
        
        let formSize = _legend.formSize
        let formToTextSpace = _legend.formToTextSpace
        let xEntrySpace = _legend.xEntrySpace
        let direction = _legend.direction

        // space between the entries
        let stackSpace = _legend.stackSpace

        let yoffset = _legend.yOffset
        let xoffset = _legend.xOffset
        
        let legendPosition = _legend.position
        
        switch (legendPosition)
        {
        case
        .BelowChartLeft,
        .BelowChartRight,
        .BelowChartCenter,
        .AboveChartLeft,
        .AboveChartRight,
        .AboveChartCenter:
            
            let contentWidth: CGFloat = viewPortHandler.contentWidth
            
            var originPosX: CGFloat
            
            if (legendPosition == .BelowChartLeft || legendPosition == .AboveChartLeft)
            {
                originPosX = viewPortHandler.contentLeft + xoffset
                
                if (direction == .RightToLeft)
                {
                    originPosX += _legend.neededWidth
                }
            }
            else if (legendPosition == .BelowChartRight || legendPosition == .AboveChartRight)
            {
                originPosX = viewPortHandler.contentRight - xoffset
                
                if (direction == .LeftToRight)
                {
                    originPosX -= _legend.neededWidth
                }
            }
            else // .BelowChartCenter || .AboveChartCenter
            {
                originPosX = viewPortHandler.contentLeft + contentWidth / 2.0
            }
            
            var calculatedLineSizes = _legend.calculatedLineSizes
            var calculatedLabelSizes = _legend.calculatedLabelSizes
            var calculatedLabelBreakPoints = _legend.calculatedLabelBreakPoints
            
            var posX: CGFloat = originPosX
            var posY: CGFloat
            
            if (legendPosition == .AboveChartLeft
                || legendPosition == .AboveChartRight
                || legendPosition == .AboveChartCenter)
            {
                posY = 0
            }
            else
            {
                posY = viewPortHandler.chartHeight - yoffset - _legend.neededHeight
            }
            
            var lineIndex: Int = 0
            
            
            for i in 0..<labels.count
            {
                if (i < calculatedLabelBreakPoints.count && calculatedLabelBreakPoints[i])
                {
                    posX = originPosX
                    posY += labelLineHeight
                }
                
                if (posX == originPosX && legendPosition == .BelowChartCenter && lineIndex < calculatedLineSizes.count)
                {
                    posX += (direction == .RightToLeft ? calculatedLineSizes[lineIndex].width : -calculatedLineSizes[lineIndex].width) / 2.0
                    lineIndex++
                }
                
                let drawingForm = colors[i] != nil
                let isStacked = labels[i] == nil; // grouped forms have null labels
                
                if (drawingForm)
                {
                    if (direction == .RightToLeft)
                    {
                        posX -= formSize
                    }
                    
                    drawForm(context: context, x: posX, y: posY + formYOffset, colorIndex: i, legend: _legend)
                    
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
            
        case
        .PiechartCenter,
        .RightOfChart,
        .RightOfChartCenter,
        .RightOfChartInside,
        .LeftOfChart,
        .LeftOfChartCenter,
        .LeftOfChartInside:
            
            // contains the stacked legend size in pixels
            var stack = CGFloat(0.0)
            var wasStacked = false
            var posX: CGFloat = 0.0, posY: CGFloat = 0.0
            
            if (legendPosition == .PiechartCenter)
            {
                posX = viewPortHandler.chartWidth / 2.0 + (direction == .LeftToRight ? -_legend.textWidthMax / 2.0 : _legend.textWidthMax / 2.0)
                posY = viewPortHandler.chartHeight / 2.0 - _legend.neededHeight / 2.0 + _legend.yOffset
            }
            else
            {
                let isRightAligned = legendPosition == .RightOfChart ||
                    legendPosition == .RightOfChartCenter ||
                    legendPosition == .RightOfChartInside
                
                if (isRightAligned)
                {
                    posX = viewPortHandler.chartWidth - xoffset
                    if (direction == .LeftToRight)
                    {
                        posX -= _legend.textWidthMax
                    }
                }
                else
                {
                    posX = xoffset
                    if (direction == .RightToLeft)
                    {
                        posX += _legend.textWidthMax
                    }
                }
                
                switch legendPosition
                {
                case .RightOfChart, .LeftOfChart:
                    posY = viewPortHandler.contentTop + yoffset
                case .RightOfChartCenter, .LeftOfChartCenter:
                    posY = viewPortHandler.chartHeight / 2.0 - _legend.neededHeight / 2.0
                default: // case .RightOfChartInside, .LeftOfChartInside
                    posY = viewPortHandler.contentTop + yoffset
                }
            }
            
            for i in 0..<labels.count
            {
                let drawingForm = colors[i] != nil
                var x = posX
                
                if (drawingForm)
                {
                    if (direction == .LeftToRight)
                    {
                        x += stack
                    }
                    else
                    {
                        x -= formSize - stack
                    }
                    
                    drawForm(context: context, x: x, y: posY + formYOffset, colorIndex: i, legend: _legend)
                    
                    if (direction == .LeftToRight)
                    {
                        x += formSize
                    }
                }
                
                if (labels[i] != nil)
                {
                    if (drawingForm && !wasStacked)
                    {
                        x += direction == .LeftToRight ? formToTextSpace : -formToTextSpace
                    }
                    else if (wasStacked)
                    {
                        x = posX
                    }
                    
                    if (direction == .RightToLeft)
                    {
                        x -= (labels[i] as NSString!).sizeWithAttributes([NSFontAttributeName: labelFont]).width
                    }
                    
                    if (!wasStacked)
                    {
                        drawLabel(context: context, x: x, y: posY, label: labels[i]!, font: labelFont, textColor: labelTextColor)
                    }
                    else
                    {
                        posY += labelLineHeight
                        drawLabel(context: context, x: x, y: posY, label: labels[i]!, font: labelFont, textColor: labelTextColor)
                    }
                    
                    // make a step down
                    posY += labelLineHeight
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
    internal func drawForm(context context: CGContext, x: CGFloat, y: CGFloat, colorIndex: Int, legend: ChartLegend)
    {
        guard let formColor = legend.colors[colorIndex] where formColor != UIColor.clearColor() else {
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
    internal func drawLabel(context context: CGContext, x: CGFloat, y: CGFloat, label: String, font: UIFont, textColor: UIColor)
    {
        ChartUtils.drawText(context: context, text: label, point: CGPoint(x: x, y: y), align: .Left, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor])
    }
}