//
//  BubbleChartRenderer.swift
//  Charts
//
//  Bubble chart implementation:
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics
import UIKit

public class BubbleChartRenderer: ChartDataRendererBase
{
    public weak var dataProvider: BubbleChartDataProvider?
    
    public init(dataProvider: BubbleChartDataProvider?, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    public override func drawData(context context: CGContext)
    {
        guard let dataProvider = dataProvider, bubbleData = dataProvider.bubbleData else { return }
        
        for set in bubbleData.dataSets as! [IBubbleChartDataSet]
        {
            if set.isVisible && set.entryCount > 0
            {
                drawDataSet(context: context, dataSet: set)
            }
        }
    }
    
    private func getShapeSize(entrySize entrySize: CGFloat, maxSize: CGFloat, reference: CGFloat) -> CGFloat
    {
        let factor: CGFloat = (maxSize == 0.0) ? 1.0 : sqrt(entrySize / maxSize)
        let shapeSize: CGFloat = reference * factor
        return shapeSize
    }
    
    private var _pointBuffer = CGPoint()
    private var _sizeBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    internal func drawDataSet(context context: CGContext, dataSet: IBubbleChartDataSet)
    {
        guard let dataProvider = dataProvider else { return }
        
        let trans = dataProvider.getTransformer(dataSet.axisDependency)
        
        let phaseX = _animator.phaseX
        let phaseY = _animator.phaseY
        
        let entryCount = dataSet.entryCount
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
        
        CGContextSaveGState(context)
        
        let entryFrom = dataSet.entryForXIndex(_minX)
        let entryTo = dataSet.entryForXIndex(_maxX)
        
        let minx = max(dataSet.entryIndex(entry: entryFrom!), 0)
        let maxx = min(dataSet.entryIndex(entry: entryTo!) + 1, entryCount)
        
        _sizeBuffer[0].x = 0.0
        _sizeBuffer[0].y = 0.0
        _sizeBuffer[1].x = 1.0
        _sizeBuffer[1].y = 0.0
        
        trans.pointValuesToPixel(&_sizeBuffer)
        
        // calcualte the full width of 1 step on the x-axis
        let maxBubbleWidth: CGFloat = abs(_sizeBuffer[1].x - _sizeBuffer[0].x)
        let maxBubbleHeight: CGFloat = abs(viewPortHandler.contentBottom - viewPortHandler.contentTop)
        let referenceSize: CGFloat = min(maxBubbleHeight, maxBubbleWidth)
        
        for (var j = minx; j < maxx; j++)
        {
            guard let entry = dataSet.entryForIndex(j) as? BubbleChartDataEntry else { continue }
            
            _pointBuffer.x = CGFloat(entry.xIndex - minx) * phaseX + CGFloat(minx)
            _pointBuffer.y = CGFloat(entry.value) * phaseY
            _pointBuffer = CGPointApplyAffineTransform(_pointBuffer, valueToPixelMatrix)
            
            let shapeSize = getShapeSize(entrySize: entry.size, maxSize: dataSet.maxSize, reference: referenceSize)
            let shapeHalf = shapeSize / 2.0
            
            if (!viewPortHandler.isInBoundsTop(_pointBuffer.y + shapeHalf)
                || !viewPortHandler.isInBoundsBottom(_pointBuffer.y - shapeHalf))
            {
                continue
            }
            
            if (!viewPortHandler.isInBoundsLeft(_pointBuffer.x + shapeHalf))
            {
                continue
            }
            
            if (!viewPortHandler.isInBoundsRight(_pointBuffer.x - shapeHalf))
            {
                break
            }
            
            let color = dataSet.colorAt(entry.xIndex)
            
            let rect = CGRect(
                x: _pointBuffer.x - shapeHalf,
                y: _pointBuffer.y - shapeHalf,
                width: shapeSize,
                height: shapeSize
            )

            CGContextSetFillColorWithColor(context, color.CGColor)
            CGContextFillEllipseInRect(context, rect)
        }
        
        CGContextRestoreGState(context)
    }
    
    public override func drawValues(context context: CGContext)
    {
        guard let dataProvider = dataProvider, bubbleData = dataProvider.bubbleData else { return }
        
        // if values are drawn
        if (bubbleData.yValCount < Int(ceil(CGFloat(dataProvider.maxVisibleValueCount) * viewPortHandler.scaleX)))
        {
            let dataSets = bubbleData.dataSets as! [IBubbleChartDataSet]
            
            let phaseX = _animator.phaseX
            let phaseY = _animator.phaseY
            
            var pt = CGPoint()
            
            for dataSet in dataSets
            {
                if !dataSet.isDrawValuesEnabled || dataSet.entryCount == 0
                {
                    continue
                }
                
                let alpha = phaseX == 1 ? phaseY : phaseX
                let valueTextColor = dataSet.valueTextColor.colorWithAlphaComponent(alpha)
                
                let formatter = dataSet.valueFormatter
                
                let trans = dataProvider.getTransformer(dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                let entryCount = dataSet.entryCount
                
                let entryFrom = dataSet.entryForXIndex(_minX)
                let entryTo = dataSet.entryForXIndex(_maxX)
                
                let minx = max(dataSet.entryIndex(entry: entryFrom!), 0)
                let maxx = min(dataSet.entryIndex(entry: entryTo!) + 1, entryCount)
                
                for (var j = minx; j < maxx; j++)
                {
                    guard let e = dataSet.entryForIndex(j) as? BubbleChartDataEntry else { break }
                    
                    pt.x = CGFloat(e.xIndex - minx) * phaseX + CGFloat(minx)
                    pt.y = CGFloat(e.value) * phaseY
                    pt = CGPointApplyAffineTransform(pt, valueToPixelMatrix)
                    
                    if (!viewPortHandler.isInBoundsRight(pt.x))
                    {
                        break
                    }
                    
                    if ((!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y)))
                    {
                        continue
                    }
                    
                    let text = formatter!.stringFromNumber(e.size)
                    
                    // Larger font for larger bubbles?
                    let valueFont = dataSet.valueFont
                    let lineHeight = valueFont.lineHeight

                    ChartUtils.drawText(
                        context: context,
                        text: text!,
                        point: CGPoint(
                            x: pt.x,
                            y: pt.y - (0.5 * lineHeight)),
                        align: .Center,
                        attributes: [NSFontAttributeName: valueFont, NSForegroundColorAttributeName: valueTextColor])
                }
            }
        }
    }
    
    public override func drawExtras(context context: CGContext)
    {
        
    }
    
    public override func drawHighlighted(context context: CGContext, indices: [ChartHighlight])
    {
        guard let dataProvider = dataProvider, bubbleData = dataProvider.bubbleData else { return }
        
        CGContextSaveGState(context)
        
        let phaseX = _animator.phaseX
        let phaseY = _animator.phaseY
        
        for indice in indices
        {
            let dataSet = bubbleData.getDataSetByIndex(indice.dataSetIndex) as! IBubbleChartDataSet!
            
            if (dataSet === nil || !dataSet.isHighlightEnabled)
            {
                continue
            }
            
            let entryFrom = dataSet.entryForXIndex(_minX)
            let entryTo = dataSet.entryForXIndex(_maxX)
            
            let minx = max(dataSet.entryIndex(entry: entryFrom!), 0)
            let maxx = min(dataSet.entryIndex(entry: entryTo!) + 1, dataSet.entryCount)
            
            let entry: BubbleChartDataEntry! = bubbleData.getEntryForHighlight(indice) as! BubbleChartDataEntry
            if (entry === nil || entry.xIndex != indice.xIndex)
            {
                continue
            }
            
            let trans = dataProvider.getTransformer(dataSet.axisDependency)
            
            _sizeBuffer[0].x = 0.0
            _sizeBuffer[0].y = 0.0
            _sizeBuffer[1].x = 1.0
            _sizeBuffer[1].y = 0.0
            
            trans.pointValuesToPixel(&_sizeBuffer)
            
            // calcualte the full width of 1 step on the x-axis
            let maxBubbleWidth: CGFloat = abs(_sizeBuffer[1].x - _sizeBuffer[0].x)
            let maxBubbleHeight: CGFloat = abs(viewPortHandler.contentBottom - viewPortHandler.contentTop)
            let referenceSize: CGFloat = min(maxBubbleHeight, maxBubbleWidth)

            _pointBuffer.x = CGFloat(entry.xIndex - minx) * phaseX + CGFloat(minx)
            _pointBuffer.y = CGFloat(entry.value) * phaseY
            trans.pointValueToPixel(&_pointBuffer)
            
            let shapeSize = getShapeSize(entrySize: entry.size, maxSize: dataSet.maxSize, reference: referenceSize)
            let shapeHalf = shapeSize / 2.0
            
            if (!viewPortHandler.isInBoundsTop(_pointBuffer.y + shapeHalf)
                || !viewPortHandler.isInBoundsBottom(_pointBuffer.y - shapeHalf))
            {
                continue
            }
            
            if (!viewPortHandler.isInBoundsLeft(_pointBuffer.x + shapeHalf))
            {
                continue
            }
            
            if (!viewPortHandler.isInBoundsRight(_pointBuffer.x - shapeHalf))
            {
                break
            }
            
            if (indice.xIndex < minx || indice.xIndex >= maxx)
            {
                continue
            }
            
            let originalColor = dataSet.colorAt(entry.xIndex)
            
            var h: CGFloat = 0.0
            var s: CGFloat = 0.0
            var b: CGFloat = 0.0
            var a: CGFloat = 0.0
            
            originalColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            
            let color = UIColor(hue: h, saturation: s, brightness: b * 0.5, alpha: a)
            let rect = CGRect(
                x: _pointBuffer.x - shapeHalf,
                y: _pointBuffer.y - shapeHalf,
                width: shapeSize,
                height: shapeSize)

            CGContextSetLineWidth(context, dataSet.highlightCircleWidth)
            CGContextSetStrokeColorWithColor(context, color.CGColor)
            CGContextStrokeEllipseInRect(context, rect)
        }
        
        CGContextRestoreGState(context)
    }
}