//
//  BubbleChartRenderer.swift
//  Charts
//
//  Bubble chart implementation:
//    Copyright 2015 Pierre-Marc Airoldi
//    Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif


public class BubbleChartRenderer: BarLineScatterCandleBubbleRenderer
{
    public weak var dataProvider: BubbleChartDataProvider?
    
    public init(dataProvider: BubbleChartDataProvider?, animator: Animator?, viewPortHandler: ViewPortHandler?)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    public override func drawData(context context: CGContext)
    {
        guard let dataProvider = dataProvider, bubbleData = dataProvider.bubbleData else { return }
        
        for set in bubbleData.dataSets as! [IBubbleChartDataSet]
        {
            if set.isVisible
            {
                drawDataSet(context: context, dataSet: set)
            }
        }
    }
    
    private func getShapeSize(
        entrySize entrySize: CGFloat,
                  maxSize: CGFloat,
                  reference: CGFloat,
                  normalizeSize: Bool) -> CGFloat
    {
        let factor: CGFloat = normalizeSize
            ? ((maxSize == 0.0) ? 1.0 : sqrt(entrySize / maxSize))
            : entrySize
        let shapeSize: CGFloat = reference * factor
        return shapeSize
    }
    
    private var _pointBuffer = CGPoint()
    private var _sizeBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public func drawDataSet(context context: CGContext, dataSet: IBubbleChartDataSet)
    {
        guard let
            dataProvider = dataProvider,
            viewPortHandler = self.viewPortHandler,
            animator = animator
            else { return }
        
        let trans = dataProvider.getTransformer(dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
    
        _sizeBuffer[0].x = 0.0
        _sizeBuffer[0].y = 0.0
        _sizeBuffer[1].x = 1.0
        _sizeBuffer[1].y = 0.0
        
        trans.pointValuesToPixel(&_sizeBuffer)
        
        CGContextSaveGState(context)
        
        let normalizeSize = dataSet.isNormalizeSizeEnabled
        
        // calcualte the full width of 1 step on the x-axis
        let maxBubbleWidth: CGFloat = abs(_sizeBuffer[1].x - _sizeBuffer[0].x)
        let maxBubbleHeight: CGFloat = abs(viewPortHandler.contentBottom - viewPortHandler.contentTop)
        let referenceSize: CGFloat = min(maxBubbleHeight, maxBubbleWidth)
        
        for j in _xBounds.min.stride(through: _xBounds.range + _xBounds.min, by: 1)
        {
            guard let entry = dataSet.entryForIndex(j) as? BubbleChartDataEntry else { continue }
            
            _pointBuffer.x = CGFloat(entry.x)
            _pointBuffer.y = CGFloat(entry.y * phaseY)
            _pointBuffer = CGPointApplyAffineTransform(_pointBuffer, valueToPixelMatrix)
            
            let shapeSize = getShapeSize(entrySize: entry.size, maxSize: dataSet.maxSize, reference: referenceSize, normalizeSize: normalizeSize)
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
            
            let color = dataSet.colorAt(Int(entry.x))
            
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
        guard let
            dataProvider = dataProvider,
            viewPortHandler = self.viewPortHandler,
            bubbleData = dataProvider.bubbleData,
            animator = animator
            else { return }
        
        // if values are drawn
        if isDrawingValuesAllowed(dataProvider: dataProvider)
        {
            guard let dataSets = bubbleData.dataSets as? [IBubbleChartDataSet] else { return }
            
            let phaseX = max(0.0, min(1.0, animator.phaseX))
            let phaseY = animator.phaseY
            
            var pt = CGPoint()
            
            for i in 0..<dataSets.count
            {
                let dataSet = dataSets[i]
                
                if !shouldDrawValues(forDataSet: dataSet)
                {
                    continue
                }
                
                let alpha = phaseX == 1 ? phaseY : phaseX
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                _xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
                
                let trans = dataProvider.getTransformer(dataSet.axisDependency)
                let valueToPixelMatrix = trans.valueToPixelMatrix
                
                for j in _xBounds.min.stride(through: _xBounds.range + _xBounds.min, by: 1)
                {
                    guard let e = dataSet.entryForIndex(j) as? BubbleChartDataEntry else { break }
                    
                    let valueTextColor = dataSet.valueTextColorAt(j).colorWithAlphaComponent(CGFloat(alpha))
                    
                    pt.x = CGFloat(e.x)
                    pt.y = CGFloat(e.y * phaseY)
                    pt = CGPointApplyAffineTransform(pt, valueToPixelMatrix)
                    
                    if (!viewPortHandler.isInBoundsRight(pt.x))
                    {
                        break
                    }
                    
                    if ((!viewPortHandler.isInBoundsLeft(pt.x) || !viewPortHandler.isInBoundsY(pt.y)))
                    {
                        continue
                    }
                    
                    let text = formatter.stringForValue(
                        Double(e.size),
                        entry: e,
                        dataSetIndex: i,
                        viewPortHandler: viewPortHandler)
                    
                    // Larger font for larger bubbles?
                    let valueFont = dataSet.valueFont
                    let lineHeight = valueFont.lineHeight

                    ChartUtils.drawText(
                        context: context,
                        text: text,
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
    
    public override func drawHighlighted(context context: CGContext, indices: [Highlight])
    {
        guard let
            dataProvider = dataProvider,
            viewPortHandler = self.viewPortHandler,
            bubbleData = dataProvider.bubbleData,
            animator = animator
            else { return }
        
        CGContextSaveGState(context)
        
        let phaseY = animator.phaseY
        
        for high in indices
        {
            guard let dataSet = bubbleData.getDataSetByIndex(high.dataSetIndex) as? IBubbleChartDataSet
                where dataSet.isHighlightEnabled
                else { continue }
                        
            // In bubble charts - it makes sense to have multiple bubbles on the same X value in the same dataset.
            
            let entries = dataSet.entriesForXValue(high.x)
            
            for entry in entries
            {
                guard let entry = entry as? BubbleChartDataEntry
                    else { continue }
                
                if entry.y != high.y { continue }
                
                if !isInBoundsX(entry: entry, dataSet: dataSet) { continue }
                
                let trans = dataProvider.getTransformer(dataSet.axisDependency)
                
                _sizeBuffer[0].x = 0.0
                _sizeBuffer[0].y = 0.0
                _sizeBuffer[1].x = 1.0
                _sizeBuffer[1].y = 0.0
                
                trans.pointValuesToPixel(&_sizeBuffer)
                
                let normalizeSize = dataSet.isNormalizeSizeEnabled
                
                // calcualte the full width of 1 step on the x-axis
                let maxBubbleWidth: CGFloat = abs(_sizeBuffer[1].x - _sizeBuffer[0].x)
                let maxBubbleHeight: CGFloat = abs(viewPortHandler.contentBottom - viewPortHandler.contentTop)
                let referenceSize: CGFloat = min(maxBubbleHeight, maxBubbleWidth)
                
                _pointBuffer.x = CGFloat(entry.x)
                _pointBuffer.y = CGFloat(entry.y * phaseY)
                trans.pointValueToPixel(&_pointBuffer)
                
                let shapeSize = getShapeSize(entrySize: entry.size, maxSize: dataSet.maxSize, reference: referenceSize, normalizeSize: normalizeSize)
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
                
                let originalColor = dataSet.colorAt(Int(entry.x))
                
                var h: CGFloat = 0.0
                var s: CGFloat = 0.0
                var b: CGFloat = 0.0
                var a: CGFloat = 0.0
                
                originalColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
                
                let color = NSUIColor(hue: h, saturation: s, brightness: b * 0.5, alpha: a)
                let rect = CGRect(
                    x: _pointBuffer.x - shapeHalf,
                    y: _pointBuffer.y - shapeHalf,
                    width: shapeSize,
                    height: shapeSize)
                
                CGContextSetLineWidth(context, dataSet.highlightCircleWidth)
                CGContextSetStrokeColorWithColor(context, color.CGColor)
                CGContextStrokeEllipseInRect(context, rect)
                
                high.setDraw(x: _pointBuffer.x, y: _pointBuffer.y)
            }
        }
        
        CGContextRestoreGState(context)
    }
}