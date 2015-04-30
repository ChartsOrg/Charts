//
//  BarChartRenderer.swift
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
import UIKit.UIFont

@objc
public protocol BarChartRendererDelegate
{
    func barChartRendererData(renderer: BarChartRenderer) -> BarChartData!;
    func barChartRenderer(renderer: BarChartRenderer, transformerForAxis which: ChartYAxis.AxisDependency) -> ChartTransformer!;
    func barChartRendererMaxVisibleValueCount(renderer: BarChartRenderer) -> Int;
    func barChartDefaultRendererValueFormatter(renderer: BarChartRenderer) -> NSNumberFormatter!;
    func barChartRendererChartXMax(renderer: BarChartRenderer) -> Float;
    func barChartIsDrawHighlightArrowEnabled(renderer: BarChartRenderer) -> Bool;
    func barChartIsDrawValueAboveBarEnabled(renderer: BarChartRenderer) -> Bool;
    func barChartIsDrawValuesForWholeStackEnabled(renderer: BarChartRenderer) -> Bool;
    func barChartIsDrawBarShadowEnabled(renderer: BarChartRenderer) -> Bool;
    func barChartIsInverted(renderer: BarChartRenderer, axis: ChartYAxis.AxisDependency) -> Bool;
}

public class BarChartRenderer: ChartDataRendererBase
{
    public weak var delegate: BarChartRendererDelegate?;
    
    public init(delegate: BarChartRendererDelegate?, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler);
        
        self.delegate = delegate;
    }
    
    public override func drawData(#context: CGContext)
    {
        var barData = delegate!.barChartRendererData(self);
        
        if (barData === nil)
        {
            return;
        }
        
        for (var i = 0; i < barData.dataSetCount; i++)
        {
            var set = barData.getDataSetByIndex(i);
            
            if (set !== nil && set!.isVisible)
            {
                drawDataSet(context: context, dataSet: set as! BarChartDataSet, index: i);
            }
        }
    }
    
    internal func drawDataSet(#context: CGContext, dataSet: BarChartDataSet, index: Int)
    {
        CGContextSaveGState(context);
        
        var barData = delegate!.barChartRendererData(self);
        
        var trans = delegate!.barChartRenderer(self, transformerForAxis: dataSet.axisDependency);
        
        var drawBarShadowEnabled: Bool = delegate!.barChartIsDrawBarShadowEnabled(self);
        var dataSetOffset = (barData.dataSetCount - 1);
        var groupSpace = barData.groupSpace;
        var groupSpaceHalf = groupSpace / 2.0;
        var barSpace = dataSet.barSpace;
        var barSpaceHalf = barSpace / 2.0;
        var containsStacks = dataSet.isStacked;
        var isInverted = delegate!.barChartIsInverted(self, axis: dataSet.axisDependency);
        var entries = dataSet.yVals as! [BarChartDataEntry];
        var barWidth: CGFloat = 0.5;
        var phaseY = _animator.phaseY;
        var barRect = CGRect();
        var barShadow = CGRect();
        var y: Float;
        
        // do the drawing
        for (var j = 0, count = Int(ceil(CGFloat(dataSet.entryCount) * _animator.phaseX)); j < count; j++)
        {
            var e = entries[j];
            
            // calculate the x-position, depending on datasetcount
            var x = CGFloat(e.xIndex + j * dataSetOffset) + CGFloat(index)
                + groupSpace * CGFloat(j) + groupSpaceHalf;
            var vals = e.values;
            
            if (!containsStacks || vals == nil)
            {
                y = e.value;
                
                var left = x - barWidth + barSpaceHalf;
                var right = x + barWidth - barSpaceHalf;
                var top = isInverted ? (y <= 0.0 ? CGFloat(y) : 0) : (y >= 0.0 ? CGFloat(y) : 0);
                var bottom = isInverted ? (y >= 0.0 ? CGFloat(y) : 0) : (y <= 0.0 ? CGFloat(y) : 0);
                
                // multiply the height of the rect with the phase
                if (top > 0)
                {
                    top *= phaseY;
                }
                else
                {
                    bottom *= phaseY;
                }
                
                barRect.origin.x = left;
                barRect.size.width = right - left;
                barRect.origin.y = top;
                barRect.size.height = bottom - top;
                
                trans.rectValueToPixel(&barRect);
                
                if (!viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width))
                {
                    continue;
                }
                
                if (!viewPortHandler.isInBoundsRight(barRect.origin.x))
                {
                    break;
                }
                
                // if drawing the bar shadow is enabled
                if (drawBarShadowEnabled)
                {
                    barShadow.origin.x = barRect.origin.x;
                    barShadow.origin.y = viewPortHandler.contentTop;
                    barShadow.size.width = barRect.size.width;
                    barShadow.size.height = viewPortHandler.contentHeight;
                    
                    CGContextSetFillColorWithColor(context, dataSet.barShadowColor.CGColor);
                    CGContextFillRect(context, barShadow);
                }
                
                // Set the color for the currently drawn value. If the index is out of bounds, reuse colors.
                CGContextSetFillColorWithColor(context, dataSet.colorAt(j).CGColor);
                CGContextFillRect(context, barRect);
            }
            else
            {
                var all = e.value;
                
                // if drawing the bar shadow is enabled
                if (drawBarShadowEnabled)
                {
                    y = e.value;
                    
                    var left = x - barWidth + barSpaceHalf;
                    var right = x + barWidth - barSpaceHalf;
                    var top = isInverted ? (y <= 0.0 ? CGFloat(y) : 0) : (y >= 0.0 ? CGFloat(y) : 0);
                    var bottom = isInverted ? (y >= 0.0 ? CGFloat(y) : 0) : (y <= 0.0 ? CGFloat(y) : 0);
                    
                    // multiply the height of the rect with the phase
                    if (top > 0)
                    {
                        top *= phaseY;
                    }
                    else
                    {
                        bottom *= phaseY;
                    }
                    
                    barRect.origin.x = left;
                    barRect.size.width = right - left;
                    barRect.origin.y = top;
                    barRect.size.height = bottom - top;
                    
                    trans.rectValueToPixel(&barRect);
                    
                    barShadow.origin.x = barRect.origin.x;
                    barShadow.origin.y = viewPortHandler.contentTop;
                    barShadow.size.width = barRect.size.width;
                    barShadow.size.height = viewPortHandler.contentHeight;
                    
                    CGContextSetFillColorWithColor(context, dataSet.barShadowColor.CGColor);
                    CGContextFillRect(context, barShadow);
                }
                
                // fill the stack
                for (var k = 0; k < vals.count; k++)
                {
                    all -= vals[k];
                    y = vals[k] + all;
                    
                    var left = x - barWidth + barSpaceHalf;
                    var right = x + barWidth - barSpaceHalf;
                    var top = y >= 0.0 ? CGFloat(y) : 0;
                    var bottom = y <= 0.0 ? CGFloat(y) : 0;
                    
                    // multiply the height of the rect with the phase
                    if (top > 0)
                    {
                        top *= phaseY;
                    }
                    else
                    {
                        bottom *= phaseY;
                    }
                    
                    barRect.origin.x = left;
                    barRect.size.width = right - left;
                    barRect.origin.y = top;
                    barRect.size.height = bottom - top;
                    
                    trans.rectValueToPixel(&barRect);
                    
                    if (k == 0 && !viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width))
                    {
                        // Skip to next bar
                        break;
                    }
                    
                    // avoid drawing outofbounds values
                    if (!viewPortHandler.isInBoundsRight(barRect.origin.x))
                    {
                        break;
                    }
                    
                    // Set the color for the currently drawn value. If the index is out of bounds, reuse colors.
                    CGContextSetFillColorWithColor(context, dataSet.colorAt(k).CGColor);
                    CGContextFillRect(context, barRect);
                }
            }
        }
        
        CGContextRestoreGState(context);
    }
    
    /// Prepares a bar for being highlighted.
    internal func prepareBarHighlight(#x: CGFloat, y: Float, barspacehalf: CGFloat, from: Float, trans: ChartTransformer, inout rect: CGRect)
    {
        let barWidth: CGFloat = 0.5;
        
        var left = x - barWidth + barspacehalf;
        var right = x + barWidth - barspacehalf;
        var top = y >= from ? CGFloat(y) : CGFloat(from);
        var bottom = y <= from ? CGFloat(y) : CGFloat(from);
        
        rect.origin.x = left;
        rect.origin.y = top;
        rect.size.width = right - left;
        rect.size.height = bottom - top;
        
        trans.rectValueToPixel(&rect, phaseY: _animator.phaseY);
    }
    
    public override func drawValues(#context: CGContext)
    {
        // if values are drawn
        if (passesCheck())
        {
            var barData = delegate!.barChartRendererData(self);
            
            var defaultValueFormatter = delegate!.barChartDefaultRendererValueFormatter(self);
            
            var dataSets = barData.dataSets;
            
            var drawValueAboveBar = delegate!.barChartIsDrawValueAboveBarEnabled(self);
            var drawValuesForWholeStackEnabled = delegate!.barChartIsDrawValuesForWholeStackEnabled(self);
            
            var valueTextHeight: CGFloat;
            var posOffset: CGFloat;
            var negOffset: CGFloat;
            
            for (var i = 0, count = barData.dataSetCount; i < count; i++)
            {
                var dataSet = dataSets[i];
                
                if (!dataSet.isDrawValuesEnabled)
                {
                    continue;
                }
                
                var isInverted = delegate!.barChartIsInverted(self, axis: dataSet.axisDependency);
                
                // calculate the correct offset depending on the draw position of the value
                let valueOffsetPlus: CGFloat = 5.0;
                var valueFont = dataSet.valueFont;
                var valueTextHeight = valueFont.lineHeight;
                posOffset = (drawValueAboveBar ? -(valueTextHeight + valueOffsetPlus) : valueOffsetPlus);
                negOffset = (drawValueAboveBar ? valueOffsetPlus : -(valueTextHeight + valueOffsetPlus));
                
                if (isInverted)
                {
                    posOffset = -posOffset - valueTextHeight;
                    negOffset = -negOffset - valueTextHeight;
                }
                
                var valueTextColor = dataSet.valueTextColor;
                
                var formatter = dataSet.valueFormatter;
                if (formatter === nil)
                {
                    formatter = defaultValueFormatter;
                }
                
                var trans = delegate!.barChartRenderer(self, transformerForAxis: dataSet.axisDependency);
                
                var entries = dataSet.yVals as! [BarChartDataEntry];
                
                var valuePoints = getTransformedValues(trans: trans, entries: entries, dataSetIndex: i);
                
                // if only single values are drawn (sum)
                if (!drawValuesForWholeStackEnabled)
                {
                    for (var j = 0, count = Int(ceil(CGFloat(valuePoints.count) * _animator.phaseX)); j < count; j++)
                    {
                        if (!viewPortHandler.isInBoundsRight(valuePoints[j].x))
                        {
                            break;
                        }
                        
                        if (!viewPortHandler.isInBoundsY(valuePoints[j].y)
                            || !viewPortHandler.isInBoundsLeft(valuePoints[j].x))
                        {
                            continue;
                        }
                        
                        var val = entries[j].value;
                    
                        drawValue(context: context,
                            value: formatter!.stringFromNumber(val)!,
                            xPos: valuePoints[j].x,
                            yPos: valuePoints[j].y + (val >= 0.0 ? posOffset : negOffset),
                            font: valueFont,
                            align: .Center,
                            color: valueTextColor);
                    }
                }
                else
                {
                    // if each value of a potential stack should be drawn
                    
                    for (var j = 0, count = Int(ceil(CGFloat(valuePoints.count) * _animator.phaseX)); j < count; j++)
                    {
                        var e = entries[j];
                        
                        var vals = e.values;
                        
                        // we still draw stacked bars, but there is one non-stacked in between
                        if (vals == nil)
                        {
                            if (!viewPortHandler.isInBoundsRight(valuePoints[j].x))
                            {
                                break;
                            }
                            
                            if (!viewPortHandler.isInBoundsY(valuePoints[j].y)
                                || !viewPortHandler.isInBoundsLeft(valuePoints[j].x))
                            {
                                continue;
                            }
                            
                            drawValue(context: context,
                                value: formatter!.stringFromNumber(e.value)!,
                                xPos: valuePoints[j].x,
                                yPos: valuePoints[j].y + (e.value >= 0.0 ? posOffset : negOffset),
                                font: valueFont,
                                align: .Center,
                                color: valueTextColor);
                        }
                        else
                        {
                            var transformed = [CGPoint]();
                            var cnt = 0;
                            var add = e.value;
                            
                            for (var k = 0; k < vals.count; k++)
                            {
                                add -= vals[cnt];
                                transformed.append(CGPoint(x: 0.0, y: (CGFloat(vals[cnt]) + CGFloat(add)) * _animator.phaseY));
                                cnt++;
                            }
                            
                            trans.pointValuesToPixel(&transformed);
                            
                            for (var k = 0; k < transformed.count; k++)
                            {
                                var x = valuePoints[j].x;
                                var y = transformed[k].y + (vals[k] >= 0 ? posOffset : negOffset);
                                
                                if (!viewPortHandler.isInBoundsRight(x))
                                {
                                    break;
                                }
                                
                                if (!viewPortHandler.isInBoundsY(y) || !viewPortHandler.isInBoundsLeft(x))
                                {
                                    continue;
                                }
                                
                                drawValue(context: context,
                                    value: formatter!.stringFromNumber(vals[k])!,
                                    xPos: x,
                                    yPos: y,
                                    font: valueFont,
                                    align: .Center,
                                    color: valueTextColor);
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Draws a value at the specified x and y position.
    internal func drawValue(#context: CGContext, value: String, xPos: CGFloat, yPos: CGFloat, font: UIFont, align: NSTextAlignment, color: UIColor)
    {
        ChartUtils.drawText(context: context, text: value, point: CGPoint(x: xPos, y: yPos), align: align, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: color]);
    }
    
    public override func drawExtras(#context: CGContext)
    {
        
    }
    
    private var _highlightArrowPtsBuffer = [CGPoint](count: 3, repeatedValue: CGPoint());
    
    public override func drawHighlighted(#context: CGContext, indices: [ChartHighlight])
    {
        var barData = delegate!.barChartRendererData(self);
        if (barData === nil)
        {
            return;
        }
        
        CGContextSaveGState(context);
        
        var setCount = barData.dataSetCount;
        var drawHighlightArrowEnabled = delegate!.barChartIsDrawHighlightArrowEnabled(self);
        var barRect = CGRect();
        
        for (var i = 0; i < indices.count; i++)
        {
            var h = indices[i];
            var index = h.xIndex;
            
            var dataSetIndex = h.dataSetIndex;
            var set = barData.getDataSetByIndex(dataSetIndex) as! BarChartDataSet!;
            
            if (set === nil)
            {
                continue;
            }
            
            var barspaceHalf = set.barSpace / 2.0;
            
            var trans = delegate!.barChartRenderer(self, transformerForAxis: set.axisDependency);
            
            CGContextSetFillColorWithColor(context, set.highlightColor.CGColor);
            CGContextSetAlpha(context, set.highLightAlpha);
            
            // check outofbounds
            if (index < barData.yValCount && index >= 0
                && CGFloat(index) < (CGFloat(delegate!.barChartRendererChartXMax(self)) * _animator.phaseX) / CGFloat(setCount))
            {
                var e = barData.getDataSetByIndex(dataSetIndex)!.entryForXIndex(index) as! BarChartDataEntry!;
                
                if (e === nil)
                {
                    continue;
                }
                
                var groupspace = barData.groupSpace;
                var isStack = h.stackIndex < 0 ? false : true;

                // calculate the correct x-position
                var x = CGFloat(index * setCount + dataSetIndex) + groupspace / 2.0 + groupspace * CGFloat(index);
                var y = isStack ? e.values[h.stackIndex] + e.getBelowSum(h.stackIndex) : e.value;
                
                // this is where the bar starts
                var from = isStack ? e.getBelowSum(h.stackIndex) : 0.0;

                prepareBarHighlight(x: x, y: y, barspacehalf: barspaceHalf, from: from, trans: trans, rect: &barRect);
                
                CGContextFillRect(context, barRect);
                
                if (drawHighlightArrowEnabled)
                {
                    CGContextSetAlpha(context, 1.0);
                    
                    // distance between highlight arrow and bar
                    var offsetY = _animator.phaseY * 0.07;
                    
                    CGContextSaveGState(context);
                    
                    var pixelToValueMatrix = trans.pixelToValueMatrix;
                    var onePoint = CGPoint(x: 100.0, y: 100.0);
                    onePoint.x = onePoint.x * sqrt(pixelToValueMatrix.a * pixelToValueMatrix.a + pixelToValueMatrix.c * pixelToValueMatrix.c);
                    onePoint.y = onePoint.y * sqrt(pixelToValueMatrix.b * pixelToValueMatrix.b + pixelToValueMatrix.d * pixelToValueMatrix.d);
                    var xToYRel = abs(onePoint.y / onePoint.x);
                    
                    var arrowWidth = set.barSpace / 2.0;
                    var arrowHeight = arrowWidth * xToYRel;
                    
                    _highlightArrowPtsBuffer[0].x = CGFloat(x) + 0.4;
                    _highlightArrowPtsBuffer[0].y = CGFloat(y) + offsetY;
                    _highlightArrowPtsBuffer[1].x = CGFloat(x) + 0.4 + arrowWidth;
                    _highlightArrowPtsBuffer[1].y = CGFloat(y) + offsetY - arrowHeight;
                    _highlightArrowPtsBuffer[2].x = CGFloat(x) + 0.4 + arrowWidth;
                    _highlightArrowPtsBuffer[2].y = CGFloat(y) + offsetY + arrowHeight;
                    
                    trans.pointValuesToPixel(&_highlightArrowPtsBuffer);
                    
                    CGContextBeginPath(context);
                    CGContextMoveToPoint(context, _highlightArrowPtsBuffer[0].x, _highlightArrowPtsBuffer[0].y);
                    CGContextAddLineToPoint(context, _highlightArrowPtsBuffer[1].x, _highlightArrowPtsBuffer[1].y);
                    CGContextAddLineToPoint(context, _highlightArrowPtsBuffer[2].x, _highlightArrowPtsBuffer[2].y);
                    CGContextClosePath(context);
                    
                    CGContextFillPath(context);
                    
                    CGContextRestoreGState(context);
                }
            }
        }
        
        CGContextRestoreGState(context);
    }
    
    public func getTransformedValues(#trans: ChartTransformer, entries: [BarChartDataEntry], dataSetIndex: Int) -> [CGPoint]
    {
        return trans.generateTransformedValuesBarChart(entries, dataSet: dataSetIndex, barData: delegate!.barChartRendererData(self)!, phaseY: _animator.phaseY);
    }
    
    internal func passesCheck() -> Bool
    {
        var barData = delegate!.barChartRendererData(self);
        
        if (barData === nil)
        {
            return false;
        }
        
        return CGFloat(barData.yValCount) < CGFloat(delegate!.barChartRendererMaxVisibleValueCount(self)) * viewPortHandler.scaleX;
    }
}