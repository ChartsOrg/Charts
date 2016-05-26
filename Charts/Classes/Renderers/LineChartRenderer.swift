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
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif


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
        
        for i in 0 ..< lineData.dataSetCount
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
        switch dataSet.mode
        {
        case .Linear: fallthrough
        case .Stepped:
            drawLinear(context: context, dataSet: dataSet)
            
        case .CubicBezier:
            drawCubicBezier(context: context, dataSet: dataSet)
            
        case .HorizontalBezier:
            drawHorizontalBezier(context: context, dataSet: dataSet)
        }
        
        CGContextRestoreGState(context)
    }
    
    public func drawCubicBezier(context context: CGContext, dataSet: ILineChartDataSet)
    {
        guard let
            trans = dataProvider?.getTransformer(dataSet.axisDependency),
            animator = animator
            else { return }
        
        let entryCount = dataSet.entryCount
        
        guard let
            entryFrom = dataSet.entryForXIndex(self.minX < 0 ? 0 : self.minX, rounding: .Down),
            entryTo = dataSet.entryForXIndex(self.maxX, rounding: .Up)
            else { return }
        
        let diff = (entryFrom == entryTo) ? 1 : 0
        let minx = max(dataSet.entryIndex(entry: entryFrom) - diff - 1, 0)
        let maxx = min(max(minx + 2, dataSet.entryIndex(entry: entryTo) + 1), entryCount)
        
        let phaseX = max(0.0, min(1.0, animator.phaseX))
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
            
            for j in (minx + 1).stride(to: min(size, entryCount), by: 1)
            {
                prevPrev = prev
                prev = cur
                cur = next
                next = entryCount > j + 1 ? dataSet.entryForIndex(j + 1) : cur
                
                if next == nil { break }
                
                prevDx = CGFloat(cur.xIndex - prevPrev.xIndex) * intensity
                prevDy = CGFloat(cur.value - prevPrev.value) * intensity
                curDx = CGFloat(next.xIndex - prev.xIndex) * intensity
                curDy = CGFloat(next.value - prev.value) * intensity
                
                CGPathAddCurveToPoint(cubicPath, &valueToPixelMatrix,
                                      CGFloat(prev.xIndex) + prevDx,
                                      (CGFloat(prev.value) + prevDy) * phaseY,
                                      CGFloat(cur.xIndex) - curDx,
                                      (CGFloat(cur.value) - curDy) * phaseY,
                                      CGFloat(cur.xIndex),
                                      CGFloat(cur.value) * phaseY)
            }
        }
        
        CGContextSaveGState(context)
        
        if (dataSet.isDrawFilledEnabled)
        {
            // Copy this path because we make changes to it
            let fillPath = CGPathCreateMutableCopy(cubicPath)
            
            drawCubicFill(context: context, dataSet: dataSet, spline: fillPath!, matrix: valueToPixelMatrix, from: minx, to: size)
        }
        
        CGContextBeginPath(context)
        CGContextAddPath(context, cubicPath)
        CGContextSetStrokeColorWithColor(context, drawingColor.CGColor)
        CGContextStrokePath(context)
        
        CGContextRestoreGState(context)
    }
    
    public func drawHorizontalBezier(context context: CGContext, dataSet: ILineChartDataSet)
    {
        guard let
            trans = dataProvider?.getTransformer(dataSet.axisDependency),
            animator = animator
            else { return }
        
        let entryCount = dataSet.entryCount
        
        guard let
            entryFrom = dataSet.entryForXIndex(self.minX < 0 ? 0 : self.minX, rounding: .Down),
            entryTo = dataSet.entryForXIndex(self.maxX, rounding: .Up)
            else { return }
        
        let diff = (entryFrom == entryTo) ? 1 : 0
        let minx = max(dataSet.entryIndex(entry: entryFrom) - diff, 0)
        let maxx = min(max(minx + 2, dataSet.entryIndex(entry: entryTo) + 1), entryCount)
        
        let phaseX = max(0.0, min(1.0, animator.phaseX))
        let phaseY = animator.phaseY
        
        // get the color that is specified for this position from the DataSet
        let drawingColor = dataSet.colors.first!
        
        // the path for the cubic-spline
        let cubicPath = CGPathCreateMutable()
        
        var valueToPixelMatrix = trans.valueToPixelMatrix
        
        let size = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))
        
        if (size - minx >= 2)
        {
            var prev: ChartDataEntry! = dataSet.entryForIndex(minx)
            var cur: ChartDataEntry! = prev
            
            if cur == nil { return }
            
            // let the spline start
            CGPathMoveToPoint(cubicPath, &valueToPixelMatrix, CGFloat(cur.xIndex), CGFloat(cur.value) * phaseY)
            
            for j in (minx + 1).stride(to: min(size, entryCount), by: 1)
            {
                prev = cur
                cur = dataSet.entryForIndex(j)
                
                let cpx = CGFloat(prev.xIndex) + CGFloat(cur.xIndex - prev.xIndex) / 2.0
                
                CGPathAddCurveToPoint(cubicPath,
                                      &valueToPixelMatrix,
                                      cpx, CGFloat(prev.value) * phaseY,
                                      cpx, CGFloat(cur.value) * phaseY,
                                      CGFloat(cur.xIndex), CGFloat(cur.value) * phaseY)
            }
        }
        
        CGContextSaveGState(context)
        
        if (dataSet.isDrawFilledEnabled)
        {
            // Copy this path because we make changes to it
            let fillPath = CGPathCreateMutableCopy(cubicPath)
            
            drawCubicFill(context: context, dataSet: dataSet, spline: fillPath!, matrix: valueToPixelMatrix, from: minx, to: size)
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
        
        // Take the from/to xIndex from the entries themselves,
        // so missing entries won't screw up the filling.
        // What we need to draw is line from points of the xIndexes - not arbitrary entry indexes!
        let xTo = dataSet.entryForIndex(to - 1)?.xIndex ?? 0
        let xFrom = dataSet.entryForIndex(from)?.xIndex ?? 0

        var pt1 = CGPoint(x: CGFloat(xTo), y: fillMin)
        var pt2 = CGPoint(x: CGFloat(xFrom), y: fillMin)
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
        let isDrawSteppedEnabled = dataSet.mode == .Stepped
        let pointsPerEntryPair = isDrawSteppedEnabled ? 4 : 2
        
        let phaseX = max(0.0, min(1.0, animator.phaseX))
        let phaseY = animator.phaseY

        guard let
            entryFrom = dataSet.entryForXIndex(self.minX < 0 ? 0 : self.minX, rounding: .Down),
            entryTo = dataSet.entryForXIndex(self.maxX, rounding: .Up)
            else { return }
        
        var diff = (entryFrom == entryTo) ? 1 : 0
        if dataSet.mode == .CubicBezier
        {
            diff += 1
        }
        
        let minx = max(dataSet.entryIndex(entry: entryFrom) - diff, 0)
        let maxx = min(max(minx + 2, dataSet.entryIndex(entry: entryTo) + 1), entryCount)
        
        CGContextSaveGState(context)
        
        CGContextSetLineCap(context, dataSet.lineCapType)

        // more than 1 color
        if (dataSet.colors.count > 1)
        {
            if (_lineSegments.count != pointsPerEntryPair)
            {
                _lineSegments = [CGPoint](count: pointsPerEntryPair, repeatedValue: CGPoint())
            }
            
            let count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))
            for j in minx.stride(to: count, by: 1)
            {
                if (count > 1 && j == count - 1)
                { // Last point, we have already drawn a line to this point
                    break
                }
                
                var e: ChartDataEntry! = dataSet.entryForIndex(j)
                
                if e == nil { continue }
                
                _lineSegments[0].x = CGFloat(e.xIndex)
                _lineSegments[0].y = CGFloat(e.value) * phaseY
                
                if (j + 1 < count)
                {
                    e = dataSet.entryForIndex(j + 1)
                    
                    if e == nil { break }
                    
                    if isDrawSteppedEnabled
                    {
                        _lineSegments[1] = CGPoint(x: CGFloat(e.xIndex), y: _lineSegments[0].y)
                        _lineSegments[2] = _lineSegments[1]
                        _lineSegments[3] = CGPoint(x: CGFloat(e.xIndex), y: CGFloat(e.value) * phaseY)
                    }
                    else
                    {
                        _lineSegments[1] = CGPoint(x: CGFloat(e.xIndex), y: CGFloat(e.value) * phaseY)
                    }
                }
                else
                {
                    _lineSegments[1] = _lineSegments[0]
                }

                for i in 0..<_lineSegments.count
                {
                    _lineSegments[i] = CGPointApplyAffineTransform(_lineSegments[i], valueToPixelMatrix)
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
                CGContextStrokeLineSegments(context, _lineSegments, pointsPerEntryPair)
            }
        }
        else
        { // only one color per dataset
            
            var e1: ChartDataEntry!
            var e2: ChartDataEntry!
            
            if (_lineSegments.count != max((entryCount - 1) * pointsPerEntryPair, pointsPerEntryPair))
            {
                _lineSegments = [CGPoint](count: max((entryCount - 1) * pointsPerEntryPair, pointsPerEntryPair), repeatedValue: CGPoint())
            }
            
            e1 = dataSet.entryForIndex(minx)
            
            if e1 != nil
            {
                let count = Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx)))
                
                var j = 0
                for x in (count > 1 ? minx + 1 : minx).stride(to: count, by: 1)
                {
                    e1 = dataSet.entryForIndex(x == 0 ? 0 : (x - 1))
                    e2 = dataSet.entryForIndex(x)
                    
                    if e1 == nil || e2 == nil { continue }
                    
                    _lineSegments[j] = CGPointApplyAffineTransform(
                        CGPoint(
                            x: CGFloat(e1.xIndex),
                            y: CGFloat(e1.value) * phaseY
                        ), valueToPixelMatrix)
                    j += 1
                    
                    if isDrawSteppedEnabled
                    {
                        _lineSegments[j] = CGPointApplyAffineTransform(
                            CGPoint(
                                x: CGFloat(e2.xIndex),
                                y: CGFloat(e1.value) * phaseY
                            ), valueToPixelMatrix)
                        j += 1
                        
                        _lineSegments[j] = CGPointApplyAffineTransform(
                            CGPoint(
                                x: CGFloat(e2.xIndex),
                                y: CGFloat(e1.value) * phaseY
                            ), valueToPixelMatrix)
                        j += 1
                    }
                    
                    _lineSegments[j] = CGPointApplyAffineTransform(
                        CGPoint(
                            x: CGFloat(e2.xIndex),
                            y: CGFloat(e2.value) * phaseY
                        ), valueToPixelMatrix)
                    j += 1
                }
                
                if j > 0
                {
                    let size = max((count - minx - 1) * pointsPerEntryPair, pointsPerEntryPair)
                    CGContextSetStrokeColorWithColor(context, dataSet.colorAt(0).CGColor)
                    CGContextStrokeLineSegments(context, _lineSegments, size)
                }
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
    private func generateFilledPath(dataSet dataSet: ILineChartDataSet, fillMin: CGFloat, from: Int, to: Int, matrix: CGAffineTransform) -> CGPath
    {
        let phaseX = max(0.0, min(1.0, animator?.phaseX ?? 1.0))
        let phaseY = animator?.phaseY ?? 1.0
        let isDrawSteppedEnabled = dataSet.mode == .Stepped
        var matrix = matrix
        
        var e: ChartDataEntry!
        
        let filled = CGPathCreateMutable()
        
        e = dataSet.entryForIndex(from)
        if e != nil
        {
            CGPathMoveToPoint(filled, &matrix, CGFloat(e.xIndex), fillMin)
            CGPathAddLineToPoint(filled, &matrix, CGFloat(e.xIndex), CGFloat(e.value) * phaseY)
        }
        
        // create a new path
        for x in (from + 1).stride(to: Int(ceil(CGFloat(to - from) * phaseX + CGFloat(from))), by: 1)
        {
            guard let e = dataSet.entryForIndex(x) else { continue }
            
            if isDrawSteppedEnabled
            {
                guard let ePrev = dataSet.entryForIndex(x-1) else { continue }
                CGPathAddLineToPoint(filled, &matrix, CGFloat(e.xIndex), CGFloat(ePrev.value) * phaseY)
            }
            
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
            
            let phaseX = max(0.0, min(1.0, animator.phaseX))
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for i in 0 ..< dataSets.count
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
                    entryFrom = dataSet.entryForXIndex(self.minX < 0 ? 0 : self.minX, rounding: .Down),
                    entryTo = dataSet.entryForXIndex(self.maxX, rounding: .Up)
                    else { continue }
                
                var diff = (entryFrom == entryTo) ? 1 : 0
                if dataSet.mode == .CubicBezier
                {
                    diff += 1
                }
                
                let minx = max(dataSet.entryIndex(entry: entryFrom) - diff, 0)
                let maxx = min(max(minx + 2, dataSet.entryIndex(entry: entryTo) + 1), entryCount)
                
                for j in minx.stride(to: Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))), by: 1)
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
        
        let phaseX = max(0.0, min(1.0, animator.phaseX))
        let phaseY = animator.phaseY
        
        let dataSets = lineData.dataSets
        
        var pt = CGPoint()
        var rect = CGRect()
        
        CGContextSaveGState(context)
        
        for i in 0 ..< dataSets.count
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
            let circleHoleRadius = dataSet.circleHoleRadius
            let circleHoleDiameter = circleHoleRadius * 2.0
            
            let drawCircleHole = dataSet.isDrawCircleHoleEnabled &&
                circleHoleRadius < circleRadius &&
                circleHoleRadius > 0.0
            let drawTransparentCircleHole = drawCircleHole &&
                (dataSet.circleHoleColor == nil ||
                    dataSet.circleHoleColor == NSUIColor.clearColor())
            
            guard let
                entryFrom = dataSet.entryForXIndex(self.minX < 0 ? 0 : self.minX, rounding: .Down),
                entryTo = dataSet.entryForXIndex(self.maxX, rounding: .Up)
                else { continue }
            
            var diff = (entryFrom == entryTo) ? 1 : 0
            if dataSet.mode == .CubicBezier
            {
                diff += 1
            }
            
            let minx = max(dataSet.entryIndex(entry: entryFrom) - diff, 0)
            let maxx = min(max(minx + 2, dataSet.entryIndex(entry: entryTo) + 1), entryCount)
            
            for j in minx.stride(to: Int(ceil(CGFloat(maxx - minx) * phaseX + CGFloat(minx))), by: 1)
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
                
                if drawTransparentCircleHole
                {
                    // Begin path for circle with hole
                    CGContextBeginPath(context)
                    CGContextAddEllipseInRect(context, rect)
                    
                    // Cut hole in path
                    CGContextAddArc(context, pt.x, pt.y, circleHoleRadius, 0.0, CGFloat(M_PI_2), 1)
                    
                    // Fill in-between
                    CGContextFillPath(context)
                }
                else
                {
                    CGContextFillEllipseInRect(context, rect)
                    
                    if drawCircleHole
                    {
                        CGContextSetFillColorWithColor(context, dataSet.circleHoleColor!.CGColor)
                     
                        // The hole rect
                        rect.origin.x = pt.x - circleHoleRadius
                        rect.origin.y = pt.y - circleHoleRadius
                        rect.size.width = circleHoleDiameter
                        rect.size.height = circleHoleDiameter
                        
                        CGContextFillEllipseInRect(context, rect)
                    }
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
        
        for high in indices
        {
            let minDataSetIndex = high.dataSetIndex == -1 ? 0 : high.dataSetIndex
            let maxDataSetIndex = high.dataSetIndex == -1 ? lineData.dataSetCount : (high.dataSetIndex + 1)
            if maxDataSetIndex - minDataSetIndex < 1 { continue }
            
            for dataSetIndex in minDataSetIndex..<maxDataSetIndex
            {
                guard let set = lineData.getDataSetByIndex(dataSetIndex) as? ILineChartDataSet else { continue }
                
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
                
                let xIndex = high.xIndex; // get the x-position
                
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
        }
        
        CGContextRestoreGState(context)
    }
}