//
//  LineChartRenderer.swift
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

public class LineChartRenderer: LineRadarChartRenderer
{
    public weak var dataProvider: LineChartDataProvider?
    
    public init(dataProvider: LineChartDataProvider?, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    public override func drawData(context context: CGContext)
    {
        guard let lineData = dataProvider?.lineData else { return }
        
        for (var i = 0; i < lineData.dataSetCount; i++)
        {
            guard let set = lineData.getDataSetByIndex(i) else { continue }
            
            if set.isVisible
            {
                if !(set is ILineChartDataSet)
                {
                    fatalError("Datasets for LineChartRenderer must conform to ILineChartDataSet")
                }
                
                drawDataSet(context: context, dataSet: set as! ILineChartDataSet)
            }
        }
    }
    
    public func drawDataSet(context context: CGContext, dataSet: ILineChartDataSet)
    {
        let entryCount = dataSet.entryCount
        
        if (entryCount < 1)
        {
            return
        }
        
        CGContextSaveGState(context)
        
        CGContextSetLineWidth(context, dataSet.lineWidth)
        if (dataSet.lineDashLengths != nil)
        {
            CGContextSetLineDash(context, dataSet.lineDashPhase, dataSet.lineDashLengths!, dataSet.lineDashLengths!.count)
        }
        else
        {
            CGContextSetLineDash(context, 0.0, nil, 0)
        }
        
        // if drawing cubic lines is enabled
        if (dataSet.isDrawCubicEnabled)
        {
            drawCubic(context: context, dataSet: dataSet)
        }
        else
        { // draw normal (straight) lines
            drawLinear(context: context, dataSet: dataSet)
        }
        
        CGContextRestoreGState(context)
    }
    
    public func drawCubic(context context: CGContext, dataSet: ILineChartDataSet)
    {
        guard let
            trans = dataProvider?.getTransformer(dataSet.axisDependency),
            animator = animator
            else { return }
        
        let entryCount = dataSet.entryCount
        
        guard let
            entryFrom = dataSet.entryForXIndex(self.minX),
            entryTo = dataSet.entryForXIndex(self.maxX)
            else { return }
        
        let diff = (entryFrom == entryTo) ? 1 : 0
        let minx = max(dataSet.entryIndex(entry: entryFrom) - diff, 0)
        let maxx = min(max(minx + 2, dataSet.entryIndex(entry: entryTo) + 1), entryCount)
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        // get the color that is specified for this position from the DataSet
        let drawingColor = dataSet.colors.first!
        
        let intensity = dataSet.cubicIntensity
        
        // the path for the cubic-spline
        let cubicPath = CGPathCreateMutable()
        
        var valueToPixelMatrix = trans.valueToPixelMatrix
        
        let size = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))
        
        if (size - minx >= 2)
        {
            var prevDx: CGFloat = 0.0
            var prevDy: CGFloat = 0.0
            var curDx: CGFloat = 0.0
            var curDy: CGFloat = 0.0
            
            var prevPrev: ChartDataEntry! = dataSet.entryForIndex(minx)
            var prev: ChartDataEntry! = prevPrev
            var cur: ChartDataEntry! = prev
            var next: ChartDataEntry! = dataSet.entryForIndex(minx + 1)
            
            if cur == nil || next == nil { return }
            
            // let the spline start
            CGPathMoveToPoint(cubicPath, &valueToPixelMatrix, CGFloat(cur.xIndex), CGFloat(cur.value) * phaseY)
            
            prevDx = CGFloat(cur.xIndex - prev.xIndex) * intensity
            prevDy = CGFloat(cur.value - prev.value) * intensity
            
            curDx = CGFloat(next.xIndex - cur.xIndex) * intensity
            curDy = CGFloat(next.value - cur.value) * intensity
            
            // the first cubic
            CGPathAddCurveToPoint(cubicPath, &valueToPixelMatrix,
                CGFloat(prev.xIndex) + prevDx, (CGFloat(prev.value) + prevDy) * phaseY,
                CGFloat(cur.xIndex) - curDx, (CGFloat(cur.value) - curDy) * phaseY,
                CGFloat(cur.xIndex), CGFloat(cur.value) * phaseY)
            
            for (var j = minx + 1, count = min(size, entryCount - 1); j < count; j++)
            {
                prevPrev = prev
                prev = cur
                cur = next
                next = dataSet.entryForIndex(j + 1)
                
                if next == nil { break }
                
                prevDx = CGFloat(cur.xIndex - prevPrev.xIndex) * intensity
                prevDy = CGFloat(cur.value - prevPrev.value) * intensity
                curDx = CGFloat(next.xIndex - prev.xIndex) * intensity
                curDy = CGFloat(next.value - prev.value) * intensity
                
                CGPathAddCurveToPoint(cubicPath, &valueToPixelMatrix, CGFloat(prev.xIndex) + prevDx, (CGFloat(prev.value) + prevDy) * phaseY,
                    CGFloat(cur.xIndex) - curDx,
                    (CGFloat(cur.value) - curDy) * phaseY, CGFloat(cur.xIndex), CGFloat(cur.value) * phaseY)
            }
            
            if (size > entryCount - 1)
            {
                prevPrev = dataSet.entryForIndex(entryCount - (entryCount >= 3 ? 3 : 2))
                prev = dataSet.entryForIndex(entryCount - 2)
                cur = dataSet.entryForIndex(entryCount - 1)
                next = cur
                
                if prevPrev == nil || prev == nil || cur == nil { return }
                
                prevDx = CGFloat(cur.xIndex - prevPrev.xIndex) * intensity
                prevDy = CGFloat(cur.value - prevPrev.value) * intensity
                curDx = CGFloat(next.xIndex - prev.xIndex) * intensity
                curDy = CGFloat(next.value - prev.value) * intensity
                
                // the last cubic
                CGPathAddCurveToPoint(cubicPath, &valueToPixelMatrix, CGFloat(prev.xIndex) + prevDx, (CGFloat(prev.value) + prevDy) * phaseY,
                    CGFloat(cur.xIndex) - curDx,
                    (CGFloat(cur.value) - curDy) * phaseY, CGFloat(cur.xIndex), CGFloat(cur.value) * phaseY)
            }
        }
        
        CGContextSaveGState(context)
        
        if (dataSet.isDrawFilledEnabled)
        {
            drawCubicFill(context: context, dataSet: dataSet, spline: cubicPath, matrix: valueToPixelMatrix, from: minx, to: size)
        }
        
        CGContextBeginPath(context)
        CGContextAddPath(context, cubicPath)
        CGContextSetStrokeColorWithColor(context, drawingColor.CGColor)
        CGContextStrokePath(context)
        
        CGContextRestoreGState(context)
    }
    
    public func drawCubicFill(context context: CGContext, dataSet: ILineChartDataSet, spline: CGMutablePath, matrix: CGAffineTransform, from: Int, to: Int)
    {
        guard let dataProvider = dataProvider else { return }
        
        if to - from <= 1
        {
            return
        }
        
        let fillMin = dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0
        
        var pt1 = CGPoint(x: CGFloat(to - 1), y: fillMin)
        var pt2 = CGPoint(x: CGFloat(from), y: fillMin)
        pt1 = CGPointApplyAffineTransform(pt1, matrix)
        pt2 = CGPointApplyAffineTransform(pt2, matrix)
        
        CGPathAddLineToPoint(spline, nil, pt1.x, pt1.y)
        CGPathAddLineToPoint(spline, nil, pt2.x, pt2.y)
        CGPathCloseSubpath(spline)
        
        if dataSet.fill != nil
        {
            drawFilledPath(context: context, path: spline, fill: dataSet.fill!, fillAlpha: dataSet.fillAlpha)
        }
        else
        {
            drawFilledPath(context: context, path: spline, fillColor: dataSet.fillColor, fillAlpha: dataSet.fillAlpha)
        }
    }
    
    private var _lineSegments = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public func drawLinear(context context: CGContext, dataSet: ILineChartDataSet)
    {
        guard let
            trans = dataProvider?.getTransformer(dataSet.axisDependency),
            animator = animator
            else { return }
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        let entryCount = dataSet.entryCount
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        CGContextSaveGState(context)
        
        guard let
            entryFrom = dataSet.entryForXIndex(self.minX),
            entryTo = dataSet.entryForXIndex(self.maxX)
            else { return }
        
        let diff = (entryFrom == entryTo) ? 1 : 0
        let minx = max(dataSet.entryIndex(entry: entryFrom) - diff, 0)
        let maxx = min(max(minx + 2, dataSet.entryIndex(entry: entryTo) + 1), entryCount)
        
        // more than 1 color
        if (dataSet.colors.count > 1)
        {
            if (_lineSegments.count != 2)
            {
                _lineSegments = [CGPoint](count: 2, repeatedValue: CGPoint())
            }
            
            for (var j = minx, count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))); j < count; j++)
            {
                if (count > 1 && j == count - 1)
                { // Last point, we have already drawn a line to this point
                    break
                }
                
                var e: ChartDataEntry! = dataSet.entryForIndex(j)
                
                if e == nil { continue }
                
                _lineSegments[0].x = CGFloat(e.xIndex)
                _lineSegments[0].y = CGFloat(e.value) * phaseY
                _lineSegments[0] = CGPointApplyAffineTransform(_lineSegments[0], valueToPixelMatrix)
                if (j + 1 < count)
                {
                    e = dataSet.entryForIndex(j + 1)
                    
                    if e == nil { break }
                    
                    _lineSegments[1].x = CGFloat(e.xIndex)
                    _lineSegments[1].y = CGFloat(e.value) * phaseY
                    _lineSegments[1] = CGPointApplyAffineTransform(_lineSegments[1], valueToPixelMatrix)
                }
                else
                {
                    _lineSegments[1] = _lineSegments[0]
                }
                
                if (!viewPortHandler.isInBoundsRight(_lineSegments[0].x))
                {
                    break
                }
                
                // make sure the lines don't do shitty things outside bounds
                if (!viewPortHandler.isInBoundsLeft(_lineSegments[1].x)
                    || (!viewPortHandler.isInBoundsTop(_lineSegments[0].y) && !viewPortHandler.isInBoundsBottom(_lineSegments[1].y))
                    || (!viewPortHandler.isInBoundsTop(_lineSegments[0].y) && !viewPortHandler.isInBoundsBottom(_lineSegments[1].y)))
                {
                    continue
                }
                
                // get the color that is set for this line-segment
                CGContextSetStrokeColorWithColor(context, dataSet.colorAt(j).CGColor)
                CGContextStrokeLineSegments(context, _lineSegments, 2)
            }
        }
        else
        { // only one color per dataset
            
            var e1: ChartDataEntry!
            var e2: ChartDataEntry!
            
            if (_lineSegments.count != max((entryCount - 1) * 2, 2))
            {
                _lineSegments = [CGPoint](count: max((entryCount - 1) * 2, 2), repeatedValue: CGPoint())
            }
            
            e1 = dataSet.entryForIndex(minx)
            
            if e1 != nil
            {
                let count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))
                
                for (var x = count > 1 ? minx + 1 : minx, j = 0; x < count; x++)
                {
                    e1 = dataSet.entryForIndex(x == 0 ? 0 : (x - 1))
                    e2 = dataSet.entryForIndex(x)
                    
                    if e1 == nil || e2 == nil { continue }
                    
                    _lineSegments[j++] = CGPointApplyAffineTransform(CGPoint(x: CGFloat(e1.xIndex), y: CGFloat(e1.value) * phaseY), valueToPixelMatrix)
                    _lineSegments[j++] = CGPointApplyAffineTransform(CGPoint(x: CGFloat(e2.xIndex), y: CGFloat(e2.value) * phaseY), valueToPixelMatrix)
                }
                
                let size = max((count - minx - 1) * 2, 2)
                CGContextSetStrokeColorWithColor(context, dataSet.colorAt(0).CGColor)
                CGContextStrokeLineSegments(context, _lineSegments, size)
            }
        }
        
        CGContextRestoreGState(context)
        
        // if drawing filled is enabled
        if (dataSet.isDrawFilledEnabled && entryCount > 0)
        {
            drawLinearFill(context: context, dataSet: dataSet, minx: minx, maxx: maxx, trans: trans)
        }
    }
    
    public func drawLinearFill(context context: CGContext, dataSet: ILineChartDataSet, minx: Int, maxx: Int, trans: ChartTransformer)
    {
        guard let dataProvider = dataProvider else { return }
        
        let filled = generateFilledPath(
            dataSet: dataSet,
            fillMin: dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0,
            from: minx,
            to: maxx,
            matrix: trans.valueToPixelMatrix)
        
        if dataSet.fill != nil
        {
            drawFilledPath(context: context, path: filled, fill: dataSet.fill!, fillAlpha: dataSet.fillAlpha)
        }
        else
        {
            drawFilledPath(context: context, path: filled, fillColor: dataSet.fillColor, fillAlpha: dataSet.fillAlpha)
        }
    }
    
    /// Generates the path that is used for filled drawing.
    private func generateFilledPath(dataSet dataSet: ILineChartDataSet, fillMin: CGFloat, from: Int, to: Int, var matrix: CGAffineTransform) -> CGPath
    {
        let phaseX = animator?.phaseX ?? 1.0
        let phaseY = animator?.phaseY ?? 1.0
        
        var e: ChartDataEntry!
        
        let filled = CGPathCreateMutable()
        
        e = dataSet.entryForIndex(from)
        if e != nil
        {
            CGPathMoveToPoint(filled, &matrix, CGFloat(e.xIndex), fillMin)
            CGPathAddLineToPoint(filled, &matrix, CGFloat(e.xIndex), CGFloat(e.value) * phaseY)
        }
        
        // create a new path
        for (var x = from + 1, count = Int(ceil(CGFloat(to - from) * phaseX + CGFloat(from))); x < count; x++)
        {
            guard let e = dataSet.entryForIndex(x) else { continue }
            CGPathAddLineToPoint(filled, &matrix, CGFloat(e.xIndex), CGFloat(e.value) * phaseY)
        }
        
        // close up
        e = dataSet.entryForIndex(max(min(Int(ceil(CGFloat(to - from) * phaseX + CGFloat(from))) - 1, dataSet.entryCount - 1), 0))
        if e != nil
        {
            CGPathAddLineToPoint(filled, &matrix, CGFloat(e.xIndex), fillMin)
        }
        CGPathCloseSubpath(filled)
        
        return filled
    }
    
    public override func drawValues(context context: CGContext)
    {
        guard let
            dataProvider = dataProvider,
            lineData = dataProvider.lineData,
            animator = animator
            else { return }
        
        if (CGFloat(lineData.yValCount) < CGFloat(dataProvider.maxVisibleValueCount) * viewPortHandler.scaleX)
        {
            var dataSets = lineData.dataSets
            
            let phaseX = animator.phaseX
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for (var i = 0; i < dataSets.count; i++)
            {
                guard let dataSet = dataSets[i] as? ILineChartDataSet else { continue }
                
                if !dataSet.isDrawValuesEnabled || dataSet.entryCount == 0
                {
                    continue
                }
                
                let valueFont = dataSet.valueFont
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                let trans = dataProvider.getTransformer(dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                // make sure the values do not interfear with the circles
                var valOffset = Int(dataSet.circleRadius * 1.75)
                
                if (!dataSet.isDrawCirclesEnabled)
                {
                    valOffset = valOffset / 2
                }
                
                let entryCount = dataSet.entryCount
                
                guard let
                    entryFrom = dataSet.entryForXIndex(self.minX),
                    entryTo = dataSet.entryForXIndex(self.maxX)
                    else { continue }
                
                let diff = (entryFrom == entryTo) ? 1 : 0
                let minx = max(dataSet.entryIndex(entry: entryFrom) - diff, 0)
                let maxx = min(max(minx + 2, dataSet.entryIndex(entry: entryTo) + 1), entryCount)
                
                for (var j = minx, count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))); j < count; j++)
                {
                    guard let e = dataSet.entryForIndex(j) else { break }
                    
                    pt.x = CGFloat(e.xIndex)
                    pt.y = CGFloat(e.value) * phaseY
                    pt = CGPointApplyAffineTransform(pt, valueToPixelMatrix)
                    
                    if (!viewPortHandler.isInBoundsRight(pt.x))
                    {
                        break
                    }
                    
                    if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y))
                    {
                        continue
                    }
                    
                    ChartUtils.drawText(context: context,
                        text: formatter.stringFromNumber(e.value)!,
                        point: CGPoint(
                            x: pt.x,
                            y: pt.y - CGFloat(valOffset) - valueFont.lineHeight),
                        align: .Center,
                        attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)])
                }
            }
        }
    }
    
    public override func drawExtras(context context: CGContext)
    {
        drawCircles(context: context)
    }
    
    private func drawCircles(context context: CGContext)
    {
        guard let
            dataProvider = dataProvider,
            lineData = dataProvider.lineData,
            animator = animator
            else { return }
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        let dataSets = lineData.dataSets
        
        var pt = CGPoint()
        var rect = CGRect()
        
        CGContextSaveGState(context)
        
        for (var i = 0, count = dataSets.count; i < count; i++)
        {
            guard let dataSet = lineData.getDataSetByIndex(i) as? ILineChartDataSet else { continue }
            
            if !dataSet.isVisible || !dataSet.isDrawCirclesEnabled || dataSet.entryCount == 0
            {
                continue
            }
            
            let trans = dataProvider.getTransformer(dataSet.axisDependency)
            let valueToPixelMatrix = trans.valueToPixelMatrix
            
            let entryCount = dataSet.entryCount
            
            let circleRadius = dataSet.circleRadius
            let circleDiameter = circleRadius * 2.0
            let circleHoleDiameter = circleRadius
            let circleHoleRadius = circleHoleDiameter / 2.0
            let isDrawCircleHoleEnabled = dataSet.isDrawCircleHoleEnabled
            
            guard let
                entryFrom = dataSet.entryForXIndex(self.minX),
                entryTo = dataSet.entryForXIndex(self.maxX)
                else { continue }
            
            let diff = (entryFrom == entryTo) ? 1 : 0
            let minx = max(dataSet.entryIndex(entry: entryFrom) - diff, 0)
            let maxx = min(max(minx + 2, dataSet.entryIndex(entry: entryTo) + 1), entryCount)
            
            for (var j = minx, count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))); j < count; j++)
            {
                guard let e = dataSet.entryForIndex(j) else { break }

                pt.x = CGFloat(e.xIndex)
                pt.y = CGFloat(e.value) * phaseY
                pt = CGPointApplyAffineTransform(pt, valueToPixelMatrix)
                
                if (!viewPortHandler.isInBoundsRight(pt.x))
                {
                    break
                }
                
                // make sure the circles don't do shitty things outside bounds
                if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y))
                {
                    continue
                }
                
                CGContextSetFillColorWithColor(context, dataSet.getCircleColor(j)!.CGColor)
                
                rect.origin.x = pt.x - circleRadius
                rect.origin.y = pt.y - circleRadius
                rect.size.width = circleDiameter
                rect.size.height = circleDiameter
                CGContextFillEllipseInRect(context, rect)
                
                if (isDrawCircleHoleEnabled)
                {
                    CGContextSetFillColorWithColor(context, dataSet.circleHoleColor.CGColor)
                    
                    rect.origin.x = pt.x - circleHoleRadius
                    rect.origin.y = pt.y - circleHoleRadius
                    rect.size.width = circleHoleDiameter
                    rect.size.height = circleHoleDiameter
                    CGContextFillEllipseInRect(context, rect)
                }
            }
        }
        
        CGContextRestoreGState(context)
    }
    
    private var _highlightPointBuffer = CGPoint()
    
    public override func drawHighlighted(context context: CGContext, indices: [ChartHighlight])
    {
        guard let
            lineData = dataProvider?.lineData,
            chartXMax = dataProvider?.chartXMax,
            animator = animator
            else { return }
        
        CGContextSaveGState(context)
        
        for (var i = 0; i < indices.count; i++)
        {
            guard let set = lineData.getDataSetByIndex(indices[i].dataSetIndex) as? ILineChartDataSet else { continue }
            
            if !set.isHighlightEnabled
            {
                continue
            }
            
            CGContextSetStrokeColorWithColor(context, set.highlightColor.CGColor)
            CGContextSetLineWidth(context, set.highlightLineWidth)
            if (set.highlightLineDashLengths != nil)
            {
                CGContextSetLineDash(context, set.highlightLineDashPhase, set.highlightLineDashLengths!, set.highlightLineDashLengths!.count)
            }
            else
            {
                CGContextSetLineDash(context, 0.0, nil, 0)
            }
            
            let xIndex = indices[i].xIndex; // get the x-position
            
            if (CGFloat(xIndex) > CGFloat(chartXMax) * animator.phaseX)
            {
                continue
            }
            
            let yValue = set.yValForXIndex(xIndex)
            if (yValue.isNaN)
            {
                continue
            }
            
            let y = CGFloat(yValue) * animator.phaseY; // get the y-position
            
            _highlightPointBuffer.x = CGFloat(xIndex)
            _highlightPointBuffer.y = y
            
            let trans = dataProvider?.getTransformer(set.axisDependency)
            
            trans?.pointValueToPixel(&_highlightPointBuffer)
            
            // draw the lines
            drawHighlightLines(context: context, point: _highlightPointBuffer, set: set)
        }
        
        CGContextRestoreGState(context)
    }
}