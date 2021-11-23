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
import UIKit

open class LineChartRendererSegmented: LineChartRenderer
{
    private var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    // Calculated based on the color array for the dataset
    // If y Axis has n range (n+1) lables provide n values in color array. Default color will be `defaultLineColor`
    private var rangeColor: [ClosedRange<Double>: UIColor] = [:]
    open var yRangeValues = [Double]()
    open var defaultLineColor: UIColor = .black
    
    @objc open override func drawLinear(context: CGContext, dataSet: LineChartDataSetProtocol)
    {
        
        guard let dataProvider = dataProvider else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        let entryCount = dataSet.entryCount
        
        // This Render doesnot support stepped mode.
        // TODO: To support in future make necessory changes in below code
        dataSet.mode = .linear
                
        let phaseY = animator.phaseY
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        // if drawing filled is enabled
        if dataSet.isDrawFilledEnabled && entryCount > 0
        {
            drawLinearFill(context: context, dataSet: dataSet, trans: trans, bounds: _xBounds)
        }
        
        context.saveGState()
        
        context.setLineCap(dataSet.lineCapType)
        
        let yValues = !yRangeValues.isEmpty ? yRangeValues : dataProvider.getAxis(.left).entries
        
        for (index, color) in dataSet.colors.enumerated() {
            let closedRange = yValues[index]...yValues[index+1]
            rangeColor[closedRange] = color
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
            
            let ys = _lineSegments.map{$0.y}
            let firstY = ys[0]
            let lastY = ys[ys.count - 1]
            
            var intersectionY: [Double] = []
            if firstY < lastY {
                intersectionY = yValues.filter { value in
                    let rangeY = firstY...lastY
                    return rangeY.contains(CGFloat(value))
                }.sorted()
            } else {
                intersectionY = yValues.filter { value in
                    let rangeY = lastY...firstY
                    return rangeY.contains(CGFloat(value))
                }.sorted(by: >)
            }
            
            if !intersectionY.isEmpty {
                var newLineSegments = _lineSegments
                intersectionY.forEach { yIntersect in
                    let firstSegment = newLineSegments[0]
                    let lastSegment = newLineSegments[newLineSegments.count-1]
                    var midX: CGFloat = lastSegment.x
                    
                    // Slope is undefined for vertical line hence x is const
                    if lastSegment.x != firstSegment.x {
                        let slope = (lastSegment.y - firstSegment.y) / (lastSegment.x - firstSegment.x)
                        let yIntercept = lastSegment.y - slope * lastSegment.x
                        midX = (CGFloat(yIntersect) - yIntercept)/slope
                    }
                    let intersectSegment = CGPoint(x: midX, y: yIntersect)
                    let color = self.color(for: firstSegment.y, yEnd: intersectSegment.y).cgColor
                    
                    newLineSegments[1] = intersectSegment
                    for i in 0..<newLineSegments.count
                    {
                        newLineSegments[i] = newLineSegments[i].applying(valueToPixelMatrix)
                    }
                    
                    context.setStrokeColor(color)
                    context.strokeLineSegments(between: newLineSegments)
                    
                    newLineSegments[0] = intersectSegment
                    newLineSegments[1] = lastSegment
                }
                
                let color = self.color(for: newLineSegments[0].y, yEnd: newLineSegments[1].y).cgColor
                for i in 0..<newLineSegments.count
                {
                    newLineSegments[i] = newLineSegments[i].applying(valueToPixelMatrix)
                }
                
                context.setStrokeColor(color)
                context.strokeLineSegments(between: newLineSegments)
            } else {
                var newLineSegments = _lineSegments
                let color = self.color(for: newLineSegments[0].y, yEnd: newLineSegments[1].y).cgColor
                for i in 0..<newLineSegments.count
                {
                    newLineSegments[i] = newLineSegments[i].applying(valueToPixelMatrix)
                }
                
                context.setStrokeColor(color)
                context.strokeLineSegments(between: newLineSegments)
            }
            
        }
        
        context.restoreGState()
    }
    
    private func color(for yStart: CGFloat, yEnd: CGFloat) -> UIColor {
        
        let y = yStart < yEnd ? yStart : yEnd
        
        guard let colorKey = rangeColor.keys.first(where: { y >= $0.lowerBound && y < $0.upperBound })  else {
            return defaultLineColor
        }
        
        return rangeColor[colorKey] ?? defaultLineColor
    }
    
}
#endif
