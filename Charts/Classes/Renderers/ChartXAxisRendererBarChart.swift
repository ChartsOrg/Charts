//
//  ChartXAxisRendererBarChart.swift
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


public class ChartXAxisRendererBarChart: ChartXAxisRenderer
{
    public weak var chart: BarChartView?
    
    public init(viewPortHandler: ChartViewPortHandler, xAxis: ChartXAxis, transformer: ChartTransformer!, chart: BarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: transformer)
        
        self.chart = chart
    }
    
    /// draws the x-labels on the specified y-position
    public override func drawLabels(context context: CGContext, pos: CGFloat, anchor: CGPoint)
    {
        guard let
            xAxis = xAxis,
            barData = chart?.data as? BarChartData
            else { return }
        
        let paraStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paraStyle.alignment = .Center
        
        let labelAttrs = [NSFontAttributeName: xAxis.labelFont,
            NSForegroundColorAttributeName: xAxis.labelTextColor,
            NSParagraphStyleAttributeName: paraStyle]
        let labelRotationAngleRadians = xAxis.labelRotationAngle * ChartUtils.Math.FDEG2RAD
        
        let step = barData.dataSetCount
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        var labelMaxSize = CGSize()
        
        if (xAxis.isWordWrapEnabled)
        {
            labelMaxSize.width = xAxis.wordWrapWidthPercent * valueToPixelMatrix.a
        }
        
        for i in self.minX.stride(to: min(self.maxX + 1, xAxis.values.count), by: xAxis.axisLabelModulus)
        {
            let label = i >= 0 && i < xAxis.values.count ? xAxis.values[i] : nil
            if (label == nil)
            {
                continue
            }
            
            position.x = CGFloat(i * step) + CGFloat(i) * barData.groupSpace + barData.groupSpace / 2.0
            position.y = 0.0
            
            // consider groups (center label for each group)
            if (step > 1)
            {
                position.x += (CGFloat(step) - 1.0) / 2.0
            }
            
            position = CGPointApplyAffineTransform(position, valueToPixelMatrix)
            
            if (viewPortHandler.isInBoundsX(position.x))
            {
                if (xAxis.isAvoidFirstLastClippingEnabled)
                {
                    // avoid clipping of the last
                    if (i == xAxis.values.count - 1)
                    {
                        let width = label!.sizeWithAttributes(labelAttrs).width
                        
                        if (position.x + width / 2.0 > viewPortHandler.contentRight)
                        {
                            position.x = viewPortHandler.contentRight - (width / 2.0)
                        }
                    }
                    else if (i == 0)
                    { // avoid clipping of the first
                        let width = label!.sizeWithAttributes(labelAttrs).width
                        
                        if (position.x - width / 2.0 < viewPortHandler.contentLeft)
                        {
                            position.x = viewPortHandler.contentLeft + (width / 2.0)
                        }
                    }
                }
                
                drawLabel(context: context, label: label!, xIndex: i, x: position.x, y: pos, attributes: labelAttrs, constrainedToSize: labelMaxSize, anchor: anchor, angleRadians: labelRotationAngleRadians)
            }
        }
    }
    
    private var _gridLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public override func renderGridLines(context context: CGContext)
    {
        guard let
            xAxis = xAxis,
            barData = chart?.data as? BarChartData
            else { return }
        
        if (!xAxis.isDrawGridLinesEnabled || !xAxis.isEnabled)
        {
            return
        }
        
        let step = barData.dataSetCount
        
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
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        for i in self.minX.stride(to: self.maxX, by: xAxis.axisLabelModulus)
        {
            position.x = CGFloat(i * step) + CGFloat(i) * barData.groupSpace - 0.5
            position.y = 0.0
            position = CGPointApplyAffineTransform(position, valueToPixelMatrix)
            
            if (viewPortHandler.isInBoundsX(position.x))
            {
                _gridLineSegmentsBuffer[0].x = position.x
                _gridLineSegmentsBuffer[0].y = viewPortHandler.contentTop
                _gridLineSegmentsBuffer[1].x = position.x
                _gridLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
                CGContextStrokeLineSegments(context, _gridLineSegmentsBuffer, 2)
            }
        }
        
        CGContextRestoreGState(context)
    }
}