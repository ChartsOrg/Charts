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


public class RadarChartRenderer: LineRadarRenderer
{
    public weak var chart: RadarChartView?

    public init(chart: RadarChartView?, animator: Animator?, viewPortHandler: ViewPortHandler?)
    {
        super.init(animator: animator, viewPortHandler: viewPortHandler)
        
        self.chart = chart
    }
    
    public override func drawData(context context: CGContext)
    {
        guard let chart = chart else { return }
        
        let radarData = chart.data
        
        if (radarData != nil)
        {
            let mostEntries = radarData?.maxEntryCountSet?.entryCount ?? 0
            
            for set in radarData!.dataSets as! [IRadarChartDataSet]
            {
                if set.isVisible
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
    internal func drawDataSet(context context: CGContext, dataSet: IRadarChartDataSet, mostEntries: Int)
    {
        guard let
            chart = chart,
            animator = animator
            else { return }
        
        CGContextSaveGState(context)
        
        let phaseX = animator.phaseX
        let phaseY = animator.phaseY
        
        let sliceangle = chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        let factor = chart.factor
        
        let center = chart.centerOffsets
        let entryCount = dataSet.entryCount
        let path = CGPathCreateMutable()
        var hasMovedToPoint = false
        
        for j in 0 ..< entryCount
        {
            guard let e = dataSet.entryForIndex(j) else { continue }
            
            let p = ChartUtils.getPosition(
                center: center,
                dist: CGFloat((e.y - chart.chartYMin) * Double(factor) * phaseY),
                angle: sliceangle * CGFloat(j) * CGFloat(phaseX) + chart.rotationAngle)
            
            if p.x.isNaN
            {
                continue
            }
            
            if !hasMovedToPoint
            {
                CGPathMoveToPoint(path, nil, p.x, p.y)
                hasMovedToPoint = true
            }
            else
            {
                CGPathAddLineToPoint(path, nil, p.x, p.y)
            }
        }
        
        // if this is the largest set, close it
        if dataSet.entryCount < mostEntries
        {
            // if this is not the largest set, draw a line to the center before closing
            CGPathAddLineToPoint(path, nil, center.x, center.y)
        }
        
        CGPathCloseSubpath(path)
        
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
        if !dataSet.isDrawFilledEnabled || dataSet.fillAlpha < 1.0
        {
            CGContextSetStrokeColorWithColor(context, dataSet.colorAt(0).CGColor)
            CGContextSetLineWidth(context, dataSet.lineWidth)
            CGContextSetAlpha(context, 1.0)
            
            CGContextBeginPath(context)
            CGContextAddPath(context, path)
            CGContextStrokePath(context)
        }
        
        CGContextRestoreGState(context)
    }
    
    public override func drawValues(context context: CGContext)
    {
        guard let
            chart = chart,
            data = chart.data,
            animator = animator
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
            
            if !shouldDrawValues(forDataSet: dataSet)
            {
                continue
            }
            
            let entryCount = dataSet.entryCount
            
            for j in 0 ..< entryCount
            {
                guard let e = dataSet.entryForIndex(j) else { continue }
                
                let p = ChartUtils.getPosition(
                    center: center,
                    dist: CGFloat(e.y - chart.chartYMin) * factor * CGFloat(phaseY),
                    angle: sliceangle * CGFloat(j) * CGFloat(phaseX) + chart.rotationAngle)
                
                let valueFont = dataSet.valueFont
                
                guard let formatter = dataSet.valueFormatter else { continue }
                
                ChartUtils.drawText(
                    context: context,
                    text: formatter.stringForValue(
                        e.y,
                        entry: e,
                        dataSetIndex: i,
                        viewPortHandler: viewPortHandler),
                    point: CGPoint(x: p.x, y: p.y - yoffset - valueFont.lineHeight),
                    align: .Center,
                    attributes: [NSFontAttributeName: valueFont,
                        NSForegroundColorAttributeName: dataSet.valueTextColorAt(j)]
                )
            }
        }
    }
    
    public override func drawExtras(context context: CGContext)
    {
        drawWeb(context: context)
    }
    
    private var _webLineSegmentsBuffer = [CGPoint](count: 2, repeatedValue: CGPoint())
    
    public func drawWeb(context context: CGContext)
    {
        guard let
            chart = chart,
            data = chart.data
            else { return }
        
        let sliceangle = chart.sliceAngle
        
        CGContextSaveGState(context)
        
        // calculate the factor that is needed for transforming the value to
        // pixels
        let factor = chart.factor
        let rotationangle = chart.rotationAngle
        
        let center = chart.centerOffsets
        
        // draw the web lines that come from the center
        CGContextSetLineWidth(context, chart.webLineWidth)
        CGContextSetStrokeColorWithColor(context, chart.webColor.CGColor)
        CGContextSetAlpha(context, chart.webAlpha)
        
        let xIncrements = 1 + chart.skipWebLineCount
        let maxEntryCount = chart.data?.maxEntryCountSet?.entryCount ?? 0

        for i in 0.stride(to: maxEntryCount, by: xIncrements)
        {
            let p = ChartUtils.getPosition(
                center: center,
                dist: CGFloat(chart.yRange) * factor,
                angle: sliceangle * CGFloat(i) + rotationangle)
            
            _webLineSegmentsBuffer[0].x = center.x
            _webLineSegmentsBuffer[0].y = center.y
            _webLineSegmentsBuffer[1].x = p.x
            _webLineSegmentsBuffer[1].y = p.y
            
            CGContextStrokeLineSegments(context, _webLineSegmentsBuffer, 2)
        }
        
        // draw the inner-web
        CGContextSetLineWidth(context, chart.innerWebLineWidth)
        CGContextSetStrokeColorWithColor(context, chart.innerWebColor.CGColor)
        CGContextSetAlpha(context, chart.webAlpha)
        
        let labelCount = chart.yAxis.entryCount
        
        for j in 0 ..< labelCount
        {
            for i in 0 ..< data.entryCount
            {
                let r = CGFloat(chart.yAxis.entries[j] - chart.chartYMin) * factor

                let p1 = ChartUtils.getPosition(center: center, dist: r, angle: sliceangle * CGFloat(i) + rotationangle)
                let p2 = ChartUtils.getPosition(center: center, dist: r, angle: sliceangle * CGFloat(i + 1) + rotationangle)
                
                _webLineSegmentsBuffer[0].x = p1.x
                _webLineSegmentsBuffer[0].y = p1.y
                _webLineSegmentsBuffer[1].x = p2.x
                _webLineSegmentsBuffer[1].y = p2.y
                
                CGContextStrokeLineSegments(context, _webLineSegmentsBuffer, 2)
            }
        }
        
        CGContextRestoreGState(context)
    }
    
    private var _highlightPointBuffer = CGPoint()

    public override func drawHighlighted(context context: CGContext, indices: [Highlight])
    {
        guard let
            chart = chart,
            radarData = chart.data as? RadarChartData,
            animator = animator
            else { return }
        
        CGContextSaveGState(context)
        
        let sliceangle = chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value pixels
        let factor = chart.factor
        
        let center = chart.centerOffsets
        
        for high in indices
        {
            guard let set = chart.data?.getDataSetByIndex(high.dataSetIndex) as? IRadarChartDataSet
                where set.isHighlightEnabled
                else { continue }
            
            guard let e = set.entryForIndex(Int(high.x)) as? RadarChartDataEntry
                else { continue }
            
            if !isInBoundsX(entry: e, dataSet: set)
            {
                continue
            }
            
            CGContextSetLineWidth(context, radarData.highlightLineWidth)
            if (radarData.highlightLineDashLengths != nil)
            {
                CGContextSetLineDash(context, radarData.highlightLineDashPhase, radarData.highlightLineDashLengths!, radarData.highlightLineDashLengths!.count)
            }
            else
            {
                CGContextSetLineDash(context, 0.0, nil, 0)
            }
            
            CGContextSetStrokeColorWithColor(context, set.highlightColor.CGColor)
            
            let y = e.y - chart.chartYMin
            
            _highlightPointBuffer = ChartUtils.getPosition(
                center: center,
                dist: CGFloat(y) * factor * CGFloat(animator.phaseY),
                angle: sliceangle * CGFloat(high.x) * CGFloat(animator.phaseX) + chart.rotationAngle)
            
            high.setDraw(pt: _highlightPointBuffer)
            
            // draw the lines
            drawHighlightLines(context: context, point: _highlightPointBuffer, set: set)
            
            if (set.isDrawHighlightCircleEnabled)
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
                        strokeColor = strokeColor?.colorWithAlphaComponent(set.highlightCircleStrokeAlpha)
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
        
        CGContextRestoreGState(context)
    }
    
    internal func drawHighlightCircle(
        context context: CGContext,
        atPoint point: CGPoint,
        innerRadius: CGFloat,
        outerRadius: CGFloat,
        fillColor: NSUIColor?,
        strokeColor: NSUIColor?,
        strokeWidth: CGFloat)
    {
        CGContextSaveGState(context)
        
        if let fillColor = fillColor
        {
            CGContextBeginPath(context)
            CGContextAddEllipseInRect(context, CGRectMake(point.x - outerRadius, point.y - outerRadius, outerRadius * 2.0, outerRadius * 2.0))
            if innerRadius > 0.0
            {
                CGContextAddEllipseInRect(context, CGRectMake(point.x - innerRadius, point.y - innerRadius, innerRadius * 2.0, innerRadius * 2.0))
            }
            
            CGContextSetFillColorWithColor(context, fillColor.CGColor)
            CGContextEOFillPath(context)
        }
            
        if let strokeColor = strokeColor
        {
            CGContextBeginPath(context)
            CGContextAddEllipseInRect(context, CGRectMake(point.x - outerRadius, point.y - outerRadius, outerRadius * 2.0, outerRadius * 2.0))
            CGContextSetStrokeColorWithColor(context, strokeColor.CGColor)
            CGContextSetLineWidth(context, strokeWidth)
            CGContextStrokePath(context)
        }
        
        CGContextRestoreGState(context)
    }
}