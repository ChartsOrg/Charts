//
//  BubbleChartDataSet.swift
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


open class BubbleChartDataSet: BarLineScatterCandleBubbleChartDataSet, IBubbleChartDataSet
{
    // MARK: - Data functions and accessors
    
    internal var _xMax = Double(0.0)
    internal var _xMin = Double(0.0)
    internal var _maxSize = CGFloat(0.0)
    
    open var xMin: Double { return _xMin }
    open var xMax: Double { return _xMax }
    open var maxSize: CGFloat { return _maxSize }
    open var normalizeSizeEnabled: Bool = true
    
    open override func calcMinMax(start: Int, end: Int)
    {
        let yValCount = self.entryCount
        
        if yValCount == 0
        {
            return
        }
        
        let entries = yVals as! [BubbleChartDataEntry]
    
        // need chart width to guess this properly
        
        var endValue : Int
        
        if end == 0 || end >= yValCount
        {
            endValue = yValCount - 1
        }
        else
        {
            endValue = end
        }
        
        _lastStart = start
        _lastEnd = end
        
        _yMin = yMin(entries[start])
        _yMax = yMax(entries[start])
        
        for i in stride(from: start, through: endValue, by: 1)
        {
            let entry = entries[i]

            let ymin = yMin(entry)
            let ymax = yMax(entry)
            
            if (ymin < _yMin)
            {
                _yMin = ymin
            }
            
            if (ymax > _yMax)
            {
                _yMax = ymax
            }
            
            let xmin = xMin(entry)
            let xmax = xMax(entry)
            
            if (xmin < _xMin)
            {
                _xMin = xmin
            }
            
            if (xmax > _xMax)
            {
                _xMax = xmax
            }

            let size = largestSize(entry)
            
            if (size > _maxSize)
            {
                _maxSize = size
            }
        }
    }
    
    private func yMin(_ entry: BubbleChartDataEntry) -> Double
    {
        return entry.value
    }
    
    private func yMax(_ entry: BubbleChartDataEntry) -> Double
    {
        return entry.value
    }
    
    private func xMin(_ entry: BubbleChartDataEntry) -> Double
    {
        return Double(entry.xIndex)
    }
    
    private func xMax(_ entry: BubbleChartDataEntry) -> Double
    {
        return Double(entry.xIndex)
    }
    
    private func largestSize(_ entry: BubbleChartDataEntry) -> CGFloat
    {
        return entry.size
    }
    
    // MARK: - Styling functions and accessors
    
    /// Sets/gets the width of the circle that surrounds the bubble when highlighted
    open var highlightCircleWidth: CGFloat = 2.5
    
    // MARK: - NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> Any
    {
        let copy = super.copyWithZone(zone) as! BubbleChartDataSet
        copy._xMin = _xMin
        copy._xMax = _xMax
        copy._maxSize = _maxSize
        copy.highlightCircleWidth = highlightCircleWidth
        return copy
    }
}
