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
import CoreGraphics.CGBase
import UIKit.UIColor
import UIKit.UIFont

public class ChartLegendRenderer: ChartRendererBase
{
    /// the legend object this renderer renders
    internal var _legend: ChartLegend!;

    public init(viewPortHandler: ChartViewPortHandler, legend: ChartLegend?)
    {
        super.init(viewPortHandler: viewPortHandler);
        _legend = legend;
    }

    /// Prepares the legend and calculates all needed forms, labels and colors.
    public func computeLegend(data: ChartData)
    {
        var labels = [String?]();
        var colors = [UIColor?]();
        
        // loop for building up the colors and labels used in the legend
        for (var i = 0, count = data.dataSetCount; i < count; i++)
        {
            var dataSet = data.getDataSetByIndex(i)!;

            var clrs: [UIColor] = dataSet.colors;
            var entryCount = dataSet.entryCount;
            
            // if we have a barchart with stacked bars
            if (dataSet.isKindOfClass(BarChartDataSet) && (dataSet as! BarChartDataSet).isStacked)
            {
                var bds = dataSet as! BarChartDataSet;
                var sLabels = bds.stackLabels;

                for (var j = 0; j < clrs.count && j < bds.stackSize; j++) 
                {
                    labels.append(sLabels[j % sLabels.count]);
                    colors.append(clrs[j]);
                }

                // add the legend description label
                colors.append(UIColor.clearColor());
                labels.append(bds.label);

            }
            else if (dataSet.isKindOfClass(PieChartDataSet))
            {
                var xVals = data.xVals;
                var pds = dataSet as! PieChartDataSet;

                for (var j = 0; j < clrs.count && j < entryCount && j < xVals.count; j++)
                {
                    labels.append(xVals[j]);
                    colors.append(clrs[j]);
                }

                // add the legend description label
                colors.append(UIColor.clearColor());
                labels.append(pds.label);
            }
            else
            { // all others

                for (var j = 0; j < clrs.count && j < entryCount; j++)
                {
                    // if multiple colors are set for a DataSet, group them
                    if (j < clrs.count - 1 && j < entryCount - 1)
                    {
                        labels.append(nil);
                    }
                    else
                    { // add label to the last entry
                        labels.append(dataSet.label);
                    }

                    colors.append(clrs[j]);
                }
            }
        }

        _legend.colors = colors;
        _legend.labels = labels;
        
        // calculate all dimensions of the legend
        _legend.calculateDimensions(_legend.font);
    }
    
    public func renderLegend(#context: CGContext)
    {
        if (_legend === nil || !_legend.enabled)
        {
            return;
        }
        
        var labelFont = _legend.font;
        var labelTextColor = _legend.textColor;
        var labelLineHeight = labelFont.lineHeight;

        var labels = _legend.labels;
        
        var formSize = _legend.formSize;
        var formToTextSpace = _legend.formToTextSpace;
        var xEntrySpace = _legend.xEntrySpace;
        var direction = _legend.direction;

        // space between text and shape/form of entry
        var formTextSpaceAndForm = formToTextSpace + formSize;

        // space between the entries
        var stackSpace = _legend.stackSpace;

        // the amount of pixels the text needs to be set down to be on the same height as the form
        var textDrop = (labelFont.lineHeight + formSize) / 2.0;
        
        // contains the stacked legend size in pixels
        var stack = CGFloat(0.0);

        var wasStacked = false;

        var yoffset = _legend.yOffset;
        var xoffset = _legend.xOffset;
        
        switch (_legend.position)
        {
        case .BelowChartLeft:
            
            var posX = viewPortHandler.contentLeft + xoffset;
            var posY = viewPortHandler.chartHeight - yoffset;
            
            if (direction == .RightToLeft)
            {
                posX += _legend.neededWidth;
            }
            
            for (var i = 0, count = labels.count; i < count; i++)
            {
                var drawingForm = _legend.colors[i] != UIColor.clearColor();
                
                if (drawingForm)
                {
                    if (direction == .RightToLeft)
                    {
                        posX -= formSize;
                    }
                    
                    drawForm(context, x: posX, y: posY - _legend.textHeightMax / 2.0, colorIndex: i, legend: _legend);
                    
                    if (direction == .LeftToRight)
                    {
                        posX += formSize;
                    }
                }
                
                // grouped forms have null labels
                if (labels[i] != nil)
                {
                    // spacing between form and label
                    if (drawingForm)
                    {
                        posX += direction == .RightToLeft ? -formToTextSpace : formToTextSpace;
                    }
                    
                    if (direction == .RightToLeft)
                    {
                        posX -= (labels[i] as NSString!).sizeWithAttributes([NSFontAttributeName: labelFont]).width;
                    }
                    
                    drawLabel(context, x: posX, y: posY - _legend.textHeightMax, label: labels[i]!, font: labelFont, textColor: labelTextColor);
                    
                    if (direction == .LeftToRight)
                    {
                        posX += (labels[i] as NSString!).sizeWithAttributes([NSFontAttributeName: labelFont]).width;
                    }
                    
                    posX += direction == .RightToLeft ? -xEntrySpace : xEntrySpace;
                }
                else
                {
                    posX += direction == .RightToLeft ? -stackSpace : stackSpace;
                }
            }
            
            break;
        case .BelowChartRight:
            
            var posX = viewPortHandler.contentRight - xoffset;
            var posY = viewPortHandler.chartHeight - yoffset;
            
            for (var i = labels.count - 1; i >= 0; i--)
            {
                var drawingForm = _legend.colors[i] != UIColor.clearColor();
                
                if (direction == .RightToLeft && drawingForm)
                {
                    posX -= formSize;
                    drawForm(context, x: posX, y: posY - _legend.textHeightMax / 2.0, colorIndex: i, legend: _legend);
                    posX -= formToTextSpace;
                }
                
                if (labels[i] != nil)
                {
                    posX -= (labels[i] as NSString!).sizeWithAttributes([NSFontAttributeName: labelFont]).width;
                    drawLabel(context, x: posX, y: posY - _legend.textHeightMax, label: labels[i]!, font: labelFont, textColor: labelTextColor);
                }
                
                if (direction == .LeftToRight && drawingForm)
                {
                    posX -= formToTextSpace + formSize;
                    drawForm(context, x: posX, y: posY - _legend.textHeightMax / 2.0, colorIndex: i, legend: _legend);
                }
                
                posX -= labels[i] != nil ? xEntrySpace : stackSpace;
            }
            
            break;
        case .BelowChartCenter:
            
            var posX = viewPortHandler.chartWidth / 2.0 + (direction == .LeftToRight ? -_legend.neededWidth / 2.0 : _legend.neededWidth / 2.0);
            var posY = viewPortHandler.chartHeight - yoffset;
            
            for (var i = 0; i < labels.count; i++)
            {
                var drawingForm = _legend.colors[i] != UIColor.clearColor();
                
                if (drawingForm)
                {
                    if (direction == .RightToLeft)
                    {
                        posX -= formSize;
                    }
                    
                    drawForm(context, x: posX, y: posY - _legend.textHeightMax / 2.0, colorIndex: i, legend: _legend);
                    
                    if (direction == .LeftToRight)
                    {
                        posX += formSize;
                    }
                }
                
                // grouped forms have null labels
                if (labels[i] != nil)
                {
                    // spacing between form and label
                    if (drawingForm)
                    {
                        posX += direction == .RightToLeft ? -formToTextSpace : formToTextSpace;
                    }
                    
                    if (direction == .RightToLeft)
                    {
                        posX -= (labels[i] as NSString!).sizeWithAttributes([NSFontAttributeName: labelFont]).width;
                    }
                    
                    drawLabel(context, x: posX, y: posY - _legend.textHeightMax, label: labels[i]!, font: labelFont, textColor: labelTextColor);
                    
                    if (direction == .LeftToRight)
                    {
                        posX += (labels[i] as NSString!).sizeWithAttributes([NSFontAttributeName: labelFont]).width;
                    }
                    
                    posX += direction == .RightToLeft ? -xEntrySpace : xEntrySpace;
                }
                else
                {
                    posX += direction == .RightToLeft ? -stackSpace : stackSpace;
                }
            }
            
            break;
        case .PiechartCenter:
            
            var posX = viewPortHandler.chartWidth / 2.0 + (direction == .LeftToRight ? -_legend.textWidthMax / 2.0 : _legend.textWidthMax / 2.0);
            var posY = viewPortHandler.chartHeight / 2.0 - _legend.neededHeight / 2.0 + _legend.yOffset;
            
            for (var i = 0; i < labels.count; i++)
            {
                var drawingForm = _legend.colors[i] != UIColor.clearColor();
                var x = posX;
                
                if (drawingForm)
                {
                    if (direction == .LeftToRight)
                    {
                        x += stack;
                    }
                    else
                    {
                        x -= formSize - stack;
                    }
                    
                    drawForm(context, x: x, y: posY, colorIndex: i, legend: _legend);
                    
                    if (direction == .LeftToRight)
                    {
                        x += formSize;
                    }
                }
                
                if (labels[i] != nil)
                {
                    if (drawingForm && !wasStacked)
                    {
                        x += direction == .LeftToRight ? formToTextSpace : -formToTextSpace;
                    }
                    else if (wasStacked)
                    {
                        x = posX;
                    }
                    
                    if (direction == .RightToLeft)
                    {
                        x -= (labels[i] as NSString!).sizeWithAttributes([NSFontAttributeName: labelFont]).width;
                    }
                    
                    if (!wasStacked)
                    {
                        drawLabel(context, x: x, y: posY - _legend.textHeightMax / 2.0, label: labels[i]!, font: labelFont, textColor: labelTextColor);
                        
                        posY += textDrop;
                    }
                    else
                    {
                        posY += _legend.textHeightMax * 3.0;
                        drawLabel(context, x: x, y: posY - _legend.textHeightMax * 2.0, label: labels[i]!, font: labelFont, textColor: labelTextColor);
                    }
                    
                    // make a step down
                    posY += _legend.yEntrySpace;
                    stack = 0.0;
                }
                else
                {
                    stack += formSize + stackSpace;
                    wasStacked = true;
                }
            }
            
            break;
        case .RightOfChart: fallthrough
        case .RightOfChartCenter: fallthrough
        case .RightOfChartInside: fallthrough
        case .LeftOfChart: fallthrough
        case .LeftOfChartCenter: fallthrough
        case .LeftOfChartInside:
            
            var isRightAligned = _legend.position == .RightOfChart ||
                _legend.position == .RightOfChartCenter ||
                _legend.position == .RightOfChartInside;
            
            var posX: CGFloat = 0.0, posY: CGFloat = 0.0;
            
            if (isRightAligned)
            {
                posX = viewPortHandler.chartWidth - xoffset;
                if (direction == .LeftToRight)
                {
                    posX -= _legend.textWidthMax;
                }
            }
            else
            {
                posX = xoffset;
                if (direction == .RightToLeft)
                {
                    posX += _legend.textWidthMax;
                }
            }
            
            if (_legend.position == .RightOfChart ||
                _legend.position == .LeftOfChart)
            {
                posY = viewPortHandler.contentTop + yoffset
            }
            else if (_legend.position == .RightOfChartCenter ||
                _legend.position == .LeftOfChartCenter)
            {
                posY = viewPortHandler.chartHeight / 2.0 - _legend.neededHeight / 2.0;
            }
            else /*if (legend.position == .RightOfChartInside ||
                legend.position == .LeftOfChartInside)*/
            {
                posY = viewPortHandler.contentTop + yoffset;
            }
            
            for (var i = 0; i < labels.count; i++)
            {
                var drawingForm = _legend.colors[i] != UIColor.clearColor();
                var x = posX;
                
                if (drawingForm)
                {
                    if (direction == .LeftToRight)
                    {
                        x += stack;
                    }
                    else
                    {
                        x -= formSize - stack;
                    }
                    
                    drawForm(context, x: x, y: posY, colorIndex: i, legend: _legend);
                    
                    if (direction == .LeftToRight)
                    {
                        x += formSize;
                    }
                }
                
                if (labels[i] != nil)
                {
                    if (drawingForm && !wasStacked)
                    {
                        x += direction == .LeftToRight ? formToTextSpace : -formToTextSpace;
                    }
                    else if (wasStacked)
                    {
                        x = posX;
                    }
                    
                    if (direction == .RightToLeft)
                    {
                        x -= (labels[i] as NSString!).sizeWithAttributes([NSFontAttributeName: labelFont]).width;
                    }
                    
                    if (!wasStacked)
                    {
                        drawLabel(context, x: x, y: posY - _legend.textHeightMax / 2.0, label: _legend.getLabel(i)!, font: labelFont, textColor: labelTextColor);
                        
                        posY += textDrop;
                    }
                    else
                    {
                        posY += _legend.textHeightMax * 3.0;
                        drawLabel(context, x: x, y: posY - _legend.textHeightMax * 2.0, label: _legend.getLabel(i)!, font: labelFont, textColor: labelTextColor);
                    }
                    
                    // make a step down
                    posY += _legend.yEntrySpace;
                    stack = 0.0;
                }
                else
                {
                    stack += formSize + stackSpace;
                    wasStacked = true;
                }
            }
            
            break;
        }
    }

    private var _formLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint());
    
    /// Draws the Legend-form at the given position with the color at the given index.
    internal func drawForm(context: CGContext, x: CGFloat, y: CGFloat, colorIndex: Int, legend: ChartLegend)
    {
        var formColor = legend.colors[colorIndex];
        
        if (formColor === nil || formColor == UIColor.clearColor())
        {
            return;
        }
        
        var formsize = legend.formSize;
        
        CGContextSaveGState(context);
        
        switch (legend.form)
        {
        case .Circle:
            CGContextSetFillColorWithColor(context, formColor!.CGColor);
            CGContextFillEllipseInRect(context, CGRect(x: x, y: y - formsize / 2.0, width: formsize, height: formsize));
            break;
        case .Square:
            CGContextSetFillColorWithColor(context, formColor!.CGColor);
            CGContextFillRect(context, CGRect(x: x, y: y - formsize / 2.0, width: formsize, height: formsize));
            break;
        case .Line:
            
            CGContextSetLineWidth(context, legend.formLineWidth);
            CGContextSetStrokeColorWithColor(context, formColor!.CGColor);
            
            _formLineSegmentsBuffer[0].x = x;
            _formLineSegmentsBuffer[0].y = y;
            _formLineSegmentsBuffer[1].x = x + formsize;
            _formLineSegmentsBuffer[1].y = y;
            CGContextStrokeLineSegments(context, _formLineSegmentsBuffer, 2);
            
            break;
        }
        
        CGContextRestoreGState(context);
    }

    /// Draws the provided label at the given position.
    internal func drawLabel(context: CGContext, x: CGFloat, y: CGFloat, label: String, font: UIFont, textColor: UIColor)
    {
        ChartUtils.drawText(context: context, text: label, point: CGPoint(x: x, y: y), align: .Left, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor]);
    }
}