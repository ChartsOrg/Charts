//
//  LineChartBreakRenderer.swift
//  Charts
//
//  Created by wason on 2018/3/23.
//  
//
//  Description:
//
    

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif

open class LineChartBreakRenderer: LineChartRenderer
{
    
    
    override open func drawCubicBezier(context: CGContext, dataSet: ILineChartDataSet)
    {
        guard let dataProvider = dataProvider else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        // get the color that is specified for this position from the DataSet
        let drawingColor = dataSet.colors.first!
        
        let intensity = dataSet.cubicIntensity
        
        // the path for the cubic-spline
        var cubicPath = CGMutablePath()
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        if _xBounds.range >= 1
        {
            var prevDx: CGFloat = 0.0
            var prevDy: CGFloat = 0.0
            var curDx: CGFloat = 0.0
            var curDy: CGFloat = 0.0
            
            // Take an extra point from the left, and an extra from the right.
            // That's because we need 4 points for a cubic bezier (cubic=4), otherwise we get lines moving and doing weird stuff on the edges of the chart.
            // So in the starting `prev` and `cur`, go -2, -1
            // And in the `lastIndex`, add +1
            
            let firstIndex = _xBounds.min + 1
            let lastIndex = _xBounds.min + _xBounds.range
            
            var prevPrev: ChartDataEntry! = nil
            var prev: ChartDataEntry! = dataSet.entryForIndex(max(firstIndex - 2, 0))
            var cur: ChartDataEntry! = dataSet.entryForIndex(max(firstIndex - 1, 0))
            var next: ChartDataEntry! = cur
            var nextIndex: Int = -1
            
            if cur == nil { return }
            
            // let the spline start
            cubicPath.move(to: CGPoint(x: CGFloat(cur.x), y: CGFloat(cur.y * phaseY)), transform: valueToPixelMatrix)
            for j in stride(from: firstIndex, through: lastIndex, by: 1)
            {
                prevPrev = prev
                prev = cur
                cur = nextIndex == j ? next : dataSet.entryForIndex(j)
                
                nextIndex = j + 1 < dataSet.entryCount ? j + 1 : j
                next = dataSet.entryForIndex(nextIndex)
                
                if next == nil { break }
                
                prevDx = CGFloat(cur.x - prevPrev.x) * intensity
                prevDy = CGFloat(cur.y - prevPrev.y) * intensity
                curDx = CGFloat(next.x - prev.x) * intensity
                curDy = CGFloat(next.y - prev.y) * intensity
                
                if cur.x - prev.x ==  1{
                    
                    cubicPath.addCurve(
                        to: CGPoint(
                            x: CGFloat(cur.x),
                            y: CGFloat(cur.y) * CGFloat(phaseY)),
                        control1: CGPoint(
                            x: CGFloat(prev.x) + prevDx,
                            y: (CGFloat(prev.y) + prevDy) * CGFloat(phaseY)),
                        control2: CGPoint(
                            x: CGFloat(cur.x) - curDx,
                            y: (CGFloat(cur.y) - curDy) * CGFloat(phaseY)),
                        transform: valueToPixelMatrix)
                    
                    drawCubicSave(context: context, dataSet: dataSet, cubicPath: cubicPath, matrix: valueToPixelMatrix, color: drawingColor, boundsMin: j - 1, boundsRange: 1)
                }
                
                cubicPath = CGMutablePath();
                cubicPath.move(to: CGPoint(x: CGFloat(cur.x), y: CGFloat(cur.y * phaseY)), transform: valueToPixelMatrix)
            }
        }
    }
    
    override open func drawHorizontalBezier(context: CGContext, dataSet: ILineChartDataSet)
    {
        guard let dataProvider = dataProvider else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        // get the color that is specified for this position from the DataSet
        let drawingColor = dataSet.colors.first!
        
        // the path for the cubic-spline
        var cubicPath = CGMutablePath()
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        if _xBounds.range >= 1
        {
            var prev: ChartDataEntry! = dataSet.entryForIndex(_xBounds.min)
            var cur: ChartDataEntry! = prev
            
            if cur == nil { return }
            
            // let the spline start
            cubicPath.move(to: CGPoint(x: CGFloat(cur.x), y: CGFloat(cur.y * phaseY)), transform: valueToPixelMatrix)
            var startIndex = _xBounds.min
            let lastIndex = _xBounds.min + _xBounds.range
        
            for j in stride(from: (_xBounds.min + 1), through: _xBounds.range + _xBounds.min, by: 1)
            {
                prev = cur
                cur = dataSet.entryForIndex(j)
                let cpx = CGFloat(prev.x + (cur.x - prev.x) / 2.0)
                if cur.x - prev.x == 1 {
                    cubicPath.addCurve(
                        to: CGPoint(
                            x: CGFloat(cur.x),
                            y: CGFloat(cur.y * phaseY)),
                        control1: CGPoint(
                            x: cpx,
                            y: CGFloat(prev.y * phaseY)),
                        control2: CGPoint(
                            x: cpx,
                            y: CGFloat(cur.y * phaseY)),
                        transform: valueToPixelMatrix)
                    drawCubicSave(context: context, dataSet: dataSet, cubicPath: cubicPath, matrix: valueToPixelMatrix, color: drawingColor, boundsMin: j-1, boundsRange: 1)
                }
                cubicPath = CGMutablePath();
                cubicPath.move(to: CGPoint(x: CGFloat(cur.x), y: CGFloat(cur.y * phaseY)), transform: valueToPixelMatrix)
            }
        }
    }

    
    open func  drawCubicSave(context: CGContext,
                             dataSet: ILineChartDataSet,
                             cubicPath: CGMutablePath,
                             matrix: CGAffineTransform,
                             color: UIColor,
                             boundsMin: Int,
                             boundsRange: Int){
        
        context.saveGState()
        if dataSet.isDrawFilledEnabled
        {
            // Copy this path because we make changes to it
            let fillPath = cubicPath.mutableCopy()
            drawCubicFill(context: context, dataSet: dataSet, spline: fillPath!, matrix: matrix, min: boundsMin, range: boundsRange)
        }
        context.beginPath()
        context.addPath(cubicPath)
        context.setStrokeColor(color.cgColor)
        context.strokePath()
        context.restoreGState()
    }
    
    open func drawCubicFill(
        context: CGContext,
        dataSet: ILineChartDataSet,
        spline: CGMutablePath,
        matrix: CGAffineTransform,
        min: Int,
        range: Int)
    {
        guard
            let dataProvider = dataProvider
            else { return }
        
        if range <= 0
        {
            return
        }
        
        let fillMin = dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0
        
        var pt1 = CGPoint(x: CGFloat(dataSet.entryForIndex(min + range)?.x ?? 0.0), y: fillMin)
        var pt2 = CGPoint(x: CGFloat(dataSet.entryForIndex(min)?.x ?? 0.0), y: fillMin)
        pt1 = pt1.applying(matrix)
        pt2 = pt2.applying(matrix)
        
        spline.addLine(to: pt1)
        spline.addLine(to: pt2)
        spline.closeSubpath()
        
        if dataSet.fill != nil
        {
            drawFilledPath(context: context, path: spline, fill: dataSet.fill!, fillAlpha: dataSet.fillAlpha)
        }
        else
        {
            drawFilledPath(context: context, path: spline, fillColor: dataSet.fillColor, fillAlpha: dataSet.fillAlpha)
        }
    }
    
    private var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    override open func drawLinear(context: CGContext, dataSet: ILineChartDataSet)
    {
        guard let dataProvider = dataProvider else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        let valueToPixelMatrix = trans.valueToPixelMatrix
        let entryCount = dataSet.entryCount
        let isDrawSteppedEnabled = dataSet.mode == .stepped
        let pointsPerEntryPair = isDrawSteppedEnabled ? 4 : 2
        let phaseY = animator.phaseY
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        

        context.saveGState()
        context.setLineCap(dataSet.lineCapType)
        
        // more than 1 color
        if dataSet.colors.count > 1
        {
            if _lineSegments.count != pointsPerEntryPair
            {
                // Allocate once in correct size
                _lineSegments = [CGPoint](repeating: CGPoint(), count: pointsPerEntryPair)
            }
            
            for j in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1)
            {
                var e: ChartDataEntry! = dataSet.entryForIndex(j)
                
                if e == nil { continue }
                
                _lineSegments[0].x = CGFloat(e.x)
                _lineSegments[0].y = CGFloat(e.y * phaseY)
                
                if j < _xBounds.max
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
                    _lineSegments[i] = _lineSegments[i].applying(valueToPixelMatrix)
                }
                
                if (!viewPortHandler.isInBoundsRight(_lineSegments[0].x))
                {
                    break
                }
                
                // make sure the lines don't do shitty things outside bounds
                if !viewPortHandler.isInBoundsLeft(_lineSegments[1].x)
                    || (!viewPortHandler.isInBoundsTop(_lineSegments[0].y) && !viewPortHandler.isInBoundsBottom(_lineSegments[1].y))
                {
                    continue
                }
                
                // get the color that is set for this line-segment
                context.setStrokeColor(dataSet.color(atIndex: j).cgColor)
                context.strokeLineSegments(between: _lineSegments)
            }
        }
        else
        { // only one color per dataset
            
            var e1: ChartDataEntry!
            var e2: ChartDataEntry!
            
            e1 = dataSet.entryForIndex(_xBounds.min)
            
            if e1 != nil
            {
                context.beginPath()
//                var startIndex = _xBounds.min
                for x in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1)
                {
                    e1 = dataSet.entryForIndex(x == 0 ? 0 : (x - 1))
                    e2 = dataSet.entryForIndex(x)
                    
                    if e1 == nil || e2 == nil { continue }
                    
                    if e2.x - e1.x == 1 {
                        
                        if isDrawSteppedEnabled
                        {
                            context.addLine(to: CGPoint(
                                x: CGFloat(e2.x),
                                y: CGFloat(e1.y * phaseY)
                                ).applying(valueToPixelMatrix))
                        }
                        context.move(to: CGPoint(
                            x: CGFloat(e1.x),
                            y: CGFloat(e1.y * phaseY)
                            ).applying(valueToPixelMatrix))
                        context.addLine(to: CGPoint(
                            x: CGFloat(e2.x),
                            y: CGFloat(e2.y * phaseY)
                            ).applying(valueToPixelMatrix))
                        
                        context.setStrokeColor(dataSet.color(atIndex: 0).cgColor)
                        context.strokePath()
                        
                        // if drawing filled is enabled
                        if dataSet.isDrawFilledEnabled && entryCount > 0
                        {
                            drawLinearFill(context: context, dataSet: dataSet, trans: trans, min: x - 1, range:1)
                        }

                    }
                }
            }
        }
    }
    
    open func drawLinearFill(context: CGContext, dataSet: ILineChartDataSet, trans: Transformer, min: Int,
                             range: Int)
    {
        guard let dataProvider = dataProvider else { return }
        
        let filled = generateFilledPath(
            dataSet: dataSet,
            fillMin: dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0,
            min: min,
            range: range,
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
    private func generateFilledPath(dataSet: ILineChartDataSet, fillMin: CGFloat, min: Int,
                                    range: Int, matrix: CGAffineTransform) -> CGPath
    {
        let phaseY = animator.phaseY
        let isDrawSteppedEnabled = dataSet.mode == .stepped
        let matrix = matrix
        
        var e: ChartDataEntry!
        
        let filled = CGMutablePath()
        
        e = dataSet.entryForIndex(min)
        if e != nil
        {
            filled.move(to: CGPoint(x: CGFloat(e.x), y: fillMin), transform: matrix)
            filled.addLine(to: CGPoint(x: CGFloat(e.x), y: CGFloat(e.y * phaseY)), transform: matrix)
        }
        
        // create a new path
        for x in stride(from: (min + 1), through: range + min, by: 1)
        {
            guard let e = dataSet.entryForIndex(x) else { continue }
            
            if isDrawSteppedEnabled
            {
                guard let ePrev = dataSet.entryForIndex(x-1) else { continue }
                filled.addLine(to: CGPoint(x: CGFloat(e.x), y: CGFloat(ePrev.y * phaseY)), transform: matrix)
            }
            
            filled.addLine(to: CGPoint(x: CGFloat(e.x), y: CGFloat(e.y * phaseY)), transform: matrix)
        }
        
        // close up
        e = dataSet.entryForIndex(range + min)
        if e != nil
        {
            filled.addLine(to: CGPoint(x: CGFloat(e.x), y: fillMin), transform: matrix)
        }
        filled.closeSubpath()
        
        return filled
    }

}
