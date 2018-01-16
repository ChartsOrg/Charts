//
//  YAxisRendererRadarChart.swift
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


open class YAxisRendererRadarChart: YAxisRenderer
{
    private weak var chart: RadarChartView?
    
    @objc public init(viewPortHandler: ViewPortHandler, axis: YAxis, chart: RadarChartView)
    {
        self.chart = chart

        super.init(viewPortHandler: viewPortHandler, axis: axis, transformer: nil)
    }
    
    open override func computeAxisValues(min yMin: Double, max yMax: Double)
    {
        let labelCount = axis.labelCount
        let range = abs(yMax - yMin)
        
        guard labelCount != 0,
            range > 0,
            range.isFinite
            else
        {
            axis.entries = []
            axis.centeredEntries = []
            return
        }
        
        // Find out how much spacing (in yValue space) between axis values
        let rawInterval = range / Double(labelCount)
        var interval = rawInterval.roundedToNextSignificant()

        // If granularity is enabled, then do not allow the interval to go below specified granularity.
        // This is used to avoid repeated values when rounding values for display.
        if axis.isGranularityEnabled
        {
            interval = Swift.max(interval, axis.granularity)
        }
        
        // Normalize interval
        let intervalMagnitude = pow(10.0, floor(log10(interval))).roundedToNextSignificant()
        let intervalSigDigit = Int(interval / intervalMagnitude)
        
        if intervalSigDigit > 5
        {
            // Use one order of magnitude higher, to avoid intervals like 0.9 or
            // 90
            interval = floor(10 * intervalMagnitude)
        }
        
        let centeringEnabled = axis.isCenterAxisLabelsEnabled
        var n = centeringEnabled ? 1 : 0

        // force label count
        if axis.isForceLabelsEnabled
        {
            let step = range / Double(labelCount - 1)
            
            // Ensure stops contains at least n elements.
            axis.entries.removeAll(keepingCapacity: true)
            axis.entries.reserveCapacity(labelCount)

            let values = stride(from: yMin, to: Double(labelCount) * step + yMin, by: step)
            axis.entries.append(contentsOf: values)
            
            n = labelCount
        }
        else
        {
            // no forced count
            
            var first = interval == 0.0 ? 0.0 : ceil(yMin / interval) * interval
            
            if centeringEnabled
            {
                first -= interval
            }

            let last = interval == 0.0 ? 0.0 : (floor(yMax / interval) * interval).nextUp
            
            if interval != 0.0
            {
                stride(from: first, through: last, by: interval).forEach { _ in n += 1 }
            }
            
            n += 1
            
            // Ensure stops contains at least n elements.
            axis.entries.removeAll(keepingCapacity: true)
            axis.entries.reserveCapacity(labelCount)

            let values = stride(from: first, to: Double(n) * interval + first, by: interval)
            axis.entries.append(contentsOf: values)
        }
        
        // set decimals
        if interval < 1
        {
            axis.decimals = Int(ceil(-log10(interval)))
        }
        else
        {
            axis.decimals = 0
        }
        
        if centeringEnabled
        {
            let offset = (axis.entries[1] - axis.entries[0]) / 2.0
            axis.centeredEntries = axis.entries.map { $0 + offset }
        }
        
        axis.axisMinimum = axis.entries[0]
        axis._axisMaximum = axis.entries[n-1]
        axis.axisRange = abs(axis._axisMaximum - axis.axisMinimum)
    }
    
    open override func renderAxisLabels(context: CGContext)
    {
        guard
            let chart = chart,
            axis.isEnabled,
            axis.isDrawLabelsEnabled
            else { return }

        let labelFont = axis.labelFont
        let labelTextColor = axis.labelTextColor
        
        let center = chart.centerOffsets
        let factor = chart.factor
        
        let labelLineHeight = axis.labelFont.lineHeight
        
        let from = axis.isDrawBottomYLabelEntryEnabled ? 0 : 1
        let to = axis.isDrawTopYLabelEntryEnabled ? axis.entryCount : (axis.entryCount - 1)
        
        for i in from..<to
        {
            let r = CGFloat(axis.entries[i] - axis.axisMinimum) * factor
            
            let p = center.moving(distance: r, atAngle: chart.rotationAngle)
            
            let label = axis.getFormattedLabel(i)
            
            context.drawText(label,
                             at: CGPoint(x: p.x + 10.0, y: p.y - labelLineHeight),
                             align: .left,
                             attributes: [.font: labelFont,
                                          .foregroundColor: labelTextColor])
        }
    }
    
    open override func renderLimitLines(context: CGContext)
    {
        guard
            let chart = chart,
            let data = chart.data
            else { return }
        
        var limitLines = axis.limitLines
        
        guard !limitLines.isEmpty else { return }

        context.saveGState()
        defer { context.restoreGState() }

        let sliceangle = chart.sliceAngle
        
        // calculate the factor that is needed for transforming the value to pixels
        let factor = chart.factor
        
        let center = chart.centerOffsets
        
        for l in limitLines where l.isEnabled
        {
            context.setStrokeColor(l.lineColor.cgColor)
            context.setLineWidth(l.lineWidth)
            if l.lineDashLengths != nil
            {
                context.setLineDash(phase: l.lineDashPhase, lengths: l.lineDashLengths!)
            }
            else
            {
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            let r = CGFloat(l.limit - chart.chartYMin) * factor
            
            context.beginPath()
            
            for i in 0 ..< (data.maxEntryCountSet?.entryCount ?? 0)
            {
                let p = center.moving(distance: r, atAngle: sliceangle * CGFloat(i) + chart.rotationAngle)
                
                if i == 0
                {
                    context.move(to: CGPoint(x: p.x, y: p.y))
                }
                else
                {
                    context.addLine(to: CGPoint(x: p.x, y: p.y))
                }
            }
            
            context.closePath()
            context.strokePath()
        }
    }
}
