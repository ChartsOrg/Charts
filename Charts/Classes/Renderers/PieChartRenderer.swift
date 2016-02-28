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

#if !os(OSX)
    import UIKit
#endif


public class PieChartRenderer: ChartDataRendererBase
{
    public weak var chart: PieChartView?
    
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
    
    public func calculateMinimumRadiusForSpacedSlice(
        center center: CGPoint,
        radius: CGFloat,
        angle: CGFloat,
        arcStartPointX: CGFloat,
        arcStartPointY: CGFloat,
        startAngle: CGFloat,
        sweepAngle: CGFloat) -> CGFloat
    {
        let angleMiddle = startAngle + sweepAngle / 2.0
        
        // Other point of the arc
        let arcEndPointX = center.x + radius * cos((startAngle + sweepAngle) * ChartUtils.Math.FDEG2RAD)
        let arcEndPointY = center.y + radius * sin((startAngle + sweepAngle) * ChartUtils.Math.FDEG2RAD)
        
        // Middle point on the arc
        let arcMidPointX = center.x + radius * cos(angleMiddle * ChartUtils.Math.FDEG2RAD)
        let arcMidPointY = center.y + radius * sin(angleMiddle * ChartUtils.Math.FDEG2RAD)
        
        // Middle point on straight line between the two point.
        // This is the base of the contained triangle
        let basePointsDistance = sqrt(
            pow(arcEndPointX - arcStartPointX, 2) +
                pow(arcEndPointY - arcStartPointY, 2))
        
        // After reducing space from both sides of the "slice",
        //   the angle of the contained triangle should stay the same.
        // So let's find out the height of that triangle.
        let containedTriangleHeight = (basePointsDistance / 2.0 *
            tan((180.0 - angle) / 2.0 * ChartUtils.Math.FDEG2RAD))
        
        // Now we subtract that from the radius
        var spacedRadius = radius - containedTriangleHeight
        
        // And now subtract the height of the arc that's between the triangle and the outer circle
        spacedRadius -= sqrt(
            pow(arcMidPointX - (arcEndPointX + arcStartPointX) / 2.0, 2) +
                pow(arcMidPointY - (arcEndPointY + arcStartPointY) / 2.0, 2))
        
        return spacedRadius
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
        let sliceSpace = dataSet.sliceSpace
        let center = chart.centerCircleBox
        let radius = chart.radius
        let userInnerRadius = chart.drawHoleEnabled && !chart.drawSlicesUnderHoleEnabled ? radius * chart.holeRadiusPercent : 0.0
        
        var visibleAngleCount = 0
        for (var j = 0; j < entryCount; j++)
        {
            guard let e = dataSet.entryForIndex(j) else { continue }
            if ((abs(e.value) > 0.000001))
            {
                visibleAngleCount++;
            }
        }

        CGContextSaveGState(context)
        
        for (var j = 0; j < entryCount; j++)
        {
            let sliceAngle = drawAngles[j]
            var innerRadius = userInnerRadius
            
            guard let e = dataSet.entryForIndex(j) else { continue }
            
            // draw only if the value is greater than zero
            if ((abs(e.value) > 0.000001))
            {
                if (!chart.needsHighlight(xIndex: e.xIndex,
                    dataSetIndex: data.indexOfDataSet(dataSet)))
                {
                    CGContextSetFillColorWithColor(context, dataSet.colorAt(j).CGColor)
                    
                    let sliceSpaceOuterAngle = visibleAngleCount == 1 ?
                        0.0 :
                        sliceSpace / (ChartUtils.Math.FDEG2RAD * radius)
                    let startAngleOuter = rotationAngle + (angle + sliceSpaceOuterAngle / 2.0) * phaseY
                    var sweepAngleOuter = (sliceAngle - sliceSpaceOuterAngle) * phaseY
                    if (sweepAngleOuter < 0.0)
                    {
                        sweepAngleOuter = 0.0
                    }
                    
                    let arcStartPointX = center.x + radius * cos(startAngleOuter * ChartUtils.Math.FDEG2RAD)
                    let arcStartPointY = center.y + radius * sin(startAngleOuter * ChartUtils.Math.FDEG2RAD)

                    let path = CGPathCreateMutable()
                    
                    CGPathMoveToPoint(
                        path,
                        nil,
                        arcStartPointX,
                        arcStartPointY)
                    CGPathAddRelativeArc(
                        path,
                        nil,
                        center.x,
                        center.y,
                        radius,
                        startAngleOuter * ChartUtils.Math.FDEG2RAD,
                        sweepAngleOuter * ChartUtils.Math.FDEG2RAD)
                    
                    if sliceSpace > 0.0
                    {
                        innerRadius = max(innerRadius,
                            calculateMinimumRadiusForSpacedSlice(
                                center: center,
                                radius: radius,
                                angle: sliceAngle * phaseY,
                                arcStartPointX: arcStartPointX,
                                arcStartPointY: arcStartPointY,
                                startAngle: startAngleOuter,
                                sweepAngle: sweepAngleOuter))
                    }

                    if (innerRadius > 0.0)
                    {
                        let sliceSpaceInnerAngle = visibleAngleCount == 1 ?
                            0.0 :
                            sliceSpace / (ChartUtils.Math.FDEG2RAD * innerRadius)
                        let startAngleInner = rotationAngle + (angle + sliceSpaceInnerAngle / 2.0) * phaseY
                        var sweepAngleInner = (sliceAngle - sliceSpaceInnerAngle) * phaseY
                        if (sweepAngleInner < 0.0)
                        {
                            sweepAngleInner = 0.0
                        }
                        let endAngleInner = startAngleInner + sweepAngleInner
                        
                        CGPathAddLineToPoint(
                            path,
                            nil,
                            center.x + innerRadius * cos(endAngleInner * ChartUtils.Math.FDEG2RAD),
                            center.y + innerRadius * sin(endAngleInner * ChartUtils.Math.FDEG2RAD))
                        CGPathAddRelativeArc(
                            path,
                            nil,
                            center.x,
                            center.y,
                            innerRadius,
                            endAngleInner * ChartUtils.Math.FDEG2RAD,
                            -sweepAngleInner * ChartUtils.Math.FDEG2RAD)
                    }
                    else
                    {
                        CGPathAddLineToPoint(
                            path,
                            nil,
                            center.x,
                            center.y)
                    }
                    
                    CGPathCloseSubpath(path)
                    
                    CGContextBeginPath(context)
                    CGContextAddPath(context, path)
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
        
        if chart.drawHoleEnabled
        {
            off = (r - (r * chart.holeRadiusPercent)) / 2.0
        }
        
        r -= off; // offset to keep things inside the chart
        
        var dataSets = data.dataSets
        
        let yValueSum = (data as! PieChartData).yValueSum
        
        let drawXVals = chart.isDrawSliceTextEnabled
        let usePercentValuesEnabled = chart.usePercentValuesEnabled
        
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
                let sliceSpaceMiddleAngle = sliceSpace / (ChartUtils.Math.FDEG2RAD * r)
                
                // offset needed to center the drawn text in the slice
                let offset = (sliceAngle - sliceSpaceMiddleAngle / 2.0) / 2.0

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
            let holeRadius = radius * chart.holeRadiusPercent
            let center = chart.centerCircleBox
            
            if let holeColor = chart.holeColor
            {
                if holeColor != NSUIColor.clearColor()
                {
                    // draw the hole-circle
                    CGContextSetFillColorWithColor(context, chart.holeColor!.CGColor)
                    CGContextFillEllipseInRect(context, CGRect(x: center.x - holeRadius, y: center.y - holeRadius, width: holeRadius * 2.0, height: holeRadius * 2.0))
                }
            }
            
            // only draw the circle if it can be seen (not covered by the hole)
            if let transparentCircleColor = chart.transparentCircleColor
            {
                if transparentCircleColor != NSUIColor.clearColor() &&
                    chart.transparentCircleRadiusPercent > chart.holeRadiusPercent
                {
                    let alpha = animator.phaseX * animator.phaseY
                    let secondHoleRadius = radius * chart.transparentCircleRadiusPercent
                    
                    // make transparent
                    CGContextSetAlpha(context, alpha);
                    CGContextSetFillColorWithColor(context, transparentCircleColor.CGColor)
                    
                    // draw the transparent-circle
                    CGContextBeginPath(context)
                    CGContextAddEllipseInRect(context, CGRect(
                        x: center.x - secondHoleRadius,
                        y: center.y - secondHoleRadius,
                        width: secondHoleRadius * 2.0,
                        height: secondHoleRadius * 2.0))
                    CGContextAddEllipseInRect(context, CGRect(
                        x: center.x - holeRadius,
                        y: center.y - holeRadius,
                        width: holeRadius * 2.0,
                        height: holeRadius * 2.0))
                    CGContextEOFillPath(context)
                }
            }
            
            CGContextRestoreGState(context)
        }
    }
    
    /// draws the description text in the center of the pie chart makes most sense when center-hole is enabled
    private func drawCenterText(context context: CGContext)
    {
        guard let
            chart = chart,
            centerAttributedText = chart.centerAttributedText
            else { return }
        
        if chart.drawCenterTextEnabled && centerAttributedText.length > 0
        {
            let center = chart.centerCircleBox
            let innerRadius = chart.drawHoleEnabled && !chart.drawSlicesUnderHoleEnabled ? chart.radius * chart.holeRadiusPercent : chart.radius
            let holeRect = CGRect(x: center.x - innerRadius, y: center.y - innerRadius, width: innerRadius * 2.0, height: innerRadius * 2.0)
            var boundingRect = holeRect
            
            if (chart.centerTextRadiusPercent > 0.0)
            {
                boundingRect = CGRectInset(boundingRect, (boundingRect.width - boundingRect.width * chart.centerTextRadiusPercent) / 2.0, (boundingRect.height - boundingRect.height * chart.centerTextRadiusPercent) / 2.0)
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
        let center = chart.centerCircleBox
        let radius = chart.radius
        let userInnerRadius = chart.drawHoleEnabled && !chart.drawSlicesUnderHoleEnabled ? radius * chart.holeRadiusPercent : 0.0
        
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
            
            let entryCount = set.entryCount
            var visibleAngleCount = 0
            for (var j = 0; j < entryCount; j++)
            {
                guard let e = set.entryForIndex(j) else { continue }
                if ((abs(e.value) > 0.000001))
                {
                    visibleAngleCount++;
                }
            }
            
            if (xIndex == 0)
            {
                angle = 0.0
            }
            else
            {
                angle = absoluteAngles[xIndex - 1] * phaseX
            }
            
            let sliceSpace = set.sliceSpace
            
            let sliceAngle = drawAngles[xIndex]
            let sliceSpaceOuterAngle = visibleAngleCount == 1 ?
                0.0 :
                sliceSpace / (ChartUtils.Math.FDEG2RAD * radius)
            var innerRadius = userInnerRadius
            
            let shift = set.selectionShift
            let highlightedRadius = radius + shift
            
            CGContextSetFillColorWithColor(context, set.colorAt(xIndex).CGColor)
            
            let startAngleOuter = rotationAngle + (angle + sliceSpaceOuterAngle / 2.0) * phaseY
            var sweepAngleOuter = (sliceAngle - sliceSpaceOuterAngle) * phaseY
            if (sweepAngleOuter < 0.0)
            {
                sweepAngleOuter = 0.0
            }
            
            let path = CGPathCreateMutable()
            
            CGPathMoveToPoint(
                path,
                nil,
                center.x + highlightedRadius * cos(startAngleOuter * ChartUtils.Math.FDEG2RAD),
                center.y + highlightedRadius * sin(startAngleOuter * ChartUtils.Math.FDEG2RAD))
            CGPathAddRelativeArc(
                path,
                nil,
                center.x,
                center.y,
                highlightedRadius,
                startAngleOuter * ChartUtils.Math.FDEG2RAD,
                sweepAngleOuter * ChartUtils.Math.FDEG2RAD)
            
            if sliceSpace > 0.0
            {
                innerRadius = max(innerRadius,
                    calculateMinimumRadiusForSpacedSlice(
                        center: center,
                        radius: radius,
                        angle: sliceAngle * phaseY,
                        arcStartPointX: center.x + radius * cos(startAngleOuter * ChartUtils.Math.FDEG2RAD),
                        arcStartPointY: center.y + radius * sin(startAngleOuter * ChartUtils.Math.FDEG2RAD),
                        startAngle: startAngleOuter,
                        sweepAngle: sweepAngleOuter))
            }
            
            if (innerRadius > 0.0)
            {
                let sliceSpaceInnerAngle = visibleAngleCount == 1 ?
                    0.0 :
                    sliceSpace / (ChartUtils.Math.FDEG2RAD * innerRadius)
                let startAngleInner = rotationAngle + (angle + sliceSpaceInnerAngle / 2.0) * phaseY
                var sweepAngleInner = (sliceAngle - sliceSpaceInnerAngle) * phaseY
                if (sweepAngleInner < 0.0)
                {
                    sweepAngleInner = 0.0
                }
                let endAngleInner = startAngleInner + sweepAngleInner
                
                CGPathAddLineToPoint(
                    path,
                    nil,
                    center.x + innerRadius * cos(endAngleInner * ChartUtils.Math.FDEG2RAD),
                    center.y + innerRadius * sin(endAngleInner * ChartUtils.Math.FDEG2RAD))
                CGPathAddRelativeArc(
                    path,
                    nil,
                    center.x,
                    center.y,
                    innerRadius,
                    endAngleInner * ChartUtils.Math.FDEG2RAD,
                    -sweepAngleInner * ChartUtils.Math.FDEG2RAD)
            }
            else
            {
                CGPathAddLineToPoint(
                    path,
                    nil,
                    center.x,
                    center.y)
            }
            
            CGPathCloseSubpath(path)
            
            CGContextBeginPath(context)
            CGContextAddPath(context, path)
            CGContextEOFillPath(context)
        }
        
        CGContextRestoreGState(context)
    }
}
