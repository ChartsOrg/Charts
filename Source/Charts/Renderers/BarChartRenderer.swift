//
//  BarChartRenderer.swift
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

open class BarChartRenderer: BarLineScatterCandleBubbleRenderer
{
    fileprivate class Buffer
    {
        var rects = [CGRect]()
    }

    open weak var dataProvider: BarChartDataProvider?

    public init(dataProvider: BarChartDataProvider?, animator: Animator?, viewPortHandler: ViewPortHandler?)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)

        self.dataProvider = dataProvider
    }

    // [CGRect] per dataset
    fileprivate var _buffers = [Buffer]()

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

            for i in 0..<barData.dataSetCount
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

    fileprivate func prepareBuffer(dataSet: IBarChartDataSet, index: Int)
    {
        guard let dataProvider = dataProvider,
            let barData = dataProvider.barData,
            let animator = animator
            else { return }

        let barWidthHalf = barData.barWidth / 2.0

        let buffer = _buffers[index]
        var bufferIndex = 0
        let containsStacks = dataSet.isStacked

        let isInverted = dataProvider.isInverted(axis: dataSet.axisDependency)
        let phaseY = CGFloat(animator.phaseY)
        var barRect = CGRect()
        var x: CGFloat
        var y: CGFloat

        let to = min(Int(ceil(CGFloat(dataSet.entryCount) * animator.phaseX)), dataSet.entryCount)
        for i in 0..<to
        {
            guard let e = dataSet.entryForIndex(i) as? BarChartDataEntry else { continue }

            let vals = e.yValues

            x = CGFloat(e.x)
            y = CGFloat(e.y)

            if !containsStacks || vals == nil
            {
                let left = x - barWidthHalf
                let right = x + barWidthHalf
                var top = isInverted
                    ? (y <= 0.0 ? y : 0)
                    : (y >= 0.0 ? y : 0)
                var bottom = isInverted
                    ? (y >= 0.0 ? y : 0)
                    : (y <= 0.0 ? y : 0)

                // multiply the height of the rect with the phase
                if top.sign == .plus
                {
                    top *= phaseY
                }
                else
                {
                    bottom *= phaseY
                }

                barRect.origin.x = left
                barRect.size.width = right - left
                barRect.origin.y = top
                barRect.size.height = bottom - top

                buffer.rects[bufferIndex] = barRect
                bufferIndex += 1
            }
            else
            {
                var posY: CGFloat = 0.0
                var negY = CGFloat(-e.negativeSum)
                var yStart: CGFloat = 0.0

                // fill the stack
                for value in vals!
                {
                    let value = CGFloat(value)

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

                    let left = x - barWidthHalf
                    let right = x + barWidthHalf
                    var top = isInverted
                        ? (y <= yStart ? y : yStart)
                        : (y >= yStart ? y : yStart)
                    var bottom = isInverted
                        ? (y >= yStart ? y : yStart)
                        : (y <= yStart ? y : yStart)

                    // multiply the height of the rect with the phase
                    top *= phaseY
                    bottom *= phaseY

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

    open override func drawData(context: CGContext)
    {
        guard let dataProvider = dataProvider,
            let barData = dataProvider.barData
            else { return }

        // TODO: Refine when `ChartData` conforms to `Collection`
        for i in 0 ..< barData.dataSetCount
        {
            guard let set = barData.getDataSetByIndex(i), set.isVisible else { continue }

            if !(set is IBarChartDataSet)
            {
                fatalError("Datasets for BarChartRenderer must conform to IBarChartDataset")
            }

            drawDataSet(context: context, dataSet: set as! IBarChartDataSet, index: i)
        }
    }

    fileprivate var _barShadowRectBuffer: CGRect = CGRect()

    open func drawDataSet(context: CGContext, dataSet: IBarChartDataSet, index: Int)
    {
        guard let dataProvider = dataProvider,
            let viewPortHandler = self.viewPortHandler
            else { return }

        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)

        prepareBuffer(dataSet: dataSet, index: index)
        trans.rectValuesToPixel(&_buffers[index].rects)

        let borderWidth = dataSet.barBorderWidth
        let borderColor = dataSet.barBorderColor
        let drawBorder = borderWidth > 0.0

        context.saveGState()
        defer { context.restoreGState() }

        // draw the bar shadow before the values
        if dataProvider.isDrawBarShadowEnabled
        {
            guard let animator = animator,
                let barData = dataProvider.barData
                else { return }

            let barWidth = barData.barWidth
            let barWidthHalf = barWidth / 2.0
            var x: CGFloat = 0.0

            let end = min(Int(ceil(CGFloat(dataSet.entryCount) * animator.phaseX)), dataSet.entryCount)
            // TODO: Refine when `ChartData` conforms to `Collection`
            for i in 0..<end
            {
                guard let e = dataSet.entryForIndex(i) as? BarChartDataEntry else { continue }

                x = CGFloat(e.x)

                _barShadowRectBuffer.origin.x = x - barWidthHalf
                _barShadowRectBuffer.size.width = barWidth

                trans.rectValueToPixel(&_barShadowRectBuffer)

                guard viewPortHandler.isInBoundsLeft(_barShadowRectBuffer.origin.x + _barShadowRectBuffer.size.width) else { continue }

                guard viewPortHandler.isInBoundsRight(_barShadowRectBuffer.origin.x) else { break }

                _barShadowRectBuffer.origin.y = viewPortHandler.contentTop
                _barShadowRectBuffer.size.height = viewPortHandler.contentHeight

                context.setFillColor(dataSet.barShadowColor.cgColor)
                context.fill(_barShadowRectBuffer)
            }
        }

        let buffer = _buffers[index]

        // draw the bar shadow before the values
        if dataProvider.isDrawBarShadowEnabled
        {
            for barRect in buffer.rects where
                viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width)
            {
                guard viewPortHandler.isInBoundsRight(barRect.origin.x) else { break }

                context.setFillColor(dataSet.barShadowColor.cgColor)
                context.fill(barRect)
            }
        }

        let isSingleColor = dataSet.colors.count == 1

        if isSingleColor
        {
            context.setFillColor(dataSet.color(atIndex: 0).cgColor)
        }

        for j in 0..<buffer.rects.count
        {
            let barRect = buffer.rects[j]

            guard viewPortHandler.isInBoundsLeft(barRect.origin.x + barRect.size.width) else { continue }
            guard viewPortHandler.isInBoundsRight(barRect.origin.x) else { break }

            if !isSingleColor
            {
                // Set the color for the currently drawn value. If the index is out of bounds, reuse colors.
                context.setFillColor(dataSet.color(atIndex: j).cgColor)
            }

            context.fill(barRect)

            if drawBorder
            {
                context.setStrokeColor(borderColor.cgColor)
                context.setLineWidth(borderWidth)
                context.stroke(barRect)
            }
        }
    }

    open func prepareBarHighlight(
        x: Double,
        y1: Double,
        y2: Double,
        barWidthHalf: CGFloat,
        trans: Transformer,
        rect: inout CGRect)
    {
        let left = CGFloat(x) - barWidthHalf
        let right = CGFloat(x) + barWidthHalf
        let top = CGFloat(y1)
        let bottom = CGFloat(y2)

        //        rect = CGRect(x: left, y: top, width: right - left, height: bottom - top)
        rect.origin.x = left
        rect.origin.y = top
        rect.size.width = right - left
        rect.size.height = bottom - top

        trans.rectValueToPixel(&rect, phaseY: animator?.phaseY ?? 1.0)
    }

    open override func drawValues(context: CGContext)
    {
        // if values are drawn
        guard isDrawingValuesAllowed(dataProvider: dataProvider),
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

        for dataSetIndex in 0 ..< barData.dataSetCount
        {
            guard let dataSet = dataSets[dataSetIndex] as? IBarChartDataSet,
                shouldDrawValues(forDataSet: dataSet)
                else { continue }

            let isInverted = dataProvider.isInverted(axis: dataSet.axisDependency)

            // calculate the correct offset depending on the draw position of the value
            let valueFont = dataSet.valueFont
            let valueTextHeight = valueFont.lineHeight
            posOffset = (drawValueAboveBar ? -(valueTextHeight + valueOffsetPlus) : valueOffsetPlus)
            negOffset = (drawValueAboveBar ? valueOffsetPlus : -(valueTextHeight + valueOffsetPlus))

            if isInverted
            {
                posOffset = -posOffset - valueTextHeight
                negOffset = -negOffset - valueTextHeight
            }

            let buffer = _buffers[dataSetIndex]

            guard let formatter = dataSet.valueFormatter else { continue }

            let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)

            let phaseY = animator.phaseY

            let iconsOffset = dataSet.iconsOffset

            // if only single values are drawn (sum)
            if !dataSet.isStacked
            {
                let end = Int(ceil(CGFloat(dataSet.entryCount) * animator.phaseX))
                for j in 0 ..< end
                {
                    guard let e = dataSet.entryForIndex(j) as? BarChartDataEntry else { continue }

                    let rect = buffer.rects[j]

                    let x = rect.origin.x + rect.size.width / 2.0

                    guard viewPortHandler.isInBoundsRight(x) else { break }

                    guard viewPortHandler.isInBoundsY(rect.origin.y),
                        viewPortHandler.isInBoundsLeft(x)
                        else { continue }

                    let val = e.y

                    if dataSet.isDrawValuesEnabled
                    {
                        drawValue(
                            context: context,
                            value: formatter.stringForValue(
                                val,
                                entry: e,
                                dataSetIndex: dataSetIndex,
                                viewPortHandler: viewPortHandler),
                            xPos: x,
                            yPos: val >= 0.0
                                ? (rect.origin.y + posOffset)
                                : (rect.origin.y + rect.size.height + negOffset),
                            font: valueFont,
                            align: .center,
                            color: dataSet.valueTextColorAt(j))
                    }

                    if let icon = e.icon, dataSet.isDrawIconsEnabled
                    {
                        var px = x
                        var py = val >= 0.0
                            ? (rect.origin.y + posOffset)
                            : (rect.origin.y + rect.size.height + negOffset)

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
            else
            {
                // if we have stacks

                var bufferIndex = 0

                for index in 0 ..< Int(ceil(CGFloat(dataSet.entryCount) * animator.phaseX))
                {
                    guard let e = dataSet.entryForIndex(index) as? BarChartDataEntry else { continue }

                    let vals = e.yValues

                    let rect = buffer.rects[bufferIndex]

                    let x = rect.origin.x + rect.size.width / 2.0

                    // we still draw stacked bars, but there is one non-stacked in between
                    if let vals = vals {
                        // draw stack values
                        var transformed = [CGPoint]()

                        var posY: CGFloat = 0.0
                        var negY = CGFloat(-e.negativeSum)

                        for v in vals
                        {
                            let value = CGFloat(v)
                            var y: CGFloat

                            if value.isZero && (posY.isZero || negY.isZero)
                            {
                                // Take care of the situation of a 0.0 value, which overlaps a non-zero bar
                                y = value
                            }
                            else if value >= 0.0
                            {
                                posY += value
                                y = posY
                            }
                            else
                            {
                                y = negY
                                negY -= value
                            }

                            transformed.append(CGPoint(x: 0.0, y: y * phaseY))
                        }

                        trans.pointValuesToPixel(&transformed)

                        for k in 0 ..< transformed.count
                        {
                            let val = vals[k]
                            let drawBelow = (val == 0.0 && negY == 0.0 && posY > 0.0) || val < 0.0
                            let y = transformed[k].y + (drawBelow ? negOffset : posOffset)

                            guard viewPortHandler.isInBoundsRight(x) else { break }

                            guard viewPortHandler.isInBoundsY(y),
                                viewPortHandler.isInBoundsLeft(x)
                                else { continue }

                            if dataSet.isDrawValuesEnabled
                            {
                                drawValue(
                                    context: context,
                                    value: formatter.stringForValue(
                                        val,
                                        entry: e,
                                        dataSetIndex: dataSetIndex,
                                        viewPortHandler: viewPortHandler),
                                    xPos: x,
                                    yPos: y,
                                    font: valueFont,
                                    align: .center,
                                    color: dataSet.valueTextColorAt(index))
                            }

                            if let icon = e.icon, dataSet.isDrawIconsEnabled
                            {
                                ChartUtils.drawImage(
                                    context: context,
                                    image: icon,
                                    x: x + iconsOffset.x,
                                    y: y + iconsOffset.y,
                                    size: icon.size)
                            }
                        }
                    }
                    else
                    {
                        guard viewPortHandler.isInBoundsRight(x) else { break }

                        guard viewPortHandler.isInBoundsY(rect.origin.y),
                            viewPortHandler.isInBoundsLeft(x)
                            else { continue }

                        if dataSet.isDrawValuesEnabled
                        {
                            drawValue(
                                context: context,
                                value: formatter.stringForValue(
                                    e.y,
                                    entry: e,
                                    dataSetIndex: dataSetIndex,
                                    viewPortHandler: viewPortHandler),
                                xPos: x,
                                yPos: rect.origin.y +
                                    (e.y >= 0 ? posOffset : negOffset),
                                font: valueFont,
                                align: .center,
                                color: dataSet.valueTextColorAt(index))
                        }

                        if let icon = e.icon, dataSet.isDrawIconsEnabled
                        {
                            var px = x
                            var py = rect.origin.y +
                                (e.y >= 0 ? posOffset : negOffset)

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

                    bufferIndex = vals == nil ? (bufferIndex + 1) : (bufferIndex + vals!.count)
                }
            }
        }
    }

    /// Draws a value at the specified x and y position.
    open func drawValue(context: CGContext, value: String, xPos: CGFloat, yPos: CGFloat, font: NSUIFont, align: NSTextAlignment, color: NSUIColor)
    {
        ChartUtils.drawText(context: context, text: value, point: CGPoint(x: xPos, y: yPos), align: align, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: color])
    }

    open override func drawExtras(context: CGContext)
    {

    }

    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard let dataProvider = dataProvider,
            let barData = dataProvider.barData
            else { return }

        context.saveGState()
        defer { context.restoreGState() }

        var barRect = CGRect()

        for high in indices
        {
            guard let set = barData.getDataSetByIndex(high.dataSetIndex) as? IBarChartDataSet,
                set.isHighlightEnabled,
                let e = set.entryForXValue(high.x, closestToY: high.y) as? BarChartDataEntry,
                isInBoundsX(entry: e, dataSet: set)
                else { continue }

            let trans = dataProvider.getTransformer(forAxis: set.axisDependency)

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

            prepareBarHighlight(x: e.x, y1: y1, y2: y2, barWidthHalf: barData.barWidth / 2.0, trans: trans, rect: &barRect)
            
            setHighlightDrawPos(highlight: high, barRect: barRect)
            
            context.fill(barRect)
        }
    }
    
    /// Sets the drawing position of the highlight object based on the riven bar-rect.
    internal func setHighlightDrawPos(highlight high: Highlight, barRect: CGRect)
    {
        high.setDraw(x: barRect.midX, y: barRect.origin.y)
    }
}
