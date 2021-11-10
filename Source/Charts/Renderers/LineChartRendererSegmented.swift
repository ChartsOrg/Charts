//
//  LineChartRendererSegmented.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//
#if canImport(UIKit)
import Foundation
import CoreGraphics

open class LineChartRendererSegmented: LineChartRenderer
{
    private var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    @objc open override func drawLinear(context: CGContext, dataSet: LineChartDataSetProtocol)
    {
        guard let dataProvider = dataProvider else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        let entryCount = dataSet.entryCount
        
        // This Render doesnot support stepped mode.
        // TODO: To support in future make necessory changes in below code
        dataSet.mode = .linear
        
        let pointsPerEntryPair = 2
        
        let phaseY = animator.phaseY
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        // if drawing filled is enabled
        if dataSet.isDrawFilledEnabled && entryCount > 0
        {
            drawLinearFill(context: context, dataSet: dataSet, trans: trans, bounds: _xBounds)
        }
        
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
                    
                    if e == nil {
                        break
                        
                    }
                    
                    _lineSegments[1] = CGPoint(x: CGFloat(e.x), y: CGFloat(e.y * phaseY))
                }
                else
                {
                    _lineSegments[1] = _lineSegments[0]
                }

                var color = dataSet.color(atIndex: j).cgColor
                
                var newLineSegments = _lineSegments
                let yValues = dataProvider.getAxis(.left).entries
                
                let intersectionY = yValues.first { value in
                    let ys = _lineSegments.map{$0.y}
                    let firstY = ys[0]
                    let lastY = ys[ys.count - 1]
                    
                    let rangeY = firstY < lastY ? firstY...lastY : lastY...firstY
                    return rangeY.contains(CGFloat(value))
                }
                
                if let midY = intersectionY {
                    let firstSegment = newLineSegments[0]
                    let lastSegment = newLineSegments[newLineSegments.count-1]
                    
                    var midX: CGFloat = lastSegment.x
                    
                    // Slope is undefined for vertical line hence x is const
                    if lastSegment.x != firstSegment.x {
                        let slope = (lastSegment.y - firstSegment.y) / (lastSegment.x - firstSegment.x)
                        let yIntercept = lastSegment.y - slope * lastSegment.x
                        midX = (CGFloat(midY) - yIntercept)/slope
                    }
                    
                    newLineSegments[0] = firstSegment
                    newLineSegments[1] = CGPoint(x: midX, y: CGFloat(midY))
                    _lineSegments[0] = newLineSegments[1]
                    _lineSegments[1] = lastSegment
                    
                    for i in 0..<newLineSegments.count
                    {
                        newLineSegments[i] = newLineSegments[i].applying(valueToPixelMatrix)
                    }
                    
                    context.setStrokeColor(color)
                    color = dataSet.color(atIndex: j+1).cgColor
                    context.strokeLineSegments(between: newLineSegments)
                }
                
            
            
                _lineSegments = _lineSegments.map { $0.applying(valueToPixelMatrix) }
                
                
                if (!viewPortHandler.isInBoundsRight(_lineSegments[0].x))
                {
                    break
                }
                
                // Determine the start and end coordinates of the line, and make sure they differ.
                guard
                    let firstCoordinate = _lineSegments.first,
                    let lastCoordinate = _lineSegments.last,
                    firstCoordinate != lastCoordinate else { continue }
                
                // make sure the lines don't do shitty things outside bounds
                if !viewPortHandler.isInBoundsLeft(lastCoordinate.x) ||
                    !viewPortHandler.isInBoundsTop(max(firstCoordinate.y, lastCoordinate.y)) ||
                    !viewPortHandler.isInBoundsBottom(min(firstCoordinate.y, lastCoordinate.y))
                {
                    continue
                }
                
                // get the color that is set for this line-segment
                context.setStrokeColor(color)
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
                var firstPoint = true
                
                for x in stride(from: _xBounds.min, through: _xBounds.range + _xBounds.min, by: 1)
                {
                    e1 = dataSet.entryForIndex(x == 0 ? 0 : (x - 1))
                    e2 = dataSet.entryForIndex(x)
                    
                    if e1 == nil || e2 == nil { continue }
                    
                    let pt = CGPoint(
                        x: CGFloat(e1.x),
                        y: CGFloat(e1.y * phaseY)
                        ).applying(valueToPixelMatrix)
                    
                    if firstPoint
                    {
                        context.move(to: pt)
                        firstPoint = false
                    }
                    else
                    {
                        context.addLine(to: pt)
                    }
                    
                    context.addLine(to: CGPoint(
                            x: CGFloat(e2.x),
                            y: CGFloat(e2.y * phaseY)
                        ).applying(valueToPixelMatrix))
                }
                
                if !firstPoint
                {
                    context.setStrokeColor(dataSet.color(atIndex: 0).cgColor)
                    context.strokePath()
                }
            }
        }
        
        context.restoreGState()
    }
}
#endif
