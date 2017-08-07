//
//  LineScatterCandleRadarChartDataSet.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation


open class LineScatterCandleRadarChartDataSet: BarLineScatterCandleBubbleChartDataSet, ILineScatterCandleRadarChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// Enables / disables the horizontal highlight-indicator. If disabled, the indicator is not drawn.
    /// - returns: `true` if horizontal highlight indicator lines are enabled (drawn)
    public var isHorizontalHighlightIndicatorEnabled: Bool {
        get { return _isHorizontalHighlightIndicatorEnabled }
        @objc(setHorizontalHighlightIndicatorEnabled:) set { _isHorizontalHighlightIndicatorEnabled = newValue }
    }
    private var _isHorizontalHighlightIndicatorEnabled = true

    /// Enables / disables the vertical highlight-indicator. If disabled, the indicator is not drawn.
    /// - returns: `true` if vertical highlight indicator lines are enabled (drawn)
    public var isVerticalHighlightIndicatorEnabled: Bool {
        get { return _isVerticalHighlightIndicatorEnabled }
        @objc(setVerticalHighlightIndicatorEnabled:) set { _isVerticalHighlightIndicatorEnabled = newValue }
    }
    private var _isVerticalHighlightIndicatorEnabled = true

    /// Enables / disables both vertical and horizontal highlight-indicators.
    /// :param: enabled
    open func setDrawHighlightIndicators(_ enabled: Bool)
    {
        isHorizontalHighlightIndicatorEnabled = enabled
        isVerticalHighlightIndicatorEnabled = enabled
    }
    
    // MARK: NSCopying
    
    open override func copyWithZone(_ zone: NSZone?) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! LineScatterCandleRadarChartDataSet
        copy.isHorizontalHighlightIndicatorEnabled = isHorizontalHighlightIndicatorEnabled
        copy.isVerticalHighlightIndicatorEnabled = isVerticalHighlightIndicatorEnabled
        return copy
    }
    
}
