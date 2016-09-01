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


public class BubbleChartDataSet: BarLineScatterCandleBubbleChartDataSet, IBubbleChartDataSet
{
    // MARK: - Data functions and accessors
    
    internal var _maxSize = CGFloat(0.0)
    
    public var maxSize: CGFloat { return _maxSize }
    public var normalizeSizeEnabled: Bool = true
    public var isNormalizeSizeEnabled: Bool { return normalizeSizeEnabled }
    
    public override func calcMinMax(entry e: ChartDataEntry)
    {
        guard let e = e as? BubbleChartDataEntry
            else { return }
        
        super.calcMinMax(entry: e)
        
        let size = e.size
        
        if size > _maxSize
        {
            _maxSize = size
        }
    }
    
    // MARK: - Styling functions and accessors
    
    /// Sets/gets the width of the circle that surrounds the bubble when highlighted
    public var highlightCircleWidth: CGFloat = 2.5
    
    // MARK: - NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! BubbleChartDataSet
        copy._xMin = _xMin
        copy._xMax = _xMax
        copy._maxSize = _maxSize
        copy.highlightCircleWidth = highlightCircleWidth
        return copy
    }
}
