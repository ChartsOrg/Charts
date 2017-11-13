//
//  AxisRendererBase.swift
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

@objc(ChartAxisRendererBase)
open class AxisRendererBase: Renderer
{
    /// base axis this axis renderer works with
    @objc open var axis: AxisBase?
    
    /// transformer to transform values to screen pixels and return
    @objc open var transformer: Transformer?
    
    public override init()
    {
        super.init()
    }
    
    @objc public init(viewPortHandler: ViewPortHandler?, transformer: Transformer?, axis: AxisBase?)
    {
        super.init(viewPortHandler: viewPortHandler)
        
        self.transformer = transformer
        self.axis = axis
    }
    
    /// Draws the axis labels on the specified context
    @objc open func renderAxisLabels(context: CGContext)
    {
        fatalError("renderAxisLabels() cannot be called on AxisRendererBase")
    }
    
    /// Draws the grid lines belonging to the axis.
    @objc open func renderGridLines(context: CGContext)
    {
        fatalError("renderGridLines() cannot be called on AxisRendererBase")
    }
    
    /// Draws the line that goes alongside the axis.
    @objc open func renderAxisLine(context: CGContext)
    {
        fatalError("renderAxisLine() cannot be called on AxisRendererBase")
    }
    
    /// Draws the LimitLines associated with this axis to the screen.
    @objc open func renderLimitLines(context: CGContext)
    {
        fatalError("renderLimitLines() cannot be called on AxisRendererBase")
    }
    
    /// Computes the axis values.
    /// - parameter min: the minimum value in the data object for this axis
    /// - parameter max: the maximum value in the data object for this axis
    @objc open func computeAxis(min: Double, max: Double, inverted: Bool)
    {
        guard
            let transformer = self.transformer,
            let viewPortHandler = viewPortHandler,
            viewPortHandler.contentWidth > 10.0,
            !viewPortHandler.isFullyZoomedOutY
            else { return computeAxisValues(min: min, max: max) }

        // calculate the starting and entry point of the y-labels (depending on zoom / contentrect bounds)
        let p1 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentTop))
        let p2 = transformer.valueForTouchPoint(CGPoint(x: viewPortHandler.contentLeft, y: viewPortHandler.contentBottom))

        let min = inverted ? Double(p1.y) : Double(p2.y)
        let max = inverted ? Double(p2.y) : Double(p1.y)

        computeAxisValues(min: min, max: max)
    }
    
    /// Sets up the axis values. Computes the desired number of labels between the two given extremes.
    @objc open func computeAxisValues(min: Double, max: Double)
    {
        guard let axis = self.axis else { return }
        
        let yMin = min
        let yMax = max
        
        let labelCount = axis.labelCount
        let range = abs(yMax - yMin)

        guard
            labelCount > 0,
            range > 0,
            !range.isInfinite
            else {
                axis.entries = []
                axis.centeredEntries = []
                return
        }

        // Find out how much spacing (in y value space) between axis values
        let rawInterval = range / Double(labelCount)
        var interval = ChartUtils.roundToNextSignificant(number: Double(rawInterval))
        
        // If granularity is enabled, then do not allow the interval to go below specified granularity.
        // This is used to avoid repeated values when rounding values for display.
        if axis.granularityEnabled
        {
            interval = Swift.max(interval, axis.granularity)
        }
        
        // Normalize interval
        let intervalMagnitude = ChartUtils.roundToNextSignificant(number: pow(10.0, Double(Int(log10(interval)))))
        let intervalSigDigit = Int(interval / intervalMagnitude)
        if intervalSigDigit > 5
        {
            // Use one order of magnitude higher, to avoid intervals like 0.9 or 90
            interval = floor(10.0 * Double(intervalMagnitude))
        }
        
        var n = axis.centerAxisLabelsEnabled ? 1 : 0
        
        // force label count
        if axis.isForceLabelsEnabled
        {
            interval = range / Double(labelCount - 1)
            
            // Ensure stops contains at least n elements.
            let yMax = yMin + interval * Double(labelCount)
            axis.entries = stride(from: yMin, to: yMax, by: interval).map { $0 }

            n = labelCount
        }
        else
        {
            // no forced count
        
            var first = interval == 0.0 ? 0.0 : ceil(yMin / interval) * interval
            
            if axis.centerAxisLabelsEnabled
            {
                first -= interval
            }
            
            let last = interval == 0.0 ? 0.0 : ChartUtils.nextUp(floor(yMax / interval) * interval)
            
            if interval != 0.0 && last != first
            {
                stride(from: first, through: last, by: interval).forEach { _ in
                    n += 1
                }
            }
            
            // Ensure stops contains at least n elements.
            axis.entries.removeAll(keepingCapacity: true)
            axis.entries.reserveCapacity(labelCount)
            
            var f = first
            (0..<n).forEach { _ in
                if f == 0.0
                {
                    // Fix for IEEE negative zero case (Where value == -0.0, and 0.0 == -0.0)
                    f = 0.0
                }
                
                axis.entries.append(Double(f))
                
                f += interval
            }
        }
        
        // set decimals
        axis.decimals = interval < 1 ? Int(ceil(-log10(interval))) : 0

        if axis.centerAxisLabelsEnabled
        {
            let offset = interval / 2.0
            axis.centeredEntries = (0 ..< n).map { axis.entries[$0] + offset }
        }
    }
}
