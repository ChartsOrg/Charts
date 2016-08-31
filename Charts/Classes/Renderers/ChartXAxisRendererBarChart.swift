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


open class ChartXAxisRendererBarChart: ChartXAxisRenderer
{
    open weak var chart: BarChartView?
    
    public init(viewPortHandler: ChartViewPortHandler, xAxis: ChartXAxis, transformer: ChartTransformer!, chart: BarChartView)
    {
        super.init(viewPortHandler: viewPortHandler, xAxis: xAxis, transformer: transformer)
        
        self.chart = chart
    }
    
    /// draws the x-labels on the specified y-position
    open override func drawLabels(context: CGContext, pos: CGFloat, anchor: CGPoint)
    {
        guard let xAxis = xAxis,
              let barData = chart?.data as? BarChartData
        else { return }
        
        let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paraStyle.alignment = .center
        
        let labelAttrs: [String : NSObject] = [NSFontAttributeName: xAxis.labelFont,
            NSForegroundColorAttributeName: xAxis.labelTextColor,
            NSParagraphStyleAttributeName: paraStyle]
        let labelRotationAngleRadians = xAxis.labelRotationAngle * ChartUtils.Math.FDEG2RAD
        
        let step = barData.dataSetCount
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
        var labelMaxSize = CGSize()
        
        if (xAxis.wordWrapEnabled)
        {
            labelMaxSize.width = xAxis.wordWrapWidthPercent * valueToPixelMatrix.a
        }
        
		for i in stride(from: self.minX, to: min(self.maxX + 1, xAxis.values.count), by: xAxis.axisLabelModulus)
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
            
            position = position.applying(valueToPixelMatrix)
            
            if (viewPortHandler.isInBoundsX(position.x))
            {
                if (xAxis.avoidFirstLastClippingEnabled)
                {
                    // avoid clipping of the last
                    if (i == xAxis.values.count - 1)
                    {
                        let width = label!.size(attributes: labelAttrs).width
                        
                        if (position.x + width / 2.0 > viewPortHandler.contentRight)
                        {
                            position.x = viewPortHandler.contentRight - (width / 2.0)
                        }
                    }
                    else if (i == 0)
                    { // avoid clipping of the first
                        let width = label!.size(attributes: labelAttrs).width
                        
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
    
    private var _gridLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open override func renderGridLines(context: CGContext)
    {
        guard let xAxis = xAxis,
              let barData = chart?.data as? BarChartData
            else { return }
        
        if (!xAxis.drawGridLinesEnabled || !xAxis.enabled)
        {
            return
        }
        
        let step = barData.dataSetCount
        
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
        
        let valueToPixelMatrix = transformer.valueToPixelMatrix
        
        var position = CGPoint(x: 0.0, y: 0.0)
        
		for i in stride(from: self.minX, to: self.maxX, by: xAxis.axisLabelModulus)
        {
            position.x = CGFloat(i * step) + CGFloat(i) * barData.groupSpace - 0.5
            position.y = 0.0
            position = position.applying(valueToPixelMatrix)
            
            if (viewPortHandler.isInBoundsX(position.x))
            {
                _gridLineSegmentsBuffer[0].x = position.x
                _gridLineSegmentsBuffer[0].y = viewPortHandler.contentTop
                _gridLineSegmentsBuffer[1].x = position.x
                _gridLineSegmentsBuffer[1].y = viewPortHandler.contentBottom
                context.strokeLineSegments(between: _gridLineSegmentsBuffer)
            }
        }
        
        context.restoreGState()
    }
}
