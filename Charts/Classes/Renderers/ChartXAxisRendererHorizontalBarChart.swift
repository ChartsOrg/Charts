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
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif


open class ChartXAxisRendererHorizontalBarChart: ChartXAxisRendererBarChart
{
    public override init(viewPortHandler: ChartViewPortHandler, xAxis: ChartXAxis, transformer: ChartTransformer!, chart: BarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: transformer, chart: chart)
    }
    
    open override func computeAxis(xValAverageLength: Double, xValues: [String?])
    {
        guard let xAxis = xAxis else { return }
        
        xAxis.values = xValues
       
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
        guard let xAxis = xAxis else { return }
        
        if !xAxis.enabled || !xAxis.drawLabelsEnabled || chart?.data === nil
        {
            return
        }
        
        let xoffset = xAxis.xOffset
        
        if (xAxis.labelPosition == .top)
        {
            drawLabels(context: context, pos: viewPortHandler.contentRight + xoffset, anchor: CGPoint(x: 0.0, y: 0.5))
        }
        else if (xAxis.labelPosition == .topInside)
        {
            drawLabels(context: context, pos: viewPortHandler.contentRight - xoffset, anchor: CGPoint(x: 1.0, y: 0.5))
        }
        else if (xAxis.labelPosition == .bottom)
        {
            drawLabels(context: context, pos: viewPortHandler.contentLeft - xoffset, anchor: CGPoint(x: 1.0, y: 0.5))
        }
        else if (xAxis.labelPosition == .bottomInside)
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
    open override func drawLabels(context: CGContext, pos: CGFloat, anchor: CGPoint)
    {
        guard let xAxis = xAxis,
              let bd = chart?.data as? BarChartData
        else { return }
        
        let labelFont = xAxis.labelFont
        let labelTextColor = xAxis.labelTextColor
        let labelRotationAngleRadians = xAxis.labelRotationAngle * ChartUtils.Math.FDEG2RAD
        
        // pre allocate to save performance (dont allocate in loop)
        var position = CGPoint(x: 0.0, y: 0.0)
        
        let step = bd.dataSetCount
        
		for i in stride(from: self.minX, to: min(self.maxX + 1, xAxis.values.count), by: xAxis.axisLabelModulus)
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
    
    open func drawLabel(context: CGContext, label: String, xIndex: Int, x: CGFloat, y: CGFloat, attributes: [String: NSObject], anchor: CGPoint, angleRadians: CGFloat)
    {
        guard let xAxis = xAxis else { return }
        
        let formattedLabel = xAxis.valueFormatter?.stringForXValue(xIndex, original: label, viewPortHandler: viewPortHandler) ?? label
        ChartUtils.drawText(context: context, text: formattedLabel, point: CGPoint(x: x, y: y), attributes: attributes, anchor: anchor, angleRadians: angleRadians)
    }
    
    private var _gridLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderGridLines(context: CGContext)
    {
        guard let xAxis = xAxis,
              let bd = chart?.data as? BarChartData
        else { return }
        
        if !xAxis.enabled || !xAxis.drawGridLinesEnabled
        {
            return
        }
        
        context.saveGState()
        
        context.setShouldAntialias(xAxis.gridAntialiasEnabled)
        context.setStrokeColor(xAxis.gridColor.cgColor)
        context.setLineWidth(xAxis.gridLineWidth)
        context.setLineCap(xAxis.gridLineCap)
        
        if (xAxis.gridLineDashLengths != nil)
        {
            context.setLineDash(phase: xAxis.gridLineDashPhase, lengths: xAxis.gridLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        // take into consideration that multiple DataSets increase _deltaX
        let step = bd.dataSetCount
        
		for i in stride(from: self.minX, to: min(self.maxX + 1, xAxis.values.count), by: xAxis.axisLabelModulus)
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
                context.strokeLineSegments(between: _gridLineSegmentsBuffer)
            }
        }
        
        context.restoreGState()
    }
    
    private var _axisLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderAxisLine(context: CGContext)
    {
        guard let xAxis = xAxis else { return }
        
        if (!xAxis.enabled || !xAxis.drawAxisLineEnabled)
        {
            return
        }
        
        context.saveGState()
        
        context.setStrokeColor(xAxis.axisLineColor.cgColor)
        context.setLineWidth(xAxis.axisLineWidth)
        if (xAxis.axisLineDashLengths != nil)
        {
            context.setLineDash(phase: xAxis.axisLineDashPhase, lengths: xAxis.axisLineDashLengths)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        if (xAxis.labelPosition == .top
            || xAxis.labelPosition == .topInside
            || xAxis.labelPosition == .bothSided)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }
        
        if (xAxis.labelPosition == .bottom
            || xAxis.labelPosition == .bottomInside
            || xAxis.labelPosition == .bothSided)
        {
            _axisLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[0].y = viewPortHandler.contentTop
            _axisLineSegmentsBuffer[1].x = viewPortHandler.contentLeft
            _axisLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
            context.strokeLineSegments(between: _axisLineSegmentsBuffer)
        }
        
        context.restoreGState()
    }
    
    private var _limitLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderLimitLines(context: CGContext)
    {
        guard let xAxis = xAxis else { return }
        
        var limitLines = xAxis.limitLines
        
        if (limitLines.count == 0)
        {
            return
        }
        
        context.saveGState()
        
        let trans = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for i in 0 ..< limitLines.count
        {
            let l = limitLines[i]
            
            if !l.enabled
            {
                continue
            }

            position.x = 0.0
            position.y = CGFloat(l.limit)
            position = position.applying(trans)
            
            _limitLineSegmentsBuffer[0].x = viewPortHandler.contentLeft
            _limitLineSegmentsBuffer[0].y = position.y
            _limitLineSegmentsBuffer[1].x = viewPortHandler.contentRight
            _limitLineSegmentsBuffer[1].y = position.y
            
            context.setStrokeColor(l.lineColor.cgColor)
            context.setLineWidth(l.lineWidth)
            if (l.lineDashLengths != nil)
            {
                context.setLineDash(phase: l.lineDashPhase, lengths: l.lineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            context.strokeLineSegments(between: _limitLineSegmentsBuffer)
            
            let label = l.label
            
            // if drawing the limit-value label is enabled
            if (l.drawLabelEnabled && label.characters.count > 0)
            {
                let labelLineHeight = l.valueFont.lineHeight
                
                let xOffset: CGFloat = 4.0 + l.xOffset
                let yOffset: CGFloat = l.lineWidth + labelLineHeight + l.yOffset
                
                if (l.labelPosition == .rightTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentRight - xOffset,
                            y: position.y - yOffset),
                        align: .right,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else if (l.labelPosition == .rightBottom)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentRight - xOffset,
                            y: position.y + yOffset - labelLineHeight),
                        align: .right,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else if (l.labelPosition == .leftTop)
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentLeft + xOffset,
                            y: position.y - yOffset),
                        align: .left,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
                else
                {
                    ChartUtils.drawText(context: context,
                        text: label,
                        point: CGPoint(
                            x: viewPortHandler.contentLeft + xOffset,
                            y: position.y + yOffset - labelLineHeight),
                        align: .left,
                        attributes: [NSFontAttributeName: l.valueFont, NSForegroundColorAttributeName: l.valueTextColor])
                }
            }
        }
        
        context.restoreGState()
    }
}
