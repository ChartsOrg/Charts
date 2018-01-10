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


open class LineChartRenderer: LineRadarRenderer
{
    @objc open weak var dataProvider: LineChartDataProvider?
    
    @objc public init(dataProvider: LineChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        self.dataProvider = dataProvider

        super.init(animator: animator, viewPortHandler: viewPortHandler)
    }
    
    open override func drawData(context: CGContext)
    {
        guard let lineData = dataProvider?.lineData else { return }
        
        for i in 0 ..< lineData.dataSetCount
        {
            guard let set = lineData.getDataSetByIndex(i) as? LineChartDataSetProtocol else
            {
                fatalError("Datasets for LineChartRenderer must conform to LineChartDataSetProtocol")
            }
            
            guard set.isVisible else { continue }

            drawDataSet(context: context, dataSet: set)
        }
    }
    
    @objc open func drawDataSet(context: CGContext, dataSet: LineChartDataSetProtocol)
    {
        guard dataSet.entryCount >= 0 else { return }

        context.saveGState()
        defer { context.restoreGState() }

        context.setLineWidth(dataSet.lineWidth)
        if dataSet.lineDashLengths != nil
        {
            context.setLineDash(phase: dataSet.lineDashPhase, lengths: dataSet.lineDashLengths!)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        // if drawing cubic lines is enabled
        switch dataSet.mode
        {
        case .linear: fallthrough
        case .stepped:
            drawLinear(context: context, dataSet: dataSet)
            
        case .cubicBezier:
            drawCubicBezier(context: context, dataSet: dataSet)
            
        case .horizontalBezier:
            drawHorizontalBezier(context: context, dataSet: dataSet)
        }
    }
    
    @objc open func drawCubicBezier(context: CGContext, dataSet: LineChartDataSetProtocol)
    {
        guard let dataProvider = dataProvider else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = CGFloat(animator.phaseY)
        
        xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        // get the color that is specified for this position from the DataSet
        let drawingColor = dataSet.colors.first!
        
        let intensity = dataSet.cubicIntensity
        
        // the path for the cubic-spline
        let cubicPath = CGMutablePath()
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        if xBounds.range >= 1
        {
            var prevDx: CGFloat = 0.0
            var prevDy: CGFloat = 0.0
            var curDx: CGFloat = 0.0
            var curDy: CGFloat = 0.0
            
            // Take an extra point from the left, and an extra from the right.
            // That's because we need 4 points for a cubic bezier (cubic=4), otherwise we get lines moving and doing weird stuff on the edges of the chart.
            // So in the starting `prev` and `cur`, go -2, -1
            // And in the `lastIndex`, add +1
            
            let firstIndex = xBounds.min + 1
            let lastIndex = xBounds.min + xBounds.range
            
            var prevPrev: ChartDataEntry!
            var prev: ChartDataEntry! = dataSet.entryForIndex(max(firstIndex - 2, 0))
            var cur: ChartDataEntry! = dataSet.entryForIndex(max(firstIndex - 1, 0))
            var next: ChartDataEntry! = cur
            var nextIndex: Int = -1
            
            if cur == nil { return }
            
            // let the spline start
            cubicPath.move(to: CGPoint(x: CGFloat(cur.x), y: CGFloat(cur.y) * phaseY), transform: valueToPixelMatrix)
            
            for j in firstIndex...lastIndex
            {
                prevPrev = prev
                prev = cur
                cur = nextIndex == j ? next : dataSet.entryForIndex(j)
                
                nextIndex = j + 1 < dataSet.entryCount ? j + 1 : j
                next = dataSet.entryForIndex(nextIndex)
                
                guard next != nil else { break }
                
                prevDx = CGFloat(cur.x - prevPrev.x) * intensity
                prevDy = CGFloat(cur.y - prevPrev.y) * intensity
                curDx = CGFloat(next.x - prev.x) * intensity
                curDy = CGFloat(next.y - prev.y) * intensity
                
                cubicPath.addCurve(to: CGPoint(x: CGFloat(cur.x),
                                               y: CGFloat(cur.y) * phaseY),
                                   control1: CGPoint(x: CGFloat(prev.x) + prevDx,
                                                     y: (CGFloat(prev.y) + prevDy) * phaseY),
                                   control2: CGPoint(x: CGFloat(cur.x) - curDx,
                                                     y: (CGFloat(cur.y) - curDy) * phaseY),
                                   transform: valueToPixelMatrix)
            }
        }
        
        context.saveGState()
        defer { context.restoreGState() }

        if dataSet.isDrawFilledEnabled
        {
            // Copy this path because we make changes to it
            let fillPath = cubicPath.mutableCopy()
            
            drawCubicFill(context: context, dataSet: dataSet, spline: fillPath!, matrix: valueToPixelMatrix, bounds: xBounds)
        }
        
        context.beginPath()
        context.addPath(cubicPath)
        context.setStrokeColor(drawingColor.cgColor)
        context.strokePath()
    }
    
    @objc open func drawHorizontalBezier(context: CGContext, dataSet: LineChartDataSetProtocol)
    {
        guard let dataProvider = dataProvider else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        // get the color that is specified for this position from the DataSet
        let drawingColor = dataSet.colors.first!
        
        // the path for the cubic-spline
        let cubicPath = CGMutablePath()
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        if xBounds.range > 0
        {
            var prev: ChartDataEntry
            guard var cur = dataSet.entryForIndex(xBounds.min) else { return }
            
            // let the spline start
            cubicPath.move(to: CGPoint(x: cur.x, y: cur.y * phaseY), transform: valueToPixelMatrix)

            let start = xBounds.min + 1
            let end = xBounds.min + xBounds.range

            for j in start...end
            {
                prev = cur
                cur = dataSet.entryForIndex(j)!
                
                let cpx = prev.x + (cur.x - prev.x) / 2.0
                
                cubicPath.addCurve(to: CGPoint(x: cur.x, y: cur.y * phaseY),
                                   control1: CGPoint(x: cpx, y: prev.y * phaseY),
                                   control2: CGPoint(x: cpx, y: cur.y * phaseY),
                                   transform: valueToPixelMatrix)
            }
        }
        
        context.saveGState()
        defer { context.restoreGState() }

        if dataSet.isDrawFilledEnabled
        {
            // Copy this path because we make changes to it
            let fillPath = cubicPath.mutableCopy()
            
            drawCubicFill(context: context, dataSet: dataSet, spline: fillPath!, matrix: valueToPixelMatrix, bounds: xBounds)
        }
        
        context.beginPath()
        context.addPath(cubicPath)
        context.setStrokeColor(drawingColor.cgColor)
        context.strokePath()
    }
    
    open func drawCubicFill(
        context: CGContext,
                dataSet: LineChartDataSetProtocol,
                spline: CGMutablePath,
                matrix: CGAffineTransform,
                bounds: XBounds)
    {
        guard
            let dataProvider = dataProvider,
            bounds.range > 0
            else { return }

        let fillMin = dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0

        var pt1 = CGPoint(x: CGFloat(dataSet.entryForIndex(bounds.min + bounds.range)?.x ?? 0.0), y: fillMin)
        var pt2 = CGPoint(x: CGFloat(dataSet.entryForIndex(bounds.min)?.x ?? 0.0), y: fillMin)
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
    
    private var lineSegments = [CGPoint](repeating: .zero, count: 2)
    
    @objc open func drawLinear(context: CGContext, dataSet: LineChartDataSetProtocol)
    {
        guard let dataProvider = dataProvider else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        let entryCount = dataSet.entryCount
        let isDrawSteppedEnabled = dataSet.mode == .stepped
        let pointsPerEntryPair = isDrawSteppedEnabled ? 4 : 2
        
        let phaseY = animator.phaseY
        
        xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        // if drawing filled is enabled
        if dataSet.isDrawFilledEnabled && entryCount > 0
        {
            drawLinearFill(context: context, dataSet: dataSet, trans: trans, bounds: xBounds)
        }
        
        context.saveGState()
        defer { context.restoreGState() }

        context.setLineCap(dataSet.lineCapType)

        // more than 1 color
        if dataSet.colors.count > 1
        {
            if lineSegments.count != pointsPerEntryPair
            {
                // Allocate once in correct size
                lineSegments = [CGPoint](repeating: .zero, count: pointsPerEntryPair)
            }
            
            for j in xBounds.min...(xBounds.range + xBounds.min)
            {
                var e: ChartDataEntry! = dataSet.entryForIndex(j)
                
                if e == nil { continue }
                
                lineSegments[0].x = CGFloat(e.x)
                lineSegments[0].y = CGFloat(e.y * phaseY)
                
                if j < xBounds.max
                {
                    e = dataSet.entryForIndex(j + 1)
                    
                    if e == nil { break }
                    
                    if isDrawSteppedEnabled
                    {
                        lineSegments[1] = CGPoint(x: CGFloat(e.x), y: lineSegments[0].y)
                        lineSegments[2] = lineSegments[1]
                        lineSegments[3] = CGPoint(x: e.x, y: e.y * phaseY)
                    }
                    else
                    {
                        lineSegments[1] = CGPoint(x: e.x, y: e.y * phaseY)
                    }
                }
                else
                {
                    lineSegments[1] = lineSegments[0]
                }

                lineSegments = lineSegments.map { $0.applying(valueToPixelMatrix) }
                
                guard viewPortHandler.isInBoundsRight(lineSegments[0].x) else { break }

                // make sure the lines don't do shitty things outside bounds
                guard viewPortHandler.isInBoundsLeft(lineSegments[1].x)
                    || (viewPortHandler.isInBoundsTop(lineSegments[0].y) && viewPortHandler.isInBoundsBottom(lineSegments[1].y))
                    else { continue }

                // get the color that is set for this line-segment
                context.setStrokeColor(dataSet.color(atIndex: j).cgColor)
                context.strokeLineSegments(between: lineSegments)
            }
        }
        else
        { // only one color per dataset
            
            var e1: ChartDataEntry! = dataSet.entryForIndex(xBounds.min)
            var e2: ChartDataEntry!

            guard e1 != nil else { return }

            context.beginPath()
            var firstPoint = true

            for x in xBounds.min...(xBounds.range + xBounds.min)
            {
                e1 = dataSet.entryForIndex(x == 0 ? 0 : (x - 1))
                e2 = dataSet.entryForIndex(x)

                guard e1 != nil, e2 != nil else { continue }

                let pt = CGPoint(x: e1.x, y: e1.y * phaseY)
                    .applying(valueToPixelMatrix)

                if firstPoint
                {
                    context.move(to: pt)
                    firstPoint = false
                }
                else
                {
                    context.addLine(to: pt)
                }

                if isDrawSteppedEnabled
                {
                    let p = CGPoint(x: e2.x,y: e1.y * phaseY)
                    context.addLine(to: p.applying(valueToPixelMatrix))
                }

                context.addLine(to: CGPoint(x: e2.x, y: e2.y * phaseY).applying(valueToPixelMatrix))
            }

            if !firstPoint
            {
                context.setStrokeColor(dataSet.color(atIndex: 0).cgColor)
                context.strokePath()
            }
        }
    }
    
    open func drawLinearFill(context: CGContext, dataSet: LineChartDataSetProtocol, trans: Transformer, bounds: XBounds)
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
    private func generateFilledPath(dataSet: LineChartDataSetProtocol, fillMin: CGFloat, bounds: XBounds, matrix: CGAffineTransform) -> CGPath
    {
        let phaseY = animator.phaseY
        let isDrawSteppedEnabled = dataSet.mode == .stepped
        let matrix = matrix
        
        var e: ChartDataEntry!
        
        let filled = CGMutablePath()
        
        e = dataSet.entryForIndex(bounds.min)
        if e != nil
        {
            filled.move(to: CGPoint(x: CGFloat(e.x), y: fillMin), transform: matrix)
            filled.addLine(to: CGPoint(x: e.x, y: e.y * phaseY), transform: matrix)
        }
        
        // create a new path
        for x in (bounds.min + 1)...(bounds.range + bounds.min)
        {
            guard let e = dataSet.entryForIndex(x) else { continue }
            
            if isDrawSteppedEnabled
            {
                guard let ePrev = dataSet.entryForIndex(x-1) else { continue }
                filled.addLine(to: CGPoint(x: e.x, y: ePrev.y * phaseY), transform: matrix)
            }
            
            filled.addLine(to: CGPoint(x: e.x, y: e.y * phaseY), transform: matrix)
        }
        
        // close up
        e = dataSet.entryForIndex(bounds.range + bounds.min)
        if e != nil
        {
            filled.addLine(to: CGPoint(x: CGFloat(e.x), y: fillMin), transform: matrix)
        }
        filled.closeSubpath()
        
        return filled
    }
    
    open override func drawValues(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let lineData = dataProvider.lineData
            else { return }

        if isDrawingValuesAllowed(dataProvider: dataProvider)
        {
            var dataSets = lineData.dataSets
            
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for i in 0 ..< dataSets.count
            {
                guard
                    let dataSet = dataSets[i] as? LineChartDataSetProtocol,
                    shouldDrawValues(forDataSet: dataSet),
                    let formatter = dataSet.valueFormatter
                    else { continue }

                let valueFont = dataSet.valueFont

                let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                let iconsOffset = dataSet.iconsOffset
                
                // make sure the values do not interfear with the circles
                var valOffset = Int(dataSet.circleRadius * 1.75)
                
                if !dataSet.isDrawCirclesEnabled
                {
                    valOffset = valOffset / 2
                }
                
                xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
                
                for j in xBounds.min...min(xBounds.min + xBounds.range, xBounds.max)
                {
                    guard let e = dataSet.entryForIndex(j) else { break }
                    
                    pt.x = CGFloat(e.x)
                    pt.y = CGFloat(e.y * phaseY)
                    pt = pt.applying(valueToPixelMatrix)
                    
                    guard viewPortHandler.isInBoundsRight(pt.x) else { break }
                    
                    guard
                        viewPortHandler.isInBoundsLeft(pt.x),
                        viewPortHandler.isInBoundsY(pt.y)
                        else { continue }

                    if dataSet.isDrawValuesEnabled
                    {
                        context.drawText(formatter.stringForValue(e.y,
                                                                  entry: e,
                                                                  dataSetIndex: i,
                                                                  viewPortHandler: viewPortHandler),
                                         at: CGPoint(x: pt.x,
                                                     y: pt.y - CGFloat(valOffset) - valueFont.lineHeight),
                                         align: .center,
                                         attributes: [.font: valueFont,
                                                      .foregroundColor: dataSet.valueTextColorAt(j)])
                    }
                    
                    if let icon = e.icon, dataSet.isDrawIconsEnabled
                    {
                        context.drawImage(icon,
                                          atCenter: CGPoint(x: pt.x + iconsOffset.x,
                                                          y: pt.y + iconsOffset.y),
                                          size: icon.size)
                    }
                }
            }
        }
    }
    
    open override func drawExtras(context: CGContext)
    {
        drawCircles(context: context)
    }
    
    private func drawCircles(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let lineData = dataProvider.lineData
            else { return }
        
        let phaseY = animator.phaseY

        let dataSets = lineData.dataSets
        
        var pt = CGPoint()
        var rect = CGRect()
        
        context.saveGState()
        defer { context.restoreGState() }

        for i in 0 ..< dataSets.count
        {
            guard
                let dataSet = lineData.getDataSetByIndex(i) as? LineChartDataSetProtocol,
                dataSet.isVisible,
                dataSet.isDrawCirclesEnabled,
                dataSet.entryCount != 0
                else { continue }

            let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
            let valueToPixelMatrix = trans.valueToPixelMatrix
            
            xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
            
            let circleRadius = dataSet.circleRadius
            let circleDiameter = circleRadius * 2.0
            let circleHoleRadius = dataSet.circleHoleRadius
            let circleHoleDiameter = circleHoleRadius * 2.0
            
            let drawCircleHole = dataSet.isDrawCircleHoleEnabled
                && circleHoleRadius < circleRadius
                && circleHoleRadius > 0.0
            let drawTransparentCircleHole = drawCircleHole
                && (dataSet.circleHoleColor == nil || dataSet.circleHoleColor == .clear)
            
            for j in xBounds.min...(xBounds.range + xBounds.min)
            {
                guard let e = dataSet.entryForIndex(j) else { break }

                pt.x = CGFloat(e.x)
                pt.y = CGFloat(e.y * phaseY)
                pt = pt.applying(valueToPixelMatrix)
                
                guard viewPortHandler.isInBoundsRight(pt.x) else { break }
                
                // make sure the circles don't do shitty things outside bounds
                guard
                    viewPortHandler.isInBoundsLeft(pt.x),
                    viewPortHandler.isInBoundsY(pt.y)
                    else { continue }

                context.setFillColor(dataSet.getCircleColor(atIndex: j)!.cgColor)
                
                rect.origin.x = pt.x - circleRadius
                rect.origin.y = pt.y - circleRadius
                rect.size.width = circleDiameter
                rect.size.height = circleDiameter
                
                if drawTransparentCircleHole
                {
                    // Begin path for circle with hole
                    context.beginPath()
                    context.addEllipse(in: rect)
                    
                    // Cut hole in path
                    rect.origin.x = pt.x - circleHoleRadius
                    rect.origin.y = pt.y - circleHoleRadius
                    rect.size.width = circleHoleDiameter
                    rect.size.height = circleHoleDiameter
                    context.addEllipse(in: rect)
                    
                    // Fill in-between
                    context.fillPath(using: .evenOdd)
                }
                else
                {
                    context.fillEllipse(in: rect)
                    
                    if drawCircleHole
                    {
                        context.setFillColor(dataSet.circleHoleColor!.cgColor)
                     
                        // The hole rect
                        rect.origin.x = pt.x - circleHoleRadius
                        rect.origin.y = pt.y - circleHoleRadius
                        rect.size.width = circleHoleDiameter
                        rect.size.height = circleHoleDiameter
                        
                        context.fillEllipse(in: rect)
                    }
                }
            }
        }
    }
    
    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let dataProvider = dataProvider,
            let lineData = dataProvider.lineData
            else { return }
        
        let chartXMax = dataProvider.chartXMax
        
        context.saveGState()
        defer { context.restoreGState() }

        for high in indices
        {
            guard
                let set = lineData.getDataSetByIndex(high.dataSetIndex) as? LineChartDataSetProtocol,
                set.isHighlightEnabled,
                let e = set.entryForXValue(high.x, closestToY: high.y),
                isInBoundsX(entry: e, dataSet: set)
                else { continue }

            context.setStrokeColor(set.highlightColor.cgColor)
            context.setLineWidth(set.highlightLineWidth)
            if set.highlightLineDashLengths != nil
            {
                context.setLineDash(phase: set.highlightLineDashPhase, lengths: set.highlightLineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            let x = high.x // get the x-position
            let y = high.y * Double(animator.phaseY)
            
            guard x <= chartXMax * animator.phaseX else { continue }
            
            let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
            
            let pt = trans.pixelForValues(x: x, y: y)
            
            high.setDraw(pt: pt)
            
            // draw the lines
            drawHighlightLines(context: context, point: pt, set: set)
        }
    }
}
