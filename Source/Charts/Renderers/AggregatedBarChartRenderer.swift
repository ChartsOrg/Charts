//
//  AggregatedBarChartRenderer.swift
//  Charts
//
//  Created by Maxim Komlev on 5/4/17.
//
//

import Foundation
import CoreGraphics

#if !os(OSX)
    import UIKit
#endif


// TODO: handle multiple datasets

open class AggregatedBarChartRenderer: BarChartRenderer
{
    internal class GroupRect
    {
        // data of assotiated dataset and dataentry
        var dataIndexOfTopEntry: Int = 0
        var dataSetIndex: Int = 0

        var rect: CGRect!
        var color: NSUIColor!
        
        convenience init(dataSetIndex: Int, rect: CGRect) {
            self.init(rect: rect)
            
            self.dataSetIndex = dataSetIndex
        }

        init(rect: CGRect) {
            self.rect = rect
        }
    }
    internal var groupRects: Array<GroupRect> = Array()
    
    open override func initBuffers()
    {
        if let barData = dataProvider?.barData
        {
            // Matche buffers count to dataset count
            if _buffers.count != barData.dataSetCount
            {
                while _buffers.count < barData.dataSetCount
                {
                    _buffers.append(Buffer())
                }
                while _buffers.count > barData.dataSetCount
                {
                    _buffers.removeLast()
                }
            }
            
            for i in stride(from: 0, to: barData.dataSetCount, by: 1)
            {
                let set = barData.dataSets[i] as! IBarChartDataSet
                let size = set.entryCount
                if _buffers[i].rects.count != size
                {
                    _buffers[i].rects = [CGRect](repeating: CGRect(), count: size)
                }
            }
        }
        else
        {
            _buffers.removeAll()
        }
    }
    
    internal override func prepareBuffer(dataSet: IBarChartDataSet, index: Int)
    {
        guard
            let dataProvider = dataProvider,
            let barData = dataProvider.barData,
            let animator = animator
            else { return }
        
        let barWidthHalf = barData.barWidth / 2.0
        
        let buffer = _buffers[index]
        var bufferIndex = 0
        
        let isInverted = dataProvider.isInverted(axis: dataSet.axisDependency)
        let phaseY = animator.phaseY
        var barRect = CGRect()
        var x: Double
        var y: Double
        
        for i in stride(from: 0, to: min(Int(ceil(Double(dataSet.entryCount) * animator.phaseX)), dataSet.entryCount), by: 1)
        {
            guard let e = dataSet.entryForIndex(i) as? BarChartDataEntry else { continue }
            
            x = e.x
            y = e.y
            
            let left = CGFloat(x - barWidthHalf)
            let right = CGFloat(x + barWidthHalf)
            var top = isInverted
                ? (y <= 0.0 ? CGFloat(y) : 0)
                : (y >= 0.0 ? CGFloat(y) : 0)
            var bottom = isInverted
                ? (y >= 0.0 ? CGFloat(y) : 0)
                : (y <= 0.0 ? CGFloat(y) : 0)
            
            // multiply the height of the rect with the phase
            if top > 0
            {
                top *= CGFloat(phaseY)
            }
            else
            {
                bottom *= CGFloat(phaseY)
            }
            
            barRect.origin.x = left
            barRect.size.width = right - left
            barRect.origin.y = top
            barRect.size.height = bottom - top
            
            buffer.rects[bufferIndex] = barRect
            bufferIndex += 1
        }
    }
    
    open override func drawDataSet(context: CGContext, dataSet: IBarChartDataSet, index: Int)
    {
        guard
            let dp: AggregatedBarChartDataProvider = dataProvider as? AggregatedBarChartDataProvider,
            let viewPortHandler = self.viewPortHandler
            else { return }
        
        let trans = dp.getTransformer(forAxis: dataSet.axisDependency)
        
        prepareBuffer(dataSet: dataSet, index: index)
        trans.rectValuesToPixel(&_buffers[index].rects)
        
        let borderWidth = dataSet.barBorderWidth
        let borderColor = dataSet.barBorderColor
        let drawBorder = borderWidth > 0.0
        
        context.saveGState()
        
        let buffer = _buffers[index]
        for j in stride(from: 0, to: buffer.rects.count, by: 1) {
            buffer.rects[j].origin.x = buffer.rects[j].origin.x + (buffer.rects[j].size.width - dp.groupWidth) / 2
            buffer.rects[j].size.width = dp.groupWidth
        }
        
        let margin: CGFloat = dp.groupMargin + dp.groupWidth
        
        groupRects.removeAll()
        
        var maxHeight: CGFloat = 0
        
        for j in stride(from: 0, to: buffer.rects.count, by: 1) {
            let currentRect = GroupRect(dataSetIndex: index, rect: buffer.rects[j])
            currentRect.rect.size.width = CGFloat(dp.groupWidth)
            currentRect.dataIndexOfTopEntry = j
            currentRect.color = dataSet.color(atIndex: j)
            
            if groupRects.count == 0 {
                groupRects.append(currentRect)
            } else {
                let lastRect = groupRects.last!
                
                if (currentRect.rect.origin.x > lastRect.rect.origin.x + margin) {
                    groupRects.append(currentRect)
                    maxHeight = 0
                } else {
                    if currentRect.rect.size.height > maxHeight {
                        maxHeight = currentRect.rect.size.height
                        
                        groupRects.removeLast()
                        lastRect.dataIndexOfTopEntry = j
                        lastRect.rect.origin.y = currentRect.rect.origin.y
                        lastRect.rect.size.height = maxHeight
                        lastRect.rect.size.width = CGFloat(dp.groupWidth)
                        lastRect.color = dataSet.color(atIndex: j)
                        groupRects.append(lastRect)
                    }
                }
            }
        }
        
        // draw the bar shadow before the values
        if dp.isDrawBarShadowEnabled
        {
            for j in stride(from: 0, to: groupRects.count, by: 1)
            {
                let barRect = groupRects[j].rect
                
                if (!viewPortHandler.isInBoundsLeft((barRect?.origin.x)! + (barRect?.size.width)!))
                {
                    continue
                }
                
                if (!viewPortHandler.isInBoundsRight((barRect?.origin.x)!))
                {
                    break
                }
                
                context.setFillColor(dataSet.barShadowColor.cgColor)
                context.fill(barRect!)
            }
        }
        
        let isSingleColor = dataSet.colors.count == 1
        
        if isSingleColor
        {
            context.setFillColor(dataSet.color(atIndex: 0).cgColor)
        }
        
        for j in stride(from: 0, to: groupRects.count, by: 1)
        {
            let group = groupRects[j]
            
            if (!viewPortHandler.isInBoundsLeft(group.rect.origin.x + group.rect.size.width))
            {
                continue
            }
            
            if (!viewPortHandler.isInBoundsRight(group.rect.origin.x))
            {
                break
            }
            
            if !isSingleColor
            {
                // Set the color for the currently drawn value. If the index is out of bounds, reuse colors.
                context.setFillColor(group.color.cgColor)
            }
            
            context.fill(group.rect)
            
            if drawBorder
            {
                context.setStrokeColor(borderColor.cgColor)
                context.setLineWidth(borderWidth)
                context.stroke(group.rect)
            }
        }
        
        context.restoreGState()
    }
    
    open override func drawValues(context: CGContext)
    {
        // if values are drawn
        if isDrawingValuesAllowed(dataProvider: dataProvider)
        {
            guard
                let dataProvider = dataProvider,
                let viewPortHandler = self.viewPortHandler,
                let barData = dataProvider.barData,
                let animator = animator
                else { return }
            
            var dataSets = barData.dataSets
            
            let valueOffsetPlus: CGFloat = 4.5
            var posOffset: CGFloat
            var negOffset: CGFloat
            let drawValueAboveBar = dataProvider.isDrawValueAboveBarEnabled
            
            for j in stride(from: 0, to: groupRects.count, by: 1) {
                let group = groupRects[j]
                
                guard let dataSet = dataSets[group.dataSetIndex] as? IBarChartDataSet else { continue }
                
                if !shouldDrawValues(forDataSet: dataSet)
                {
                    continue
                }
                
                // calculate the correct offset depending on the draw position of the value
                let valueFont = dataSet.valueFont
                let valueTextHeight = valueFont.lineHeight
                posOffset = (drawValueAboveBar ? -(valueTextHeight + valueOffsetPlus) : valueOffsetPlus)
                negOffset = (drawValueAboveBar ? valueOffsetPlus : -(valueTextHeight + valueOffsetPlus))
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                let iconsOffset = dataSet.iconsOffset
                
                // if only single values are drawn (sum)
                for j in 0 ..< Int(ceil(Double(dataSet.entryCount) * animator.phaseX))
                {
                    guard let e = dataSet.entryForIndex(group.dataIndexOfTopEntry) as? BarChartDataEntry else { continue }
                    
                    let rect = group.rect
                    
                    let x = (rect?.origin.x)! + (rect?.size.width)! / 2.0
                    
                    if !viewPortHandler.isInBoundsRight(x)
                        || !viewPortHandler.isInBoundsLeft(x)
                    {
                        break
                    }
                                        
                    if dataSet.isDrawValuesEnabled
                    {
                        drawValue(
                            context: context,
                            value: formatter.stringForValue(
                                e.y,
                                entry: e,
                                dataSetIndex: group.dataSetIndex,
                                viewPortHandler: viewPortHandler),
                            xPos: x,
                            yPos: (rect?.origin.y)! >= CGFloat(0)
                                ? ((rect?.origin.y)! + posOffset)
                                : ((rect?.origin.y)! + (rect?.size.height)! + negOffset),
                            font: valueFont,
                            align: .center,
                            color: dataSet.valueTextColorAt(j))
                    }
                    
                    if let icon = e.icon, dataSet.isDrawIconsEnabled
                    {
                        var px = x
                        var py = (rect?.origin.y)! >= CGFloat(0)
                            ? ((rect?.origin.y)! + posOffset)
                            : ((rect?.origin.y)! + (rect?.size.height)! + negOffset)
                        
                        px += iconsOffset.x
                        py += iconsOffset.y
                        
                        ChartUtils.drawImage(
                            context: context,
                            image: icon,
                            x: px,
                            y: py,
                            size: icon.size)
                    }
                }
            }
        }
    }
    
    /// Draws a value at the specified x and y position.
    open override func drawValue(context: CGContext, value: String, xPos: CGFloat, yPos: CGFloat, font: NSUIFont, align: NSTextAlignment, color: NSUIColor)
    {
        ChartUtils.drawText(context: context, text: value, point: CGPoint(x: xPos, y: yPos), align: align, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: color])
    }

    open override func isDrawingValuesAllowed(dataProvider: ChartDataProvider?) -> Bool
    {
        return true
    }

    open override func drawExtras(context: CGContext)
    {
        
    }
    
    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let dataProvider = dataProvider,
            let barData = dataProvider.barData
            else { return }
        
        context.saveGState()
        
        for high in indices
        {
            let idx = findBarForPoint(x: high.xPx)
            if (idx > -1) {
                let groupRects:GroupRect = self.groupRects[idx]
                let barRect: CGRect = groupRects.rect
                
                guard
                    let set = barData.getDataSetByIndex(0) as? IBarChartDataSet,
                    set.isHighlightEnabled
                    else { return }

                //                self.drawHighlightTarget(context: context, point: CGPoint(x: self.groupedRects[idx].rect.origin.x + CGFloat(barData.barWidth) / 2, y: pt.y), coreColor: self.groupedRects[idx].color)
                setHighlightDrawPos(highlight: high, barRect: barRect)
                context.setFillColor(set.highlightColor.cgColor)
                context.setAlpha(set.highlightAlpha)
                context.fill(barRect)
            }
        }
        
        context.restoreGState()
    }
    
    public func findDataEntryAt(x:CGFloat, y:CGFloat) -> (dataSetIndex: Int, dataEntryIndex: Int)? {
        
        let idx = findBarForPoint(x: x)
        if (idx > -1) {
            let groupRects:GroupRect = self.groupRects[idx]
            
            return (dataSetIndex: groupRects.dataSetIndex, dataEntryIndex: groupRects.dataIndexOfTopEntry)
        }
        
        return nil
    }
    
    /// find index of aggregated bars by coordinate
    internal func findBarForPoint(x: CGFloat) -> Int {
        
        var left: Int = 0
        var right: Int = self.groupRects.count - 1
        
        while (left <= right) {
            
            let idx: Int = left + ((right - left) / 2)
            let rect: CGRect? = self.groupRects[idx].rect
            
            if (x > (rect?.origin.x)!) {
                left = idx + 1
            } else if (x < (rect?.origin.x)!) {
                right = idx - 1
            } else if (x == (rect?.origin.x)) {
                return idx
            }
        }
        return left > right ? right : left
    }
    
    /// Sets the drawing position of the highlight object based on the riven bar-rect.
    internal override func setHighlightDrawPos(highlight high: Highlight, barRect: CGRect)
    {
        high.setDraw(x: barRect.midX, y: barRect.origin.y)
    }
}
