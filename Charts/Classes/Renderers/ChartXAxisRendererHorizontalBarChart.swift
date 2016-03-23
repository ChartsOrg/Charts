//
//  ChartXAxisRendererHorizontalBarChart.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 3/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif


public class ChartXAxisRendererHorizontalBarChart: ChartXAxisRendererBarChart
{
    public override init(viewPortHandler: ChartViewPortHandler, xAxis: ChartXAxis, transformer: ChartTransformer!, chart: BarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: transformer, chart: chart)
    }
    
    public override func computeAxis(xValAverageLength xValAverageLength: Double, xValues: [String?])
    {
        guard let xAxis = xAxis else { return }
        
        xAxis.values = xValues
       
        let longest = xAxis.getLongestLabel() as NSString
        
        let labelSize = longest.sizeWithAttributes([NSFontAttributeName: xAxis.labelFont])
        
        let labelWidth = floor(labelSize.width + xAxis.xOffset * 3.5)
        let labelHeight = labelSize.height
        
        let labelRotatedSize = ChartUtils.sizeOfRotatedRectangle(rectangleWidth: labelSize.width, rectangleHeight:  labelHeight, degrees: xAxis.labelRotationAngle)
        
        xAxis.labelWidth = labelWidth
        xAxis.labelHeight = labelHeight
        xAxis.labelRotatedWidth = round(labelRotatedSize.width + xAxis.xOffset * 3.5)
        xAxis.labelRotatedHeight = round(labelRotatedSize.height)
    }

    public override func renderAxisLabels(context context: CGContext)
    {
        guard let xAxis = xAxis else { return }
        
        if !xAxis.isEnabled || !xAxis.isDrawLabelsEnabled || chart?.data === nil
        {
            return
        }
        
        let xoffset = xAxis.xOffset
        
        if (xAxis.labelPosition == .Top)
        {
            drawLabels(context: context, pos: viewPortHandler.contentRight + xoffset, anchor: CGPoint(x: 0.0, y: 0.5))
        }
        else if (xAxis.labelPosition == .TopInside)
        {
            drawLabels(context: context, pos: viewPortHandler.contentRight - xoffset, anchor: CGPoint(x: 1.0, y: 0.5))
        }
        else if (xAxis.labelPosition == .Bottom)
        {
            drawLabels(context: context, pos: viewPortHandler.contentLeft - xoffset, anchor: CGPoint(x: 1.0, y: 0.5))
        }
        else if (xAxis.labelPosition == .BottomInside)
        {
            drawLabels(context: context, pos: viewPortHandler.contentLeft + xoffset, anchor: CGPoint(x: 0.0, y: 0.5))
        }
        else
        { // BOTH SIDED
            drawLabels(context: context, pos: viewPortHandler.contentRight + xoffset, anchor: CGPoint(x: 0.0, y: 0.5))
            drawLabels(context: context, pos: viewPortHandler.contentLeft - xoffset, anchor: CGPoint(x: 1.0, y: 0.5))
        }
    }

    /// draws the x-labels on the specified y-position
    public override func drawLabels(context context: CGContext, pos: CGFloat, anchor: CGPoint)
    {
        guard let
            xAxis = xAxis,
            bd = chart?.data as? BarChartData
            else { return }
        
        let labelFont = xAxis.labelFont
        let labelTextColor = xAxis.labelTextColor
        let labelRotationAngleRadians = xAxis.labelRotationAngle * ChartUtils.Math.FDEG2RAD
        
        // pre allocate to save performance (dont allocate in loop)
        var position = CGPoint(x: 0.0, y: 0.0)
        
        let step = bd.dataSetCount
        
        for i in self.minX.stride(to: min(self.maxX + 1, xAxis.values.count), by: xAxis.axisLabelModulus)
        {
            let label = xAxis.values[i]
            
            if (label == nil)
            {
                continue
            }
            
            position.x = 0.0
            position.y = CGFloat(i * step) + CGFloat(i) * bd.groupSpace + bd.groupSpace / 2.0
            
            // consider groups (center label for each group)
            if (step > 1)
            {
                position.y += (CGFloat(step) - 1.0) / 2.0
            }
            
            transformer.pointValueToPixel(&position)
            
            if (viewPortHandler.isInBoundsY(position.y))
            {
                drawLabel(context: context, label: label!, xIndex: i, x: pos, y: position.y, attributes: [NSFontAttributeName: labelFont, NSForegroundColorAttributeName: labelTextColor], anchor: anchor, angleRadians: labelRotationAngleRadians)
            }
        }
    }
    
    public func drawLabel(context context: CGContext, label: String, xIndex: Int, x: CGFloat, y: CGFloat, attributes: [String: NSObject], anchor: CGPoint, angleRadians: CGFloat)
    {
        guard let xAxis = xAxis else { return }
        
        let formattedLabel = xAxis.valueFormatter?.stringForXValue(xIndex, original: label, viewPortHandler: viewPortHandler) ?? label
        ChartUtils.drawText(context: context, text: formattedLabel, point: CGPoint(x: x, y: y), attributes: attributes, anchor: anchor, angleRadians: angleRadians)
    }
    
    private var _gridLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public override func renderGridLines(context context: CGContext)
    {
        guard let
            xAxis = xAxis,
            bd = chart?.data as? BarChartData
            else { return }
        
        if !xAxis.isEnabled || !xAxis.isDrawGridLinesEnabled
        {
            return
        }
        
        CGContextSaveGState(context)
        
        CGContextSetShouldAntialias(context, xAxis.gridAntialiasEnabled)
        CGContextSetStrokeColorWithColor(context, xAxis.gridColor.CGColor)
        CGContextSetLineWidth(context, xAxis.gridLineWidth)
        CGContextSetLineCap(context, xAxis.gridLineCap)
        
        if (xAxis.gridLineDashLengths != nil)
        {
            CGContextSetLineDash(context, xAxis.gridLineDashPhase, xAxis.gridLineDashLengths, xAxis.gridLineDashLengths.count)
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0)
        }
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        // take into consideration that multiple DataSets increase _deltaX
        let step = bd.dataSetCount
        
        for i in self.minX.stride(to: min(self.maxX + 1, xAxis.values.count), by: xAxis.axisLabelModulus)
        {
            position.x = 0.0
            position.y = CGFloat(i * step) + CGFloat(i) * bd.groupSpace - 0.5
            
            transformer.pointValueToPixel(&position)
            
            if (viewPortHandler.isInBoundsY(position.y))
            {
                _gridLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
                _gridLineSegmentsBuffer[0].y = position.y
                _gridLineSegmentsBuffer[1].x = viewPortHandler.contentRight
                _gridLineSegmentsBuffer[1].y = position.y
                CGContextStrokeLineSegments(context, _gridLineSegmentsBuffer, 2)
            }
        }
        
        CGContextRestoreGState(context)
    }
    
    private var _axisLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public override func renderAxisLine(context context: CGContext)
    {
        guard let xAxis = xAxis else { return }
        
        if (!xAxis.isEnabled || !xAxis.isDrawAxisLineEnabled)
        {
            return
        }
        
        CGContextSaveGState(context)
        
        CGContextSetStrokeColorWithColor(context, xAxis.axisLineColor.CGColor)
        CGContextSetLineWidth(context, xAxis.axisLineWidth)
        if (xAxis.axisLineDashLengths != nil)
        {
            CGContextSetLineDash(context, xAxis.axisLineDashPhase, xAxis.axisLineDashLengths, xAxis.axisLineDashLengths.count)
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0)
        }
        
        if (xAxis.labelPosition == .Top
            || xAxis.labelPosition == .TopInside
            || xAxis.labelPosition == .BothSided)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            CGContextStrokeLineSegments(context, _axisLineSegmentsBuffer, 2)
        }
        
        if (xAxis.labelPosition == .Bottom
            || xAxis.labelPosition == .BottomInside
            || xAxis.labelPosition == .BothSided)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            CGContextStrokeLineSegments(context, _axisLineSegmentsBuffer, 2)
        }
        
        CGContextRestoreGState(context)
    }
    
    private var _limitLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public override func renderLimitLines(context context: CGContext)
    {
        guard let xAxis = xAxis else { return }
        
        var limitLines = xAxis.limitLines
        
        if (limitLines.count == 0)
        {
            return
        }
        
        CGContextSaveGState(context)
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for i in 0 ..< limitLines.count
        {
            let l = limitLines[i]
            
            if !l.isEnabled
            {
                continue
            }

            position.x = 0.0
            position.y = CGFloat(l.limit)
            position = CGPointApplyAffineTransform(position, trans)
            
            _limitLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _limitLineSegmentsBuffer[0].y = position.y
            _limitLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _limitLineSegmentsBuffer[1].y = position.y
            
            CGContextSetStrokeColorWithColor(context, l.lineColor.CGColor)
            CGContextSetLineWidth(context, l.lineWidth)
            if (l.lineDashLengths != nil)
            {
                CGContextSetLineDash(context, l.lineDashPhase, l.lineDashLengths!, l.lineDashLengths!.count)
            }
            else
            {
                CGContextSetLineDash(context, 0.0, nil, 0)
            }
            
            CGContextStrokeLineSegments(context, _limitLineSegmentsBuffer, 2)
            
            let label = l.label
            
            // if drawing the limit-value label is enabled
            if (label.characters.count > 0)
            {
                let labelLineHeight = l.valueFont.lineHeight
                
                let xOffset: CGFloat = 4.0 + l.xOffset
                let yOffset: CGFloat = l.lineWidth + labelLineHeight + l.yOffset
                
                if (l.labelPosition == .RightTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentRight - xOffset,
                            y: position.y - yOffset),
                        align: .Right,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else if (l.labelPosition == .RightBottom)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentRight - xOffset,
                            y: position.y + yOffset - labelLineHeight),
                        align: .Right,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else if (l.labelPosition == .LeftTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentLeft + xOffset,
                            y: position.y - yOffset),
                        align: .Left,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentLeft + xOffset,
                            y: position.y + yOffset - labelLineHeight),
                        align: .Left,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
            }
        }
        
        CGContextRestoreGState(context)
    }
}