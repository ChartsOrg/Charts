//
//  LineChartRenderer.swift
//  Charts
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


public class LineChartRenderer: LineRadarRenderer
{
    public weak var dataProvider: LineChartDataProvider?
    
    public init(dataProvider: LineChartDataProvider?, animator: Animator?, viewPortHandler: ViewPortHandler?)
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
        if dataSet.entryCount < 1
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
            dataProvider = dataProvider,
            animator = animator
            else { return }
        
        let trans = dataProvider.getTransformer(dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        // get the color that is specified for this position from the DataSet
        let drawingColor = dataSet.colors.first!
        
        let intensity = dataSet.cubicIntensity
        
        // the path for the cubic-spline
        let cubicPath = CGPathCreateMutable()
        
        var valueToPixelMatrix = trans.valueToPixelMatrix
        
        if _xBounds.range >= 1
        {
            var prevDx: CGFloat = 0.0
            var prevDy: CGFloat = 0.0
            var curDx: CGFloat = 0.0
            var curDy: CGFloat = 0.0
            
            var prevPrev: ChartDataEntry! = dataSet.entryForIndex(_xBounds.min)
            var prev: ChartDataEntry! = prevPrev
            var cur: ChartDataEntry! = prev
            var next: ChartDataEntry! = dataSet.entryForIndex(_xBounds.min + 1)
            
            if cur == nil || next == nil { return }
            
            // let the spline start
            CGPathMoveToPoint(cubicPath, &valueToPixelMatrix, CGFloat(cur.x), CGFloat(cur.y * phaseY))
            
            for j in (_xBounds.min + 1).stride(through: _xBounds.range + _xBounds.min, by: 1)
            {
                prevPrev = prev
                prev = cur
                cur = next
                next = _xBounds.max > j + 1 ? dataSet.entryForIndex(j + 1) : cur
                
                if next == nil { break }
                
                prevDx = CGFloat(cur.x - prevPrev.x) * intensity
                prevDy = CGFloat(cur.y - prevPrev.y) * intensity
                curDx = CGFloat(next.x - prev.x) * intensity
                curDy = CGFloat(next.y - prev.y) * intensity
                
                CGPathAddCurveToPoint(cubicPath, &valueToPixelMatrix,
                                      CGFloat(prev.x) + prevDx,
                                      (CGFloat(prev.y) + prevDy) * CGFloat(phaseY),
                                      CGFloat(cur.x) - curDx,
                                      (CGFloat(cur.y) - curDy) * CGFloat(phaseY),
                                      CGFloat(cur.x),
                                      CGFloat(cur.y) * CGFloat(phaseY))
            }
        }
        
        CGContextSaveGState(context)
        
        if (dataSet.isDrawFilledEnabled)
        {
            // Copy this path because we make changes to it
            let fillPath = CGPathCreateMutableCopy(cubicPath)
            
            drawCubicFill(context: context, dataSet: dataSet, spline: fillPath!, matrix: valueToPixelMatrix, bounds: _xBounds)
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
            dataProvider = dataProvider,
            animator = animator
            else { return }
        
        let trans = dataProvider.getTransformer(dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        // get the color that is specified for this position from the DataSet
        let drawingColor = dataSet.colors.first!
        
        // the path for the cubic-spline
        let cubicPath = CGPathCreateMutable()
        
        var valueToPixelMatrix = trans.valueToPixelMatrix
        
        if _xBounds.range >= 1
        {
            var prev: ChartDataEntry! = dataSet.entryForIndex(_xBounds.min)
            var cur: ChartDataEntry! = prev
            
            if cur == nil { return }
            
            // let the spline start
            CGPathMoveToPoint(cubicPath, &valueToPixelMatrix, CGFloat(cur.x), CGFloat(cur.y * phaseY))
            
            for j in (_xBounds.min + 1).stride(through: _xBounds.range + _xBounds.min, by: 1)
            {
                prev = cur
                cur = dataSet.entryForIndex(j)
                
                let cpx = CGFloat(prev.x + (cur.x - prev.x) / 2.0)
                
                CGPathAddCurveToPoint(cubicPath,
                                      &valueToPixelMatrix,
                                      cpx, CGFloat(prev.y * phaseY),
                                      cpx, CGFloat(cur.y * phaseY),
                                      CGFloat(cur.x), CGFloat(cur.y * phaseY))
            }
        }
        
        CGContextSaveGState(context)
        
        if dataSet.isDrawFilledEnabled
        {
            // Copy this path because we make changes to it
            let fillPath = CGPathCreateMutableCopy(cubicPath)
            
            drawCubicFill(context: context, dataSet: dataSet, spline: fillPath!, matrix: valueToPixelMatrix, bounds: _xBounds)
        }
        
        CGContextBeginPath(context)
        CGContextAddPath(context, cubicPath)
        CGContextSetStrokeColorWithColor(context, drawingColor.CGColor)
        CGContextStrokePath(context)
        
        CGContextRestoreGState(context)
    }
    
    public func drawCubicFill(
        context context: CGContext,
                dataSet: ILineChartDataSet,
                spline: CGMutablePath,
                matrix: CGAffineTransform,
                bounds: XBounds)
    {
        guard let dataProvider = dataProvider else { return }
        
        if bounds.range <= 0
        {
            return
        }
        
        let fillMin = dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0

        var pt1 = CGPoint(x: CGFloat(dataSet.entryForIndex(bounds.min + bounds.range)?.x ?? 0.0), y: fillMin)
        var pt2 = CGPoint(x: CGFloat(dataSet.entryForIndex(bounds.min)?.x ?? 0.0), y: fillMin)
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
            dataProvider = dataProvider,
            animator = animator,
            viewPortHandler = self.viewPortHandler
            else { return }
        
        let trans = dataProvider.getTransformer(dataSet.axisDependency)
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        let entryCount = dataSet.entryCount
        let isDrawSteppedEnabled = dataSet.mode == .Stepped
        let pointsPerEntryPair = isDrawSteppedEnabled ? 4 : 2
        
        let phaseY = animator.phaseY
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        // if drawing filled is enabled
        if (dataSet.isDrawFilledEnabled && entryCount > 0)
        {
            drawLinearFill(context: context, dataSet: dataSet, trans: trans, bounds: _xBounds)
        }
        
        CGContextSaveGState(context)
        
        CGContextSetLineCap(context, dataSet.lineCapType)

        // more than 1 color
        if dataSet.colors.count > 1
        {
            if _lineSegments.count != pointsPerEntryPair
            {
                _lineSegments = [CGPoint](count: pointsPerEntryPair, repeatedValue: CGPoint())
            }
            
            for j in _xBounds.min.stride(through: _xBounds.range + _xBounds.min, by: 1)
            {
                var e: ChartDataEntry! = dataSet.entryForIndex(j)
                
                if e == nil { continue }
                
                _lineSegments[0].x = CGFloat(e.x)
                _lineSegments[0].y = CGFloat(e.y * phaseY)
                
                if j < _xBounds.range
                {
                    e = dataSet.entryForIndex(j + 1)
                    
                    if e == nil { break }
                    
                    if isDrawSteppedEnabled
                    {
                        _lineSegments[1] = CGPoint(x: CGFloat(e.x), y: _lineSegments[0].y)
                        _lineSegments[2] = _lineSegments[1]
                        _lineSegments[3] = CGPoint(x: CGFloat(e.x), y: CGFloat(e.y * phaseY))
                    }
                    else
                    {
                        _lineSegments[1] = CGPoint(x: CGFloat(e.x), y: CGFloat(e.y * phaseY))
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
            
            if _lineSegments.count != max((entryCount) * pointsPerEntryPair, pointsPerEntryPair)
            {
                _lineSegments = [CGPoint](count: max((entryCount) * pointsPerEntryPair, pointsPerEntryPair), repeatedValue: CGPoint())
            }
            
            e1 = dataSet.entryForIndex(_xBounds.min)
            
            if e1 != nil
            {
                var j = 0
                for x in _xBounds.min.stride(through: _xBounds.range + _xBounds.min, by: 1)
                {
                    e1 = dataSet.entryForIndex(x == 0 ? 0 : (x - 1))
                    e2 = dataSet.entryForIndex(x)
                    
                    if e1 == nil || e2 == nil { continue }
                    
                    _lineSegments[j] = CGPointApplyAffineTransform(
                        CGPoint(
                            x: CGFloat(e1.x),
                            y: CGFloat(e1.y * phaseY)
                        ), valueToPixelMatrix)
                    j += 1
                    
                    if isDrawSteppedEnabled
                    {
                        _lineSegments[j] = CGPointApplyAffineTransform(
                            CGPoint(
                                x: CGFloat(e2.x),
                                y: CGFloat(e1.y * phaseY)
                            ), valueToPixelMatrix)
                        j += 1
                        
                        _lineSegments[j] = CGPointApplyAffineTransform(
                            CGPoint(
                                x: CGFloat(e2.x),
                                y: CGFloat(e1.y * phaseY)
                            ), valueToPixelMatrix)
                        j += 1
                    }
                    
                    _lineSegments[j] = CGPointApplyAffineTransform(
                        CGPoint(
                            x: CGFloat(e2.x),
                            y: CGFloat(e2.y * phaseY)
                        ), valueToPixelMatrix)
                    j += 1
                }
                
                if j > 0
                {
                    let size = max((_xBounds.range + 1) * pointsPerEntryPair, pointsPerEntryPair)
                    CGContextSetStrokeColorWithColor(context, dataSet.colorAt(0).CGColor)
                    CGContextStrokeLineSegments(context, _lineSegments, size)
                }
            }
        }
        
        CGContextRestoreGState(context)
    }
    
    public func drawLinearFill(context context: CGContext, dataSet: ILineChartDataSet, trans: Transformer, bounds: XBounds)
    {
        guard let dataProvider = dataProvider else { return }
        
        let filled = generateFilledPath(
            dataSet: dataSet,
            fillMin: dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0,
            bounds: bounds,
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
    private func generateFilledPath(dataSet dataSet: ILineChartDataSet, fillMin: CGFloat, bounds: XBounds, matrix: CGAffineTransform) -> CGPath
    {
        let phaseY = animator?.phaseY ?? 1.0
        let isDrawSteppedEnabled = dataSet.mode == .Stepped
        var matrix = matrix
        
        var e: ChartDataEntry!
        
        let filled = CGPathCreateMutable()
        
        e = dataSet.entryForIndex(bounds.min)
        if e != nil
        {
            CGPathMoveToPoint(filled, &matrix, CGFloat(e.x), fillMin)
            CGPathAddLineToPoint(filled, &matrix, CGFloat(e.x), CGFloat(e.y * phaseY))
        }
        
        // create a new path
        for x in (bounds.min + 1).stride(through: bounds.range + bounds.min, by: 1)
        {
            guard let e = dataSet.entryForIndex(x) else { continue }
            
            if isDrawSteppedEnabled
            {
                guard let ePrev = dataSet.entryForIndex(x-1) else { continue }
                CGPathAddLineToPoint(filled, &matrix, CGFloat(e.x), CGFloat(ePrev.y * phaseY))
            }
            
            CGPathAddLineToPoint(filled, &matrix, CGFloat(e.x), CGFloat(e.y * phaseY))
        }
        
        // close up
        e = dataSet.entryForIndex(bounds.range + bounds.min)
        if e != nil
        {
            CGPathAddLineToPoint(filled, &matrix, CGFloat(e.x), fillMin)
        }
        CGPathCloseSubpath(filled)
        
        return filled
    }
    
    public override func drawValues(context context: CGContext)
    {
        guard let
            dataProvider = dataProvider,
            lineData = dataProvider.lineData,
            animator = animator,
            viewPortHandler = self.viewPortHandler
            else { return }
        
        if isDrawingValuesAllowed(dataProvider: dataProvider)
        {
            var dataSets = lineData.dataSets
            
            let phaseX = max(0.0, min(1.0, animator.phaseX))
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for i in 0 ..< dataSets.count
            {
                guard let dataSet = dataSets[i] as? ILineChartDataSet else { continue }
                
                if !shouldDrawValues(forDataSet: dataSet)
                {
                    continue
                }
                
                let valueFont = dataSet.valueFont
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                let trans = dataProvider.getTransformer(dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                // make sure the values do not interfear with the circles
                var valOffset = Int(dataSet.circleRadius * 1.75)
                
                if !dataSet.isDrawCirclesEnabled
                {
                    valOffset = valOffset / 2
                }
                
                _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
                
                for j in _xBounds.min.stride(to: Int(ceil(Double(_xBounds.max - _xBounds.min) * phaseX + Double(_xBounds.min))), by: 1)
                {
                    guard let e = dataSet.entryForIndex(j) else { break }
                    
                    pt.x = CGFloat(e.x)
                    pt.y = CGFloat(e.y * phaseY)
                    pt = CGPointApplyAffineTransform(pt, valueToPixelMatrix)
                    
                    if (!viewPortHandler.isInBoundsRight(pt.x))
                    {
                        break
                    }
                    
                    if (!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y))
                    {
                        continue
                    }
                    
                    ChartUtils.drawText(
                        context: context,
                        text: formatter.stringForValue(
                            e.y,
                            entry: e,
                            dataSetIndex: i,
                            viewPortHandler: viewPortHandler),
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
            animator = animator,
            viewPortHandler = self.viewPortHandler
            else { return }
        
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
            
            _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
            
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
            
            for j in _xBounds.min.stride(through: _xBounds.range + _xBounds.min, by: 1)
            {
                guard let e = dataSet.entryForIndex(j) else { break }

                pt.x = CGFloat(e.x)
                pt.y = CGFloat(e.y * phaseY)
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
    
    public override func drawHighlighted(context context: CGContext, indices: [Highlight])
    {
        guard let
            dataProvider = dataProvider,
            lineData = dataProvider.lineData,
            animator = animator
            else { return }
        
        let chartXMax = dataProvider.chartXMax
        
        CGContextSaveGState(context)
        
        for high in indices
        {
            guard let set = lineData.getDataSetByIndex(high.dataSetIndex) as? ILineChartDataSet
                where set.isHighlightEnabled
                else { continue }
            
            guard let e = set.entryForXValue(high.x) else { continue }
            
            if !isInBoundsX(entry: e, dataSet: set)
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
            
            let x = high.x; // get the x-position
            let y = high.y * Double(animator.phaseY)
            
            if (x > chartXMax * animator.phaseX)
            {
                continue
            }
            
            let trans = dataProvider.getTransformer(set.axisDependency)
            
            let pt = trans.pixelForValues(x: x, y: y)
            
            high.setDraw(pt: pt)
            
            // draw the lines
            drawHighlightLines(context: context, point: pt, set: set)
        }
        
        CGContextRestoreGState(context)
    }
}