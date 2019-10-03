//
//  CustomCombinedChartBarForFatigueRenderer.swift
//  Charts
//
//  Created by Oussema Ayed on 8/23/19.
//


import Foundation
/// custom Combined Chart Bar For Fatigue Renderer
public class CustomCombinedChartBarForFatigueRenderer : BarChartRenderer {
    
    
    let gradientColor = [
        UIColor(red:0.12, green:0.7, blue:0.16, alpha:1).withAlphaComponent(0.3).cgColor,
        UIColor(red:0.42, green:0.63, blue:0.16, alpha:1).withAlphaComponent(0.3).cgColor,
        UIColor(red:0.93, green:0.5, blue:0.15, alpha:1).withAlphaComponent(0.3).cgColor,
        UIColor(red:0.93, green:0.5, blue:0.15, alpha:1).withAlphaComponent(0.3).cgColor,
        UIColor(red:0.93, green:0.27, blue:0.25, alpha:1).withAlphaComponent(0.3).cgColor
    ]
    var barColors = [CGColor]()
    
    fileprivate var _barShadowRectBuffer: CGRect = CGRect()
    fileprivate var _buffers = [Buffer]()
    fileprivate class Buffer
    {
        var rects = [CGRect]()
    }
    
    public override init(dataProvider: BarChartDataProvider, animator: Animator, viewPortHandler: ViewPortHandler) {
        super.init(dataProvider: dataProvider, animator: animator, viewPortHandler: viewPortHandler)
    }
    private func prepareBuffer(dataSet: IBarChartDataSet, index: Int)
    {
        guard
            let dataProvider = dataProvider,
            let barData = dataProvider.barData
            else { return }
        
        let barWidthHalf = barData.barWidth / 2.0
        
        let buffer = _buffers[index]
        var bufferIndex = 0
        let containsStacks = dataSet.isStacked
        
        let isInverted = dataProvider.isInverted(axis: dataSet.axisDependency)
        let phaseY = animator.phaseY
        var barRect = CGRect()
        var x: Double
        var y: Double
        
        
        for i in stride(from: 0, to: min(Int(ceil(Double(dataSet.entryCount) * animator.phaseX)), dataSet.entryCount), by: 1)
        {
            guard let e = dataSet.entryForIndex(i) as? BarChartDataEntry else { continue }
            
            let vals = e.yValues
            
            x = e.x
            y = e.y
            
            if !containsStacks || vals == nil
            {
                let left = CGFloat(x - barWidthHalf)
                let right = CGFloat(x + barWidthHalf)
                var top = isInverted
                    ? (y <= 0.0 ? CGFloat(y) : 0)
                    : (y >= 0.0 ? CGFloat(y) : 0)
                var bottom = isInverted
                    ? (y >= 0.0 ? CGFloat(y) : 0)
                    : (y <= 0.0 ? CGFloat(y) : 0)
                
                /* When drawing each bar, the renderer actually draws each bar from 0 to the required value.
                 * This drawn bar is then clipped to the visible chart rect in BarLineChartViewBase's draw(rect:) using clipDataToContent.
                 * While this works fine when calculating the bar rects for drawing, it causes the accessibilityFrames to be oversized in some cases.
                 * This offset attempts to undo that unnecessary drawing when calculating barRects
                 *
                 * +---------------------------------------------------------------+---------------------------------------------------------------+
                 * |      Situation 1:  (!inverted && y >= 0)                      |      Situation 3:  (inverted && y >= 0)                       |
                 * |                                                               |                                                               |
                 * |        y ->           +--+       <- top                       |        0 -> ---+--+---+--+------   <- top                     |
                 * |                       |//|        } topOffset = y - max       |                |  |   |//|          } topOffset = min         |
                 * |      max -> +---------+--+----+  <- top - topOffset           |      min -> +--+--+---+--+----+    <- top + topOffset         |
                 * |             |  +--+   |//|    |                               |             |  |  |   |//|    |                               |
                 * |             |  |  |   |//|    |                               |             |  +--+   |//|    |                               |
                 * |             |  |  |   |//|    |                               |             |         |//|    |                               |
                 * |      min -> +--+--+---+--+----+  <- bottom + bottomOffset     |      max -> +---------+--+----+    <- bottom - bottomOffset   |
                 * |                |  |   |//|        } bottomOffset = min        |                       |//|          } bottomOffset = y - max  |
                 * |        0 -> ---+--+---+--+-----  <- bottom                    |        y ->           +--+         <- bottom                  |
                 * |                                                               |                                                               |
                 * +---------------------------------------------------------------+---------------------------------------------------------------+
                 * |      Situation 2:  (!inverted && y < 0)                       |      Situation 4:  (inverted && y < 0)                        |
                 * |                                                               |                                                               |
                 * |        0 -> ---+--+---+--+-----   <- top                      |        y ->           +--+         <- top                     |
                 * |                |  |   |//|         } topOffset = -max         |                       |//|          } topOffset = min - y     |
                 * |      max -> +--+--+---+--+----+   <- top - topOffset          |      min -> +---------+--+----+    <- top + topOffset         |
                 * |             |  |  |   |//|    |                               |             |  +--+   |//|    |                               |
                 * |             |  +--+   |//|    |                               |             |  |  |   |//|    |                               |
                 * |             |         |//|    |                               |             |  |  |   |//|    |                               |
                 * |      min -> +---------+--+----+   <- bottom + bottomOffset    |      max -> +--+--+---+--+----+    <- bottom - bottomOffset   |
                 * |                       |//|         } bottomOffset = min - y   |                |  |   |//|          } bottomOffset = -max     |
                 * |        y ->           +--+        <- bottom                   |        0 -> ---+--+---+--+-------  <- bottom                  |
                 * |                                                               |                                                               |
                 * +---------------------------------------------------------------+---------------------------------------------------------------+
                 */
                var topOffset: CGFloat = 0.0
                var bottomOffset: CGFloat = 0.0
                if let offsetView = dataProvider as? BarChartView
                {
                    let offsetAxis = offsetView.getAxis(dataSet.axisDependency)
                    if y >= 0
                    {
                        // situation 1
                        if offsetAxis.axisMaximum < y
                        {
                            topOffset = CGFloat(y - offsetAxis.axisMaximum)
                        }
                        if offsetAxis.axisMinimum > 0
                        {
                            bottomOffset = CGFloat(offsetAxis.axisMinimum)
                        }
                    }
                    else // y < 0
                    {
                        //situation 2
                        if offsetAxis.axisMaximum < 0
                        {
                            topOffset = CGFloat(offsetAxis.axisMaximum * -1)
                        }
                        if offsetAxis.axisMinimum > y
                        {
                            bottomOffset = CGFloat(offsetAxis.axisMinimum - y)
                        }
                    }
                    if isInverted
                    {
                        // situation 3 and 4
                        // exchange topOffset/bottomOffset based on 1 and 2
                        // see diagram above
                        (topOffset, bottomOffset) = (bottomOffset, topOffset)
                    }
                }
                //apply offset
                top = isInverted ? top + topOffset : top - topOffset
                bottom = isInverted ? bottom - bottomOffset : bottom + bottomOffset
                
                // multiply the height of the rect with the phase
                // explicitly add 0 + topOffset to indicate this is changed after adding accessibility support (#3650, #3520)
                if top > 0 + topOffset
                {
                    top *= CGFloat(phaseY)
                }
                else
                {
                    bottom *= CGFloat(phaseY)
                }
                
                barRect.origin.x = left
                barRect.origin.y = top
                barRect.size.width = right - left
                barRect.size.height = bottom - top
                buffer.rects[bufferIndex] = barRect
                bufferIndex += 1
            }
            else
            {
                var posY = 0.0
                var negY = -e.negativeSum
                var yStart = 0.0
                
                // fill the stack
                for k in 0 ..< vals!.count
                {
                    let value = vals![k]
                    
                    if value == 0.0 && (posY == 0.0 || negY == 0.0)
                    {
                        // Take care of the situation of a 0.0 value, which overlaps a non-zero bar
                        y = value
                        yStart = y
                    }
                    else if value >= 0.0
                    {
                        y = posY
                        yStart = posY + value
                        posY = yStart
                    }
                    else
                    {
                        y = negY
                        yStart = negY + abs(value)
                        negY += abs(value)
                    }
                    
                    let left = CGFloat(x - barWidthHalf)
                    let right = CGFloat(x + barWidthHalf)
                    var top = isInverted
                        ? (y <= yStart ? CGFloat(y) : CGFloat(yStart))
                        : (y >= yStart ? CGFloat(y) : CGFloat(yStart))
                    var bottom = isInverted
                        ? (y >= yStart ? CGFloat(y) : CGFloat(yStart))
                        : (y <= yStart ? CGFloat(y) : CGFloat(yStart))
                    
                    // multiply the height of the rect with the phase
                    top *= CGFloat(phaseY)
                    bottom *= CGFloat(phaseY)
                    
                    barRect.origin.x = left
                    barRect.size.width = right - left
                    barRect.origin.y = top
                    barRect.size.height = bottom - top
                    
                    buffer.rects[bufferIndex] = barRect
                    bufferIndex += 1
                }
            }
        }
    }
    
    
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
                let size = set.entryCount * (set.isStacked ? set.stackSize : 1)
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
    
    
    public override func drawDataSet(context: CGContext, dataSet: IBarChartDataSet, index: Int) {
        
        if index < _buffers.count {
            
            guard
                let dataProvider = dataProvider
                else { return }
            
            let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
            
            prepareBuffer(dataSet: dataSet, index: index)
            trans.rectValuesToPixel(&_buffers[index].rects)
            
            let borderWidth = dataSet.barBorderWidth
            let borderColor = dataSet.barBorderColor
            let drawBorder = borderWidth > 0.0
            
            context.saveGState()
            
            // draw the bar shadow before the values
            if dataProvider.isDrawBarShadowEnabled
            {
                guard
                    let animator : Animator = animator,
                    let barData = dataProvider.barData
                    else { return }
                
                let barWidth = barData.barWidth
                let barWidthHalf = barWidth/2
                
                var x: Double = 0.0
                
                for i in stride(from: 0, to: min(Int(ceil(Double(dataSet.entryCount) * animator.phaseX)), dataSet.entryCount), by: 1)
                {
                    guard let e = dataSet.entryForIndex(i) as? BarChartDataEntry else { continue }
                    
                    x = e.x
                    
                    _barShadowRectBuffer.origin.x = CGFloat(x - barWidthHalf)
                    _barShadowRectBuffer.size.width = CGFloat(barWidth)
                    
                    trans.rectValueToPixel(&_barShadowRectBuffer)
                    
                    if !viewPortHandler.isInBoundsLeft(_barShadowRectBuffer.origin.x + _barShadowRectBuffer.size.width)
                    {
                        continue
                    }
                    
                    if !viewPortHandler.isInBoundsRight(_barShadowRectBuffer.origin.x)
                    {
                        break
                    }
                    
                    _barShadowRectBuffer.origin.y = viewPortHandler.contentTop
                    _barShadowRectBuffer.size.height = viewPortHandler.contentHeight
                    
                    context.setFillColor(dataSet.barShadowColor.cgColor)
                    #if !os(OSX)
                    let bezierPath = UIBezierPath(roundedRect: _barShadowRectBuffer, cornerRadius: 10)
                    context.addPath(bezierPath.cgPath)
                    #endif
                    context.drawPath(using: .fill)
                }
            }
            
            let buffer = _buffers[index]
            
            // draw the bar shadow before the values
            if dataProvider.isDrawBarShadowEnabled
            {
                for j in stride(from: 0, to: buffer.rects.count, by: 1)
                {
                    var barRect = buffer.rects[j]
                    
                    if (!viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width))
                    {
                        continue
                    }
                    
                    if (!viewPortHandler.isInBoundsRight(barRect.origin.x))
                    {
                        break
                    }
                    context.setFillColor(dataSet.barShadowColor.cgColor)
                    #if !os(OSX)
                    let bezierPath = UIBezierPath(roundedRect: barRect, cornerRadius: 10)
                    context.addPath(bezierPath.cgPath)
                    #endif
                    context.drawPath(using: .fill)
                }
            }
            
            let isSingleColor = dataSet.colors.count == 1
            
            if isSingleColor
            {
                context.setFillColor(dataSet.color(atIndex: 0).cgColor)
            }
            
            for j in stride(from: 0, to: buffer.rects.count, by: 1)
            {
                context.saveGState()
                
                var e: ChartDataEntry! = dataSet.entryForIndex(j)
                
                barColors.removeAll()
                for i in 0..<Int(e.y){
                    barColors.append(gradientColor[i])
                }
                
                if e.y == 0 {
                    barColors.append(gradientColor.first!)
                }
                
                let reversedBarColors = barColors.reversed().filter{$0.alpha == 0.3}
                let barRect = buffer.rects[j]
                
                if (!viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width))
                {
                    continue
                }
                
                if (!viewPortHandler.isInBoundsRight(barRect.origin.x))
                {
                    break
                }
                
                if !isSingleColor
                {
                    
                    context.addRect(barRect)
                    //                    #if !os(OSX)
                    //                    let bezierPath = UIBezierPath(roundedRect: barRect , cornerRadius: 10)
                    //
                    //                    context.addPath(bezierPath.cgPath)
                    //                    #endif
                    
                    // corner radius for bar chart
                    #if !os(OSX)
                    let path = UIBezierPath(roundedRect: barRect,
                                            byRoundingCorners: .allCorners,
                                            cornerRadii: CGSize(width: 10, height: 0))
                    path.addClip()
                    
                    context.addPath(path.cgPath)
                    #endif
                    
                    // gradient config
                    var locations  = [CGFloat]()
                    
                    locations = [0, 0.3106059, 0.58429635, 0.72057116, 1]
                    
                    
                    let colors = reversedBarColors
                    
                    let colorspace = CGColorSpaceCreateDeviceRGB()
                    
                    let gradient = CGGradient(colorsSpace: colorspace,
                                              colors: colors as CFArray, locations: locations)
                    
                    
                    var startPoint = CGPoint()
                    var endPoint =  CGPoint()
                    
                    startPoint.x = barRect.midX
                    startPoint.y = barRect.minY
                    endPoint.x = barRect.midX
                    endPoint.y = barRect.maxY
                    //Modifies the current clipping path.
                    context.clip()
                    // draw the gradient
                    context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: .drawsBeforeStartLocation)
                    
                    // Set the color for the currently drawn value. If the index is out of bounds, reuse colors.
                    //                    context.setFillColor(dataSet.color(atIndex: j).cgColor)
                }
                
                
                
                context.drawPath(using: .fill)
                
                if drawBorder
                {
                    context.setStrokeColor(borderColor.cgColor)
                    context.setLineWidth(borderWidth)
                    context.stroke(barRect)
                }
                context.restoreGState()
                
            }
            
            context.restoreGState()
        }
    }
    
    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let dataProvider = dataProvider,
            let barData = dataProvider.barData
            else { return }
        
        context.saveGState()
        
        var barRect = CGRect()
        
        for high in indices
        {
            
            guard
                let set = barData.getDataSetByIndex(high.dataSetIndex) as? IBarChartDataSet,
                set.isHighlightEnabled
                else { continue }
            
            if let e = set.entryForXValue(high.x, closestToY: high.y) as? BarChartDataEntry
            {
                //                if !isInBoundsX(entry: e, dataSet: set)
                //                {
                //                    continue
                //                }
                
                let trans = dataProvider.getTransformer(forAxis: set.axisDependency)
                context.setLineWidth(set.highlightLineWidth)
                context.setFillColor(set.highlightColor.cgColor)
                context.setAlpha(set.highlightAlpha)
                
                
                let isStack = high.stackIndex >= 0 && e.isStacked
                
                let y1: Double
                let y2: Double
                
                if isStack
                {
                    if dataProvider.isHighlightFullBarEnabled
                    {
                        y1 = e.positiveSum
                        y2 = -e.negativeSum
                    }
                    else
                    {
                        let range = e.ranges?[high.stackIndex]
                        
                        y1 = range?.from ?? 0.0
                        y2 = range?.to ?? 0.0
                    }
                }
                else
                {
                    y1 = e.y
                    y2 = 0.0
                }
                
                var rect:CGRect = CGRect(x: e.x-0.25  , y: -0.6 , width: (barData.barWidth / 0.9) * 2.25 , height: y1+(12-y1)+0.6)
                trans.rectValueToPixel(&rect)
                context.setLineWidth(2)
                context.setStrokeColor(set.highlightColor.cgColor)
                #if !os(OSX)
                let bezierPath = UIBezierPath(roundedRect: rect, cornerRadius: 10)
                context.addPath(bezierPath.cgPath)
                #endif
                context.drawPath(using: .stroke)
                prepareBarHighlight(x: e.x, y1: y1+(12-y1), y2: y2-0.5, barWidthHalf: barData.barWidth / 0.9, trans: trans, rect: &barRect)
                
                setHighlightDrawPos(highlight: high, barRect: barRect)
                context.setStrokeColor(set.highlightColor.cgColor)
                #if !os(OSX)
                let bezierPathHolder = UIBezierPath(roundedRect: barRect, cornerRadius: 10)
                context.addPath(bezierPathHolder.cgPath)
                #endif
                context.drawPath(using: .fill)
                
                
            }
        }
        context.restoreGState()
        
    }
    
    public override func setHighlightDrawPos(highlight high: Highlight, barRect: CGRect)
    {
        high.setDraw(x: barRect.midX, y: barRect.origin.y)
    }
    
}
