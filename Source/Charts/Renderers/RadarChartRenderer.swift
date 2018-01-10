//
//  RadarChartRenderer.swift
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


open class RadarChartRenderer: LineRadarRenderer
{
    @objc open weak var chart: RadarChartView?

    @objc public init(chart: RadarChartView, animator: Animator, viewPortHandler: ViewPortHandler)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.chart = chart
    }
    
    open override func drawData(context: CGContext)
    {
        guard
            let chart = chart,
            let radarData = chart.data
            else { return }

        let mostEntries = radarData.maxEntryCountSet?.entryCount ?? 0

        for set in radarData.dataSets as! [RadarChartDataSetProtocol] where set.isVisible
        {
            drawDataSet(context: context, dataSet: set, mostEntries: mostEntries)
        }
    }
    
    /// Draws the RadarDataSet
    ///
    /// - parameter context:
    /// - parameter dataSet:
    /// - parameter mostEntries: the entry count of the dataset with the most entries
    func drawDataSet(context: CGContext, dataSet: RadarChartDataSetProtocol, mostEntries: Int)
    {
        guard let chart = chart else { return }
        
        context.saveGState()
        defer { context.restoreGState() }
        
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
            
            let p = center.moving(distance: CGFloat((e.y - chart.chartYMin) * Double(factor) * phaseY),
                                  atAngle: sliceangle * CGFloat(j) * CGFloat(phaseX) + chart.rotationAngle)
            
            guard !p.x.isNaN else { continue }
            
            if !hasMovedToPoint
            {
                path.move(to: p)
                hasMovedToPoint = true
            }
            else
            {
                path.addLine(to: p)
            }
        }
        
        // if this is the largest set, close it
        if dataSet.entryCount < mostEntries
        {
            // if this is not the largest set, draw a line to the center before closing
            path.addLine(to: center)
        }
        
        path.closeSubpath()
        
        // draw filled
        if dataSet.isDrawFilledEnabled
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
        // TODO: Why can't fillAlpha be translucent?
        if !dataSet.isDrawFilledEnabled || dataSet.fillAlpha < 1.0
        {
            context.setStrokeColor(dataSet.color(atIndex: 0).cgColor)
            context.setLineWidth(dataSet.lineWidth)
            context.setAlpha(1.0)
            
            context.beginPath()
            context.addPath(path)
            context.strokePath()
        }
    }
    
    open override func drawValues(context: CGContext)
    {
        guard
            let chart = chart,
            let data = chart.data
            else { return }
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        let sliceangle = chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        let factor = chart.factor
        
        let center = chart.centerOffsets
        
        let yoffset: CGFloat = 5.0
        
        for i in 0 ..< data.dataSetCount
        {
            let dataSet = data.getDataSetByIndex(i) as! RadarChartDataSetProtocol
            
            guard shouldDrawValues(forDataSet: dataSet) else { continue }

            let entryCount = dataSet.entryCount
            
            let iconsOffset = dataSet.iconsOffset
            
            for j in 0 ..< entryCount
            {
                guard let e = dataSet.entryForIndex(j) else { continue }
                
                let p = center.moving(distance: CGFloat(e.y - chart.chartYMin) * factor * CGFloat(phaseY),
                                      atAngle: sliceangle * CGFloat(j) * CGFloat(phaseX) + chart.rotationAngle)
                
                let valueFont = dataSet.valueFont
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                if dataSet.isDrawValuesEnabled
                {
                    context.drawText(formatter.stringForValue(e.y,
                                                              entry: e,
                                                              dataSetIndex: i,
                                                              viewPortHandler: viewPortHandler),
                                     at: CGPoint(x: p.x, y: p.y - yoffset - valueFont.lineHeight),
                                     align: .center,
                                     attributes: [.font: valueFont,
                                                  .foregroundColor: dataSet.valueTextColorAt(j)])
                }
                
                if let icon = e.icon, dataSet.isDrawIconsEnabled
                {
                    var pIcon = center.moving(distance: CGFloat(e.y) * factor * CGFloat(phaseY) + iconsOffset.y,
                                              atAngle: sliceangle * CGFloat(j) * CGFloat(phaseX) + chart.rotationAngle)
                    pIcon.y += iconsOffset.x
                    
                    context.drawImage(icon,
                                      atCenter: CGPoint(x: pIcon.x, y: pIcon.y),
                                      size: icon.size)
                }
            }
        }
    }
    
    open override func drawExtras(context: CGContext)
    {
        drawWeb(context: context)
    }
    
    private var _webLineSegmentsBuffer = [CGPoint](repeating: .zero, count: 2)
    
    @objc open func drawWeb(context: CGContext)
    {
        guard
            let chart = chart,
            let data = chart.data
            else { return }
        
        let sliceangle = chart.sliceAngle
        
        context.saveGState()
        defer { context.restoreGState() }
        
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
        let maxEntryCount = chart.data?.maxEntryCountSet?.entryCount ?? 0

        for i in stride(from: 0, to: maxEntryCount, by: xIncrements)
        {
            let p = center.moving(distance: CGFloat(chart.yRange) * factor,
                                  atAngle: sliceangle * CGFloat(i) + rotationangle)
            
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
        
        let entries = chart.yAxis.entries
        
        for e in entries
        {
            for i in 0 ..< data.entryCount
            {
                let r = CGFloat(e - chart.chartYMin) * factor

                let p1 = center.moving(distance: r, atAngle: sliceangle * CGFloat(i) + rotationangle)
                let p2 = center.moving(distance: r, atAngle: sliceangle * CGFloat(i + 1) + rotationangle)
                
                _webLineSegmentsBuffer[0].x = p1.x
                _webLineSegmentsBuffer[0].y = p1.y
                _webLineSegmentsBuffer[1].x = p2.x
                _webLineSegmentsBuffer[1].y = p2.y
                
                context.strokeLineSegments(between: _webLineSegmentsBuffer)
            }
        }
    }
    
    private var _highlightPointBuffer = CGPoint()

    open override func drawHighlighted(context: CGContext, indices: [Highlight])
    {
        guard
            let chart = chart,
            let radarData = chart.data as? RadarChartData
            else { return }
        
        context.saveGState()
        defer { context.restoreGState() }

        let sliceangle = chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value pixels
        let factor = chart.factor
        
        let center = chart.centerOffsets
        
        for high in indices
        {
            guard
                let set = chart.data?.getDataSetByIndex(high.dataSetIndex) as? RadarChartDataSetProtocol,
                set.isHighlightEnabled,
                let e = set.entryForIndex(Int(high.x)) as? RadarChartDataEntry,
                isInBoundsX(entry: e, dataSet: set)
                else { continue }

            context.setLineWidth(radarData.highlightLineWidth)
            if radarData.highlightLineDashLengths != nil
            {
                context.setLineDash(phase: radarData.highlightLineDashPhase, lengths: radarData.highlightLineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            context.setStrokeColor(set.highlightColor.cgColor)
            
            let y = e.y - chart.chartYMin
            
            _highlightPointBuffer = center.moving(distance: CGFloat(y) * factor * CGFloat(animator.phaseY),
                                                  atAngle: sliceangle * CGFloat(high.x) * CGFloat(animator.phaseX) + chart.rotationAngle)
            
            high.setDraw(pt: _highlightPointBuffer)
            
            // draw the lines
            drawHighlightLines(context: context, point: _highlightPointBuffer, set: set)
            
            if set.isDrawHighlightCircleEnabled,
                !_highlightPointBuffer.x.isNaN,
                !_highlightPointBuffer.y.isNaN
            {
                var strokeColor = set.highlightCircleStrokeColor
                if strokeColor == nil
                {
                    strokeColor = set.color(atIndex: 0)
                }
                if set.highlightCircleStrokeAlpha < 1.0
                {
                    strokeColor = strokeColor?.withAlphaComponent(set.highlightCircleStrokeAlpha)
                }

                drawHighlightCircle(context: context,
                                    atPoint: _highlightPointBuffer,
                                    innerRadius: set.highlightCircleInnerRadius,
                                    outerRadius: set.highlightCircleOuterRadius,
                                    fillColor: set.highlightCircleFillColor,
                                    strokeColor: strokeColor,
                                    strokeWidth: set.highlightCircleStrokeWidth)
            }
        }
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
        defer { context.restoreGState() }

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
    }
}
