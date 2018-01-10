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


open class BubbleChartRenderer: BarLineScatterCandleBubbleRenderer
{
    @objc open weak var dataProvider: BubbleChartDataProvider?
    
    @objc public init(dataProvider: BubbleChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.dataProvider = dataProvider
    }
    
    open override func drawData(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let bubbleData = dataProvider.bubbleData
            else { return }
        
        for set in bubbleData.dataSets as! [BubbleChartDataSetProtocol] where set.isVisible
        {
            drawDataSet(context: context, dataSet: set)
        }
    }
    
    private func getShapeSize(
        entrySize: CGFloat,
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
    
    private var pointBuffer = CGPoint()
    private var sizeBuffer = [CGPoint](repeating: .zero, count: 2)
    
    @objc open func drawDataSet(context: CGContext, dataSet: BubbleChartDataSetProtocol)
    {
        guard let dataProvider = dataProvider else { return }
        
        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        
        let phaseY = animator.phaseY
        
        xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)
        
        let valueToPixelMatrix = trans.valueToPixelMatrix
    
        sizeBuffer[0].x = 0.0
        sizeBuffer[0].y = 0.0
        sizeBuffer[1].x = 1.0
        sizeBuffer[1].y = 0.0
        
        trans.pointValuesToPixel(&sizeBuffer)
        
        context.saveGState()
        defer { context.restoreGState() }
        
        let normalizeSize = dataSet.isNormalizeSizeEnabled
        
        // calcualte the full width of 1 step on the x-axis
        let maxBubbleWidth = abs(sizeBuffer[1].x - sizeBuffer[0].x)
        let maxBubbleHeight = abs(viewPortHandler.contentBottom - viewPortHandler.contentTop)
        let referenceSize = min(maxBubbleHeight, maxBubbleWidth)
        
        for j in stride(from: xBounds.min, through: xBounds.range + xBounds.min, by: 1)
        {
            guard let entry = dataSet.entryForIndex(j) as? BubbleChartDataEntry else { continue }
            
            pointBuffer.x = CGFloat(entry.x)
            pointBuffer.y = CGFloat(entry.y * phaseY)
            pointBuffer = pointBuffer.applying(valueToPixelMatrix)
            
            let shapeSize = getShapeSize(entrySize: entry.size, maxSize: dataSet.maxSize, reference: referenceSize, normalizeSize: normalizeSize)
            let shapeHalf = shapeSize / 2.0
            
            guard
                viewPortHandler.isInBoundsTop(pointBuffer.y + shapeHalf),
                viewPortHandler.isInBoundsBottom(pointBuffer.y - shapeHalf),
                viewPortHandler.isInBoundsLeft(pointBuffer.x + shapeHalf)
                else { continue }

            guard viewPortHandler.isInBoundsRight(pointBuffer.x - shapeHalf) else { break }
            
            let color = dataSet.color(atIndex: Int(entry.x))
            
            let rect = CGRect(x: pointBuffer.x - shapeHalf,
                              y: pointBuffer.y - shapeHalf,
                              width: shapeSize,
                              height: shapeSize)

            context.setFillColor(color.cgColor)
            context.fillEllipse(in: rect)
        }
    }
    
    open override func drawValues(context: CGContext)
    {
        guard
            let dataProvider = dataProvider,
            let bubbleData = dataProvider.bubbleData,
            isDrawingValuesAllowed(dataProvider: dataProvider),
            let dataSets = bubbleData.dataSets as? [BubbleChartDataSetProtocol]
            else { return }

        let phaseX = max(0.0, min(1.0, animator.phaseX))
        let phaseY = animator.phaseY

        var pt = CGPoint.zero

        for i in 0..<dataSets.count
        {
            let dataSet = dataSets[i]

            guard
                shouldDrawValues(forDataSet: dataSet),
                let formatter = dataSet.valueFormatter
                else { continue }

            let alpha = phaseX == 1 ? phaseY : phaseX

            xBounds.set(chart: dataProvider, dataSet: dataSet, animator: animator)

            let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
            let valueToPixelMatrix = trans.valueToPixelMatrix

            let iconsOffset = dataSet.iconsOffset

            for j in xBounds.min...xBounds.range + xBounds.min
            {
                guard let e = dataSet.entryForIndex(j) as? BubbleChartDataEntry else { break }

                let valueTextColor = dataSet.valueTextColorAt(j).withAlphaComponent(CGFloat(alpha))

                pt.x = CGFloat(e.x)
                pt.y = CGFloat(e.y * phaseY)
                pt = pt.applying(valueToPixelMatrix)

                guard viewPortHandler.isInBoundsRight(pt.x) else { break }

                guard
                    viewPortHandler.isInBoundsLeft(pt.x),
                    viewPortHandler.isInBoundsY(pt.y)
                    else { continue }

                let text = formatter.stringForValue(Double(e.size),
                                                    entry: e,
                                                    dataSetIndex: i,
                                                    viewPortHandler: viewPortHandler)

                // Larger font for larger bubbles?
                let valueFont = dataSet.valueFont
                let lineHeight = valueFont.lineHeight

                if dataSet.isDrawValuesEnabled
                {
                    context.drawText(text,
                                     at: CGPoint(x: pt.x,
                                                    y: pt.y - (0.5 * lineHeight)),
                                     align: .center,
                                     attributes: [.font: valueFont,
                                                  .foregroundColor: valueTextColor])
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
    
    open override func drawExtras(context: CGContext) { }
    
    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let dataProvider = dataProvider,
            let bubbleData = dataProvider.bubbleData
            else { return }

        context.saveGState()
        defer { context.restoreGState() }

        let phaseY = animator.phaseY
        
        for high in indices
        {
            guard
                let dataSet = bubbleData.getDataSetByIndex(high.dataSetIndex) as? BubbleChartDataSetProtocol,
                dataSet.isHighlightEnabled,
                let entry = dataSet.entryForXValue(high.x, closestToY: high.y) as? BubbleChartDataEntry,
                isInBoundsX(entry: entry, dataSet: dataSet)
                else { continue }

            let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
            
            sizeBuffer[0].x = 0.0
            sizeBuffer[0].y = 0.0
            sizeBuffer[1].x = 1.0
            sizeBuffer[1].y = 0.0
            
            trans.pointValuesToPixel(&sizeBuffer)
            
            let normalizeSize = dataSet.isNormalizeSizeEnabled
            
            // calcualte the full width of 1 step on the x-axis
            let maxBubbleWidth = abs(sizeBuffer[1].x - sizeBuffer[0].x)
            let maxBubbleHeight = abs(viewPortHandler.contentBottom - viewPortHandler.contentTop)
            let referenceSize = min(maxBubbleHeight, maxBubbleWidth)
            
            pointBuffer.x = CGFloat(entry.x)
            pointBuffer.y = CGFloat(entry.y * phaseY)
            trans.pointValueToPixel(&pointBuffer)
            
            let shapeSize = getShapeSize(entrySize: entry.size, maxSize: dataSet.maxSize, reference: referenceSize, normalizeSize: normalizeSize)
            let shapeHalf = shapeSize / 2.0
            
            guard
                viewPortHandler.isInBoundsTop(pointBuffer.y + shapeHalf),
                viewPortHandler.isInBoundsBottom(pointBuffer.y - shapeHalf),
                viewPortHandler.isInBoundsLeft(pointBuffer.x + shapeHalf)
                else { continue }

            guard viewPortHandler.isInBoundsRight(pointBuffer.x - shapeHalf) else { break }

            let originalColor = dataSet.color(atIndex: Int(entry.x))
            
            var h: CGFloat = 0.0
            var s: CGFloat = 0.0
            var b: CGFloat = 0.0
            var a: CGFloat = 0.0
            
            originalColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)

            let color = NSUIColor(hue: h, saturation: s, brightness: b * 0.5, alpha: a)
            let rect = CGRect(x: pointBuffer.x - shapeHalf,
                              y: pointBuffer.y - shapeHalf,
                              width: shapeSize,
                              height: shapeSize)
            
            context.setLineWidth(dataSet.highlightCircleWidth)
            context.setStrokeColor(color.cgColor)
            context.strokeEllipse(in: rect)
            
            high.setDraw(x: pointBuffer.x, y: pointBuffer.y)
        }
    }
}
