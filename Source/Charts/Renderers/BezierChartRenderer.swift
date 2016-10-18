//
//  BezierChartRenderer.swift
//  Charts
//
//  Created by Tomas Friml on 19/10/16.
//
//

import UIKit

class BezierChartRenderer: LineChartRenderer {

    open override func drawData(context: CGContext) {
        guard let lineData = dataProvider?.lineData else { return }
        
        for i in 0 ..< lineData.dataSetCount
        {
            guard let set = lineData.getDataSetByIndex(i) else { continue }
            
            if set.isVisible
            {
                if !(set is ILineChartDataSet)
                {
                    fatalError("Datasets for BezierChartRenderer must conform to ILineChartDataSet")
                }
                
                drawCubicBezier(context: context, dataSet: set as! ILineChartDataSet)
            }
        }
        
    }
    
    open override func drawCubicBezier(context: CGContext, dataSet: ILineChartDataSet)
    {
        guard
            let dataProvider = dataProvider,
            let animator = animator
            else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        // get the color that is specified for this position from the DataSet
        let drawingColor = dataSet.colors.first!
        
        // the path for the cubic-spline
        let cubicPath = CGMutablePath()
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        if _xBounds.range >= 1
        {
            let firstIndex = _xBounds.min
            let lastIndex = _xBounds.min + _xBounds.range - 3
            
            
            for j in stride(from: firstIndex, through: lastIndex, by: 1)
            {
                guard let startPoint = dataSet.entryForIndex(j) else { break }
                guard let cp1 = dataSet.entryForIndex(j+1) else { break }
                guard let cp2 = dataSet.entryForIndex(j+2) else { break }
                guard let endPoint = dataSet.entryForIndex(j+3) else { break }
                
                cubicPath.move(to: CGPoint(x: CGFloat(startPoint.x), y: CGFloat(startPoint.y * phaseY)), transform: valueToPixelMatrix)
                
                cubicPath.addCurve(
                    to: CGPoint(
                        x: CGFloat(endPoint.x),
                        y: CGFloat(endPoint.y) * CGFloat(phaseY)),
                    control1: CGPoint(
                        x: CGFloat(cp1.x),
                        y: CGFloat(cp1.y) * CGFloat(phaseY)),
                    control2: CGPoint(
                        x: CGFloat(cp2.x),
                        y: CGFloat(cp2.y) * CGFloat(phaseY)),
                    transform: valueToPixelMatrix)
            }
        }
        
        context.saveGState()
        
        if dataSet.isDrawFilledEnabled
        {
            // Copy this path because we make changes to it
            let fillPath = cubicPath.mutableCopy()
            
            drawCubicFill(context: context, dataSet: dataSet, spline: fillPath!, matrix: valueToPixelMatrix, bounds: _xBounds)
        }
        
        context.beginPath()
        context.addPath(cubicPath)
        context.setStrokeColor(drawingColor.cgColor)
        context.strokePath()
        
        context.restoreGState()
    }
}
