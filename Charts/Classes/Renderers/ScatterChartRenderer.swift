//
//  ScatterChartRenderer.swift
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


public class ScatterChartRenderer: LineScatterCandleRadarChartRenderer
{
    public weak var dataProvider: ScatterChartDataProvider?
    
    public init(dataProvider: ScatterChartDataProvider?, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    public override func drawData(context context: CGContext)
    {
        guard let scatterData = dataProvider?.scatterData else { return }
        
        for i in 0 ..< scatterData.dataSetCount
        {
            guard let set = scatterData.getDataSetByIndex(i) else { continue }
            
            if set.isVisible
            {
                if !(set is IScatterChartDataSet)
                {
                    fatalError("Datasets for ScatterChartRenderer must conform to IScatterChartDataSet")
                }
                
                drawDataSet(context: context, dataSet: set as! IScatterChartDataSet)
            }
        }
    }
    
    private var _lineSegments = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public func drawDataSet(context context: CGContext, dataSet: IScatterChartDataSet)
    {
        guard let
            dataProvider = dataProvider,
            animator = animator
            else { return }
        
        let trans = dataProvider.getTransformer(dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        let entryCount = dataSet.entryCount
        
        let shapeSize = dataSet.scatterShapeSize
        let shapeHalf = shapeSize / 2.0
        let shapeHoleSizeHalf = dataSet.scatterShapeHoleRadius
        let shapeHoleSize = shapeHoleSizeHalf * 2.0
        let shapeHoleColor = dataSet.scatterShapeHoleColor
        let shapeStrokeSize = (shapeSize - shapeHoleSize) / 2.0
        let shapeStrokeSizeHalf = shapeStrokeSize / 2.0
        
        var point = CGPoint()
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        let shape = dataSet.scatterShape
        
        CGContextSaveGState(context)
        
        for j in 0 ..< Int(min(ceil(CGFloat(entryCount) * animator.phaseX), CGFloat(entryCount)))
        {
            guard let e = dataSet.entryForIndex(j) else { continue }
            
            point.x = CGFloat(e.xIndex)
            point.y = CGFloat(e.value) * phaseY
            point = CGPointApplyAffineTransform(point, valueToPixelMatrix);            
            
            if (!viewPortHandler.isInBoundsRight(point.x))
            {
                break
            }
            
            if (!viewPortHandler.isInBoundsLeft(point.x) || !viewPortHandler.isInBoundsY(point.y))
            {
                continue
            }
            
            if (shape == .Square)
            {
                if shapeHoleSize > 0.0
                {
                    CGContextSetStrokeColorWithColor(context, dataSet.colorAt(j).CGColor)
                    CGContextSetLineWidth(context, shapeStrokeSize)
                    var rect = CGRect()
                    rect.origin.x = point.x - shapeHoleSizeHalf - shapeStrokeSizeHalf
                    rect.origin.y = point.y - shapeHoleSizeHalf - shapeStrokeSizeHalf
                    rect.size.width = shapeHoleSize + shapeStrokeSize
                    rect.size.height = shapeHoleSize + shapeStrokeSize
                    CGContextStrokeRect(context, rect)
                    
                    if let shapeHoleColor = shapeHoleColor
                    {
                        CGContextSetFillColorWithColor(context, shapeHoleColor.CGColor)
                        rect.origin.x = point.x - shapeHoleSizeHalf
                        rect.origin.y = point.y - shapeHoleSizeHalf
                        rect.size.width = shapeHoleSize
                        rect.size.height = shapeHoleSize
                        CGContextFillRect(context, rect)
                    }
                }
                else
                {
                    CGContextSetFillColorWithColor(context, dataSet.colorAt(j).CGColor)
                    var rect = CGRect()
                    rect.origin.x = point.x - shapeHalf
                    rect.origin.y = point.y - shapeHalf
                    rect.size.width = shapeSize
                    rect.size.height = shapeSize
                    CGContextFillRect(context, rect)
                }
            }
            else if (shape == .Circle)
            {
                if shapeHoleSize > 0.0
                {
                    CGContextSetStrokeColorWithColor(context, dataSet.colorAt(j).CGColor)
                    CGContextSetLineWidth(context, shapeStrokeSize)
                    var rect = CGRect()
                    rect.origin.x = point.x - shapeHoleSizeHalf - shapeStrokeSizeHalf
                    rect.origin.y = point.y - shapeHoleSizeHalf - shapeStrokeSizeHalf
                    rect.size.width = shapeHoleSize + shapeStrokeSize
                    rect.size.height = shapeHoleSize + shapeStrokeSize
                    CGContextStrokeEllipseInRect(context, rect)
                    
                    if let shapeHoleColor = shapeHoleColor
                    {
                        CGContextSetFillColorWithColor(context, shapeHoleColor.CGColor)
                        rect.origin.x = point.x - shapeHoleSizeHalf
                        rect.origin.y = point.y - shapeHoleSizeHalf
                        rect.size.width = shapeHoleSize
                        rect.size.height = shapeHoleSize
                        CGContextFillEllipseInRect(context, rect)
                    }
                }
                else
                {
                    CGContextSetFillColorWithColor(context, dataSet.colorAt(j).CGColor)
                    var rect = CGRect()
                    rect.origin.x = point.x - shapeHalf
                    rect.origin.y = point.y - shapeHalf
                    rect.size.width = shapeSize
                    rect.size.height = shapeSize
                    CGContextFillEllipseInRect(context, rect)
                }
            }
            else if (shape == .Triangle)
            {
                CGContextSetFillColorWithColor(context, dataSet.colorAt(j).CGColor)
                
                // create a triangle path
                CGContextBeginPath(context)
                CGContextMoveToPoint(context, point.x, point.y - shapeHalf)
                CGContextAddLineToPoint(context, point.x + shapeHalf, point.y + shapeHalf)
                CGContextAddLineToPoint(context, point.x - shapeHalf, point.y + shapeHalf)
                
                if shapeHoleSize > 0.0
                {
                    CGContextAddLineToPoint(context, point.x, point.y - shapeHalf)
                    
                    CGContextMoveToPoint(context, point.x - shapeHalf + shapeStrokeSize, point.y + shapeHalf - shapeStrokeSize)
                    CGContextAddLineToPoint(context, point.x + shapeHalf - shapeStrokeSize, point.y + shapeHalf - shapeStrokeSize)
                    CGContextAddLineToPoint(context, point.x, point.y - shapeHalf + shapeStrokeSize)
                    CGContextAddLineToPoint(context, point.x - shapeHalf + shapeStrokeSize, point.y + shapeHalf - shapeStrokeSize)
                }
                
                CGContextClosePath(context)
                
                CGContextFillPath(context)
                
                if shapeHoleSize > 0.0 && shapeHoleColor != nil
                {
                    CGContextSetFillColorWithColor(context, shapeHoleColor!.CGColor)
                    
                    // create a triangle path
                    CGContextBeginPath(context)
                    CGContextMoveToPoint(context, point.x, point.y - shapeHalf + shapeStrokeSize)
                    CGContextAddLineToPoint(context, point.x + shapeHalf - shapeStrokeSize, point.y + shapeHalf - shapeStrokeSize)
                    CGContextAddLineToPoint(context, point.x - shapeHalf + shapeStrokeSize, point.y + shapeHalf - shapeStrokeSize)
                    CGContextClosePath(context)
                    
                    CGContextFillPath(context)
                }
            }
            else if (shape == .Cross)
            {
                CGContextSetStrokeColorWithColor(context, dataSet.colorAt(j).CGColor)
                _lineSegments[0].x = point.x - shapeHalf
                _lineSegments[0].y = point.y
                _lineSegments[1].x = point.x + shapeHalf
                _lineSegments[1].y = point.y
                CGContextStrokeLineSegments(context, _lineSegments, 2)
                
                _lineSegments[0].x = point.x
                _lineSegments[0].y = point.y - shapeHalf
                _lineSegments[1].x = point.x
                _lineSegments[1].y = point.y + shapeHalf
                CGContextStrokeLineSegments(context, _lineSegments, 2)
            }
            else if (shape == .X)
            {
                CGContextSetStrokeColorWithColor(context, dataSet.colorAt(j).CGColor)
                _lineSegments[0].x = point.x - shapeHalf
                _lineSegments[0].y = point.y - shapeHalf
                _lineSegments[1].x = point.x + shapeHalf
                _lineSegments[1].y = point.y + shapeHalf
                CGContextStrokeLineSegments(context, _lineSegments, 2)
                
                _lineSegments[0].x = point.x + shapeHalf
                _lineSegments[0].y = point.y - shapeHalf
                _lineSegments[1].x = point.x - shapeHalf
                _lineSegments[1].y = point.y + shapeHalf
                CGContextStrokeLineSegments(context, _lineSegments, 2)
            }
            else if (shape == .Custom)
            {
                CGContextSetFillColorWithColor(context, dataSet.colorAt(j).CGColor)
                
                let customShape = dataSet.customScatterShape
                
                if customShape == nil
                {
                    return
                }
                
                // transform the provided custom path
                CGContextSaveGState(context)
                CGContextTranslateCTM(context, point.x, point.y)
                
                CGContextBeginPath(context)
                CGContextAddPath(context, customShape!)
                CGContextFillPath(context)
                
                CGContextRestoreGState(context)
            }
        }
        
        CGContextRestoreGState(context)
    }
    
    public override func drawValues(context context: CGContext)
    {
        guard let
            dataProvider = dataProvider,
            scatterData = dataProvider.scatterData,
            animator = animator
            else { return }
        
        // if values are drawn
        if (scatterData.yValCount < Int(ceil(CGFloat(dataProvider.maxVisibleValueCount) * viewPortHandler.scaleX)))
        {
            guard let dataSets = scatterData.dataSets as? [IScatterChartDataSet] else { return }
            
            let phaseX = max(0.0, min(1.0, animator.phaseX))
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for i in 0 ..< scatterData.dataSetCount
            {
                let dataSet = dataSets[i]
                
                if !dataSet.isDrawValuesEnabled || dataSet.entryCount == 0
                {
                    continue
                }
                
                let valueFont = dataSet.valueFont
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                let trans = dataProvider.getTransformer(dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                let entryCount = dataSet.entryCount
                
                let shapeSize = dataSet.scatterShapeSize
                let lineHeight = valueFont.lineHeight
                
                for j in 0 ..< Int(ceil(CGFloat(entryCount) * phaseX))
                {
                    guard let e = dataSet.entryForIndex(j) else { break }
                    
                    pt.x = CGFloat(e.xIndex)
                    pt.y = CGFloat(e.value) * phaseY
                    pt = CGPointApplyAffineTransform(pt, valueToPixelMatrix)
                    
                    if (!viewPortHandler.isInBoundsRight(pt.x))
                    {
                        break
                    }
                    
                    // make sure the lines don't do shitty things outside bounds
                    if ((!viewPortHandler.isInBoundsLeft(pt.x)
                        || !viewPortHandler.isInBoundsY(pt.y)))
                    {
                        continue
                    }
                    
                    let text = formatter.stringFromNumber(e.value)
                    
                    ChartUtils.drawText(
                        context: context,
                        text: text!,
                        point: CGPoint(
                            x: pt.x,
                            y: pt.y - shapeSize - lineHeight),
                        align: .Center,
                        attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)]
                    )
                }
            }
        }
    }
    
    public override func drawExtras(context context: CGContext)
    {
        
    }
    
    private var _highlightPointBuffer = CGPoint()
    
    public override func drawHighlighted(context context: CGContext, indices: [ChartHighlight])
    {
        guard let
            dataProvider = dataProvider,
            scatterData = dataProvider.scatterData,
            animator = animator
            else { return }
        
        let chartXMax = dataProvider.chartXMax
        
        CGContextSaveGState(context)
        
        for high in indices
        {
            let minDataSetIndex = high.dataSetIndex == -1 ? 0 : high.dataSetIndex
            let maxDataSetIndex = high.dataSetIndex == -1 ? scatterData.dataSetCount : (high.dataSetIndex + 1)
            if maxDataSetIndex - minDataSetIndex < 1 { continue }
            
            for dataSetIndex in minDataSetIndex..<maxDataSetIndex
            {
                guard let set = scatterData.getDataSetByIndex(dataSetIndex) as? IScatterChartDataSet else { continue }
                
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
                
                let yVal = set.yValForXIndex(xIndex)
                if (yVal.isNaN)
                {
                    continue
                }
                
                let y = CGFloat(yVal) * animator.phaseY; // get the y-position
                
                _highlightPointBuffer.x = CGFloat(xIndex)
                _highlightPointBuffer.y = y
                
                let trans = dataProvider.getTransformer(set.axisDependency)
                
                trans.pointValueToPixel(&_highlightPointBuffer)
                
                // draw the lines
                drawHighlightLines(context: context, point: _highlightPointBuffer, set: set)
            }
        }
        
        CGContextRestoreGState(context)
    }
}
