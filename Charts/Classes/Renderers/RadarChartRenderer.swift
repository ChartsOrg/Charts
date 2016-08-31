//
//  RadarChartRenderer.swift
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


open class RadarChartRenderer: LineRadarChartRenderer
{
    open weak var chart: RadarChartView?

    public init(chart: RadarChartView, animator: ChartAnimator?, viewPortHandler: ChartViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.chart = chart
    }
    
    open override func drawData(context: CGContext)
    {
        guard let chart = chart else { return }
        
        let radarData = chart.data
        
        if (radarData != nil)
        {
            var mostEntries = 0
            
            for set in radarData!.dataSets
            {
                if set.entryCount > mostEntries
                {
                    mostEntries = set.entryCount
                }
            }
            
            for set in radarData!.dataSets as! [IRadarChartDataSet]
            {
                if set.visible && set.entryCount > 0
                {
                    drawDataSet(context: context, dataSet: set, mostEntries: mostEntries)
                }
            }
        }
    }
    
    /// Draws the RadarDataSet
    ///
    /// - parameter context:
    /// - parameter dataSet:
    /// - parameter mostEntries: the entry count of the dataset with the most entries
    internal func drawDataSet(context: CGContext, dataSet: IRadarChartDataSet, mostEntries: Int)
    {
        guard let chart = chart,
              let animator = animator
        else { return }
        
        context.saveGState()
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        let sliceangle = chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        let factor = chart.factor
        
        let center = chart.centerOffsets
        let entryCount = dataSet.entryCount
        let path = CGMutablePath()
        var hasMovedToPoint = false
        
        for j in 0 ..< entryCount
        {
            guard let e = dataSet.entryForIndex(j) else { continue }
            
            let p = ChartUtils.getPosition(
                center: center,
                dist: CGFloat(e.value - chart.chartYMin) * factor * phaseY,
                angle: sliceangle * CGFloat(j) * phaseX + chart.rotationAngle)
            
            if p.x.isNaN
            {
                continue
            }
            
            if !hasMovedToPoint
            {
                path.move(to: CGPoint(x: p.x, y: p.y))
                hasMovedToPoint = true
            }
            else
            {
                path.addLine(to: CGPoint(x: p.x, y: p.y))
            }
        }
        
        // if this is the largest set, close it
        if dataSet.entryCount < mostEntries
        {
            // if this is not the largest set, draw a line to the center before closing
            path.addLine(to: CGPoint(x: center.x, y: center.y))
        }
        
        path.closeSubpath()
        
        // draw filled
        if dataSet.drawFilledEnabled
        {
            if dataSet.fill != nil
            {
                drawFilledPath(context: context, path: path, fill: dataSet.fill!, fillAlpha: dataSet.fillAlpha)
            }
            else
            {
                drawFilledPath(context: context, path: path, fillColor: dataSet.fillColor, fillAlpha: dataSet.fillAlpha)
            }
        }
        
        // draw the line (only if filled is disabled or alpha is below 255)
        if !dataSet.drawFilledEnabled || dataSet.fillAlpha < 1.0
        {
            context.setStrokeColor(dataSet.colorAt(0).cgColor)
            context.setLineWidth(dataSet.lineWidth)
            context.setAlpha(1.0)
            
            context.beginPath()
            context.addPath(path)
            context.strokePath()
        }
        
        context.restoreGState()
    }
    
    open override func drawValues(context: CGContext)
    {
        guard let chart = chart,
              let data = chart.data,
              let animator = animator
        else { return }
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        let sliceangle = chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        let factor = chart.factor
        
        let center = chart.centerOffsets
        
        let yoffset = CGFloat(5.0)
        
        for i in 0 ..< data.dataSetCount
        {
            let dataSet = data.getDataSetByIndex(i) as! IRadarChartDataSet
            
            if !dataSet.drawValuesEnabled || dataSet.entryCount == 0
            {
                continue
            }
            
            let entryCount = dataSet.entryCount
            
            for j in 0 ..< entryCount
            {
                guard let e = dataSet.entryForIndex(j) else { continue }
                
                let p = ChartUtils.getPosition(
                    center: center,
                    dist: CGFloat(e.value) * factor * phaseY,
                    angle: sliceangle * CGFloat(j) * phaseX + chart.rotationAngle)
                
                let valueFont = dataSet.valueFont
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                ChartUtils.drawText(
                    context: context,
                    text: formatter.string(from: e.value as NSNumber)!,
                    point: CGPoint(x: p.x, y: p.y - yoffset - valueFont.lineHeight),
                    align: .center,
                    attributes: [NSFontAttributeName: valueFont,
                        NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)]
                )
            }
        }
    }
    
    open override func drawExtras(context: CGContext)
    {
        drawWeb(context: context)
    }
    
    private var _webLineSegmentsBuffer = [CGPoint](repeating: CGPoint(), count: 2)
    
    open func drawWeb(context: CGContext)
    {
        guard let chart = chart,
              let data = chart.data
        else { return }
        
        let sliceangle = chart.sliceAngle
        
        context.saveGState()
        
        // calculate the factor that is needed for transforming the value to
        // pixels
        let factor = chart.factor
        let rotationangle = chart.rotationAngle
        
        let center = chart.centerOffsets
        
        // draw the web lines that come from the center
        context.setLineWidth(chart.webLineWidth)
        context.setStrokeColor(chart.webColor.cgColor)
        context.setAlpha(chart.webAlpha)
        
        let xIncrements = 1 + chart.skipWebLineCount
        
		for i in stride(from: 0, to: data.xValCount, by: xIncrements)
        {
            let p = ChartUtils.getPosition(
                center: center,
                dist: CGFloat(chart.yRange) * factor,
                angle: sliceangle * CGFloat(i) + rotationangle)
            
            _webLineSegmentsBuffer[0].x = center.x
            _webLineSegmentsBuffer[0].y = center.y
            _webLineSegmentsBuffer[1].x = p.x
            _webLineSegmentsBuffer[1].y = p.y
            
            context.strokeLineSegments(between: _webLineSegmentsBuffer)
        }
        
        // draw the inner-web
        context.setLineWidth(chart.innerWebLineWidth)
        context.setStrokeColor(chart.innerWebColor.cgColor)
        context.setAlpha(chart.webAlpha)
        
        let labelCount = chart.yAxis.entryCount
        
        for j in 0 ..< labelCount
        {
            for i in 0 ..< data.xValCount
            {
                let r = CGFloat(chart.yAxis.entries[j] - chart.chartYMin) * factor

                let p1 = ChartUtils.getPosition(center: center, dist: r, angle: sliceangle * CGFloat(i) + rotationangle)
                let p2 = ChartUtils.getPosition(center: center, dist: r, angle: sliceangle * CGFloat(i + 1) + rotationangle)
                
                _webLineSegmentsBuffer[0].x = p1.x
                _webLineSegmentsBuffer[0].y = p1.y
                _webLineSegmentsBuffer[1].x = p2.x
                _webLineSegmentsBuffer[1].y = p2.y
                
                context.strokeLineSegments(between: _webLineSegmentsBuffer)
            }
        }
        
        context.restoreGState()
    }
    
    private var _highlightPointBuffer = CGPoint()

    open override func drawHighlighted(context: CGContext, indices: [ChartHighlight])
    {
        guard let chart = chart,
              let data = chart.data as? RadarChartData,
              let animator = animator
        else { return }
        
        context.saveGState()
        context.setLineWidth(data.highlightLineWidth)
        if (data.highlightLineDashLengths != nil)
        {
            context.setLineDash(phase: data.highlightLineDashPhase, lengths: data.highlightLineDashLengths!)
        }
        else
        {
            context.setLineDash(phase: 0.0, lengths: [])
        }
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        let sliceangle = chart.sliceAngle
        let factor = chart.factor
        
        let center = chart.centerOffsets
        
        for i in 0 ..< indices.count
        {
            guard let set = chart.data?.getDataSetByIndex(indices[i].dataSetIndex) as? IRadarChartDataSet else { continue }
            
            if !set.highlightEnabled
            {
                continue
            }
            
            context.setStrokeColor(set.highlightColor.cgColor)
            
            // get the index to highlight
            let xIndex = indices[i].xIndex
            
            let e = set.entryForXIndex(xIndex)
            if e?.xIndex != xIndex
            {
                continue
            }
            
            let j = set.entryIndex(entry: e!)
            let y = (e!.value - chart.chartYMin)
            
            if (y.isNaN)
            {
                continue
            }
            
            _highlightPointBuffer = ChartUtils.getPosition(
                center: center,
                dist: CGFloat(y) * factor * phaseY,
                angle: sliceangle * CGFloat(j) * phaseX + chart.rotationAngle)
            
            // draw the lines
            drawHighlightLines(context: context, point: _highlightPointBuffer, set: set)
            
            if (set.drawHighlightCircleEnabled)
            {
                if (!_highlightPointBuffer.x.isNaN && !_highlightPointBuffer.y.isNaN)
                {
                    var strokeColor = set.highlightCircleStrokeColor
                    if strokeColor == nil
                    {
                        strokeColor = set.colorAt(0)
                    }
                    if set.highlightCircleStrokeAlpha < 1.0
                    {
                        strokeColor = strokeColor?.withAlphaComponent(set.highlightCircleStrokeAlpha)
                    }
                    
                    drawHighlightCircle(
                        context: context,
                        atPoint: _highlightPointBuffer,
                        innerRadius: set.highlightCircleInnerRadius,
                        outerRadius: set.highlightCircleOuterRadius,
                        fillColor: set.highlightCircleFillColor,
                        strokeColor: strokeColor,
                        strokeWidth: set.highlightCircleStrokeWidth)
                }
            }
        }
        
        context.restoreGState()
    }
    
    internal func drawHighlightCircle(
        context: CGContext,
        atPoint point: CGPoint,
        innerRadius: CGFloat,
        outerRadius: CGFloat,
        fillColor: NSUIColor?,
        strokeColor: NSUIColor?,
        strokeWidth: CGFloat)
    {
        context.saveGState()
        
        if let fillColor = fillColor
        {
            context.beginPath()
            context.addEllipse(in: CGRect(x: point.x - outerRadius, y: point.y - outerRadius, width: outerRadius * 2.0, height: outerRadius * 2.0))
            if innerRadius > 0.0
            {
                context.addEllipse(in: CGRect(x: point.x - innerRadius, y: point.y - innerRadius, width: innerRadius * 2.0, height: innerRadius * 2.0))
            }
            
            context.setFillColor(fillColor.cgColor)
            context.fillPath(using: .evenOdd)
        }
            
        if let strokeColor = strokeColor
        {
            context.beginPath()
            context.addEllipse(in: CGRect(x: point.x - outerRadius, y: point.y - outerRadius, width: outerRadius * 2.0, height: outerRadius * 2.0))
            context.setStrokeColor(strokeColor.cgColor)
            context.setLineWidth(strokeWidth)
            context.strokePath()
        }
        
        context.restoreGState()
    }
}
