//
//  PieChartRenderer.swift
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

public class PieChartRenderer: ChartDataRendererBase
{
    public weak var chart: PieChartView?
    
    public var drawHoleEnabled = true
    public var holeTransparent = true
    public var holeColor: UIColor? = UIColor.whiteColor()
    public var holeRadiusPercent = CGFloat(0.5)
    public var holeAlpha = CGFloat(0.41)
    public var transparentCircleRadiusPercent = CGFloat(0.55)
    public var drawXLabelsEnabled = true
    public var usePercentValuesEnabled = false
    public var centerAttributedText: NSAttributedString?
    public var drawCenterTextEnabled = true
    public var centerTextRadiusPercent: CGFloat = 1.0
    
    public init(chart: PieChartView, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.chart = chart
    }
    
    public override func drawData(context context: CGContext)
    {
        guard let chart = chart else { return }
        
        let pieData = chart.data
        
        if (pieData != nil)
        {
            for set in pieData!.dataSets as! [IPieChartDataSet]
            {
                if set.isVisible && set.entryCount > 0
                {
                    drawDataSet(context: context, dataSet: set)
                }
            }
        }
    }
    
    public func drawDataSet(context context: CGContext, dataSet: IPieChartDataSet)
    {
        guard let
            chart = chart,
            data = chart.data,
            animator = animator
            else {return }
        
        var angle: CGFloat = 0.0
        let rotationAngle = chart.rotationAngle
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        let entryCount = dataSet.entryCount
        var drawAngles = chart.drawAngles
        let circleBox = chart.circleBox
        let radius = chart.radius
        let innerRadius = drawHoleEnabled && holeTransparent ? radius * holeRadiusPercent : 0.0
        
        CGContextSaveGState(context)
        
        for (var j = 0; j < entryCount; j++)
        {
            let sliceAngle = drawAngles[j]
            let sliceSpace = dataSet.sliceSpace
            
            guard let e = dataSet.entryForIndex(j) else { continue }
            
            // draw only if the value is greater than zero
            if ((abs(e.value) > 0.000001))
            {
                if (!chart.needsHighlight(xIndex: e.xIndex,
                    dataSetIndex: data.indexOfDataSet(dataSet)))
                {
                    let startAngle = rotationAngle + (angle + sliceSpace / 2.0) * phaseY
                    var sweepAngle = (sliceAngle - sliceSpace / 2.0) * phaseY
                    if (sweepAngle < 0.0)
                    {
                        sweepAngle = 0.0
                    }
                    let endAngle = startAngle + sweepAngle
                    
                    let path = CGPathCreateMutable()
                    CGPathMoveToPoint(path, nil, circleBox.midX, circleBox.midY)
                    CGPathAddArc(path, nil, circleBox.midX, circleBox.midY, radius, startAngle * ChartUtils.Math.FDEG2RAD, endAngle * ChartUtils.Math.FDEG2RAD, false)
                    CGPathCloseSubpath(path)
                    
                    if (innerRadius > 0.0)
                    {
                        CGPathMoveToPoint(path, nil, circleBox.midX, circleBox.midY)
                        CGPathAddArc(path, nil, circleBox.midX, circleBox.midY, innerRadius, startAngle * ChartUtils.Math.FDEG2RAD, endAngle * ChartUtils.Math.FDEG2RAD, false)
                        CGPathCloseSubpath(path)
                    }
                    
                    CGContextBeginPath(context)
                    CGContextAddPath(context, path)
                    CGContextSetFillColorWithColor(context, dataSet.colorAt(j).CGColor)
                    CGContextEOFillPath(context)
                }
            }
            
            angle += sliceAngle * phaseX
        }
        
        CGContextRestoreGState(context)
    }
    
    public override func drawValues(context context: CGContext)
    {
        guard let
            chart = chart,
            data = chart.data,
            animator = animator
            else { return }
        
        let center = chart.centerCircleBox
        
        // get whole the radius
        var r = chart.radius
        let rotationAngle = chart.rotationAngle
        var drawAngles = chart.drawAngles
        var absoluteAngles = chart.absoluteAngles
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        var off = r / 10.0 * 3.0
        
        if (drawHoleEnabled)
        {
            off = (r - (r * chart.holeRadiusPercent)) / 2.0
        }
        
        r -= off; // offset to keep things inside the chart
        
        var dataSets = data.dataSets
        
        let yValueSum = (data as! PieChartData).yValueSum
        
        let drawXVals = drawXLabelsEnabled
        
        var angle: CGFloat = 0.0
        var xIndex = 0
        
        for (var i = 0; i < dataSets.count; i++)
        {
            guard let dataSet = dataSets[i] as? IPieChartDataSet else { continue }
            
            let drawYVals = dataSet.isDrawValuesEnabled
            
            if (!drawYVals && !drawXVals)
            {
                continue
            }
            
            let valueFont = dataSet.valueFont
            
            guard let formatter = dataSet.valueFormatter else { continue }
            
            for (var j = 0, entryCount = dataSet.entryCount; j < entryCount; j++)
            {
                if (drawXVals && !drawYVals && (j >= data.xValCount || data.xVals[j] == nil))
                {
                    continue
                }
                
                guard let e = dataSet.entryForIndex(j) else { continue }
                
                if (xIndex == 0)
                {
                    angle = 0.0
                }
                else
                {
                    angle = absoluteAngles[xIndex - 1] * phaseX
                }
                
                let sliceAngle = drawAngles[xIndex]
                let sliceSpace = dataSet.sliceSpace
                
                // offset needed to center the drawn text in the slice
                let offset = (sliceAngle - sliceSpace / 2.0) / 2.0

                angle = angle + offset
                
                // calculate the text position
                let x = r
                    * cos((rotationAngle + angle * phaseY) * ChartUtils.Math.FDEG2RAD)
                    + center.x
                var y = r
                    * sin((rotationAngle + angle * phaseY) * ChartUtils.Math.FDEG2RAD)
                    + center.y

                let value = usePercentValuesEnabled ? e.value / yValueSum * 100.0 : e.value
                
                let val = formatter.stringFromNumber(value)!
                
                let lineHeight = valueFont.lineHeight
                y -= lineHeight
                
                // draw everything, depending on settings
                if (drawXVals && drawYVals)
                {
                    ChartUtils.drawText(
                        context: context,
                        text: val,
                        point: CGPoint(x: x, y: y),
                        align: .Center,
                        attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)]
                    )
                    
                    if (j < data.xValCount && data.xVals[j] != nil)
                    {
                        ChartUtils.drawText(
                            context: context,
                            text: data.xVals[j]!,
                            point: CGPoint(x: x, y: y + lineHeight),
                            align: .Center,
                            attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)]
                        )
                    }
                }
                else if (drawXVals)
                {
                    ChartUtils.drawText(
                        context: context,
                        text: data.xVals[j]!,
                        point: CGPoint(x: x, y: y + lineHeight / 2.0),
                        align: .Center,
                        attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)]
                    )
                }
                else if (drawYVals)
                {
                    ChartUtils.drawText(
                        context: context,
                        text: val,
                        point: CGPoint(x: x, y: y + lineHeight / 2.0),
                        align: .Center,
                        attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)]
                    )
                }
                
                xIndex++
            }
        }
    }
    
    public override func drawExtras(context context: CGContext)
    {
        drawHole(context: context)
        drawCenterText(context: context)
    }
    
    /// draws the hole in the center of the chart and the transparent circle / hole
    private func drawHole(context context: CGContext)
    {
        guard let
            chart = chart,
            animator = animator
            else { return }
        
        if (chart.drawHoleEnabled)
        {
            CGContextSaveGState(context)
            
            let radius = chart.radius
            let holeRadius = radius * holeRadiusPercent
            let center = chart.centerCircleBox
            
            if holeColor !== nil && holeColor != UIColor.clearColor()
            {
                // draw the hole-circle
                CGContextSetFillColorWithColor(context, holeColor!.CGColor)
                CGContextFillEllipseInRect(context, CGRect(x: center.x - holeRadius, y: center.y - holeRadius, width: holeRadius * 2.0, height: holeRadius * 2.0))
            }
            
            // only draw the circle if it can be seen (not covered by the hole)
            if holeColor != nil && transparentCircleRadiusPercent > holeRadiusPercent
            {
                let alpha = holeAlpha * animator.phaseX * animator.phaseY
                let secondHoleRadius = radius * transparentCircleRadiusPercent
                
                // make transparent
                CGContextSetFillColorWithColor(context, holeColor!.colorWithAlphaComponent(alpha).CGColor)
                
                // draw the transparent-circle
                CGContextFillEllipseInRect(context, CGRect(x: center.x - secondHoleRadius, y: center.y - secondHoleRadius, width: secondHoleRadius * 2.0, height: secondHoleRadius * 2.0))
            }
            
            CGContextRestoreGState(context)
        }
    }
    
    /// draws the description text in the center of the pie chart makes most sense when center-hole is enabled
    private func drawCenterText(context context: CGContext)
    {
        guard let
            chart = chart,
            centerAttributedText = centerAttributedText
            else { return }
        
        if drawCenterTextEnabled && centerAttributedText.length > 0
        {
            let center = chart.centerCircleBox
            let innerRadius = drawHoleEnabled && holeTransparent ? chart.radius * holeRadiusPercent : chart.radius
            let holeRect = CGRect(x: center.x - innerRadius, y: center.y - innerRadius, width: innerRadius * 2.0, height: innerRadius * 2.0)
            var boundingRect = holeRect
            
            if (centerTextRadiusPercent > 0.0)
            {
                boundingRect = CGRectInset(boundingRect, (boundingRect.width - boundingRect.width * centerTextRadiusPercent) / 2.0, (boundingRect.height - boundingRect.height * centerTextRadiusPercent) / 2.0)
            }
            
            let textBounds = centerAttributedText.boundingRectWithSize(boundingRect.size, options: [.UsesLineFragmentOrigin, .UsesFontLeading, .TruncatesLastVisibleLine], context: nil)
            
            var drawingRect = boundingRect
            drawingRect.origin.x += (boundingRect.size.width - textBounds.size.width) / 2.0
            drawingRect.origin.y += (boundingRect.size.height - textBounds.size.height) / 2.0
            drawingRect.size = textBounds.size
            
            CGContextSaveGState(context)

            let clippingPath = CGPathCreateWithEllipseInRect(holeRect, nil)
            CGContextBeginPath(context)
            CGContextAddPath(context, clippingPath)
            CGContextClip(context)
            
            centerAttributedText.drawWithRect(drawingRect, options: [.UsesLineFragmentOrigin, .UsesFontLeading, .TruncatesLastVisibleLine], context: nil)
            
            CGContextRestoreGState(context)
        }
    }
    
    public override func drawHighlighted(context context: CGContext, indices: [ChartHighlight])
    {
        guard let
            chart = chart,
            data = chart.data,
            animator = animator
            else { return }
        
        CGContextSaveGState(context)
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        var angle: CGFloat = 0.0
        let rotationAngle = chart.rotationAngle
        
        var drawAngles = chart.drawAngles
        var absoluteAngles = chart.absoluteAngles
        
        let innerRadius = drawHoleEnabled && holeTransparent ? chart.radius * holeRadiusPercent : 0.0
        
        for (var i = 0; i < indices.count; i++)
        {
            // get the index to highlight
            let xIndex = indices[i].xIndex
            if (xIndex >= drawAngles.count)
            {
                continue
            }
            
            guard let set = data.getDataSetByIndex(indices[i].dataSetIndex) as? IPieChartDataSet else { continue }
            
            if !set.isHighlightEnabled
            {
                continue
            }
            
            if (xIndex == 0)
            {
                angle = 0.0
            }
            else
            {
                angle = absoluteAngles[xIndex - 1] * phaseX
            }
            
            let sliceAngle = drawAngles[xIndex]
            let sliceSpace = set.sliceSpace
            
            let shift = set.selectionShift
            let circleBox = chart.circleBox
            
            let highlighted = CGRect(
                x: circleBox.origin.x - shift,
                y: circleBox.origin.y - shift,
                width: circleBox.size.width + shift * 2.0,
                height: circleBox.size.height + shift * 2.0)
            
            CGContextSetFillColorWithColor(context, set.colorAt(xIndex).CGColor)
            
            // redefine the rect that contains the arc so that the highlighted pie is not cut off
            
            let startAngle = rotationAngle + (angle + sliceSpace / 2.0) * phaseY
            var sweepAngle = (sliceAngle - sliceSpace / 2.0) * phaseY
            if (sweepAngle < 0.0)
            {
                sweepAngle = 0.0
            }
            let endAngle = startAngle + sweepAngle
            
            let path = CGPathCreateMutable()
            CGPathMoveToPoint(path, nil, highlighted.midX, highlighted.midY)
            CGPathAddArc(path, nil, highlighted.midX, highlighted.midY, highlighted.size.width / 2.0, startAngle * ChartUtils.Math.FDEG2RAD, endAngle * ChartUtils.Math.FDEG2RAD, false)
            CGPathCloseSubpath(path)
            
            if (innerRadius > 0.0)
            {
                CGPathMoveToPoint(path, nil, highlighted.midX, highlighted.midY)
                CGPathAddArc(path, nil, highlighted.midX, highlighted.midY, innerRadius, startAngle * ChartUtils.Math.FDEG2RAD, endAngle * ChartUtils.Math.FDEG2RAD, false)
                CGPathCloseSubpath(path)
            }
            
            CGContextBeginPath(context)
            CGContextAddPath(context, path)
            CGContextEOFillPath(context)
        }
        
        CGContextRestoreGState(context)
    }
}