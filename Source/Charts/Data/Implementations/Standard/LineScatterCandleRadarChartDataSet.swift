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


open class LineScatterCandleRadarChartDataSet: BarLineScatterCandleBubbleChartDataSet, LineScatterCandleRadarChartDataSetProtocol
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// Enables / disables the horizontal highlight-indicator. If disabled, the indicator is not drawn.
    open var drawHorizontalHighlightIndicatorEnabled = true
    
    /// Enables / disables the vertical highlight-indicator. If disabled, the indicator is not drawn.
    open var drawVerticalHighlightIndicatorEnabled = true

    /// Enables / disables the horizontal radar highlight-indicator. If disabled, the indicator is not drawn.
    open var drawHorizontalHighlightRadarIndicatorEnabled = true

    /// Enables / disables the vertical radar highlight-indicator. If disabled, the indicator is not drawn.
    open var drawVerticalHighlightRadarIndicatorEnabled = true
    
    /// `true` if horizontal highlight indicator lines are enabled (drawn)
    open var isHorizontalHighlightIndicatorEnabled: Bool { return drawHorizontalHighlightIndicatorEnabled }
    
    /// `true` if vertical highlight indicator lines are enabled (drawn)
    open var isVerticalHighlightIndicatorEnabled: Bool { return drawVerticalHighlightIndicatorEnabled }

    /// `true` if horizontal highlight radar indicator lines are enabled (drawn)
    open var isHorizontalHighlightRadarIndicatorEnabled: Bool { return drawHorizontalHighlightRadarIndicatorEnabled }

    /// `true` if vertical highlight radar indicator lines are enabled (drawn)
    open var isVerticalHighlightRadarIndicatorEnabled: Bool { return drawVerticalHighlightRadarIndicatorEnabled }
    
    /// Enables / disables both vertical and horizontal highlight-indicators.
    /// :param: enabled
    open func setDrawHighlightIndicators(_ enabled: Bool)
    {
        drawHorizontalHighlightIndicatorEnabled = enabled
        drawVerticalHighlightIndicatorEnabled = enabled
    }

    /// Enables / disables both vertical and horizontal radar highlight-indicators.
    /// :param: enabled
    open func setDrawHighlightRadarIndicators(_ enabled: Bool) {
        drawHorizontalHighlightIndicatorEnabled = enabled
        drawVerticalHighlightIndicatorEnabled = enabled
        drawHorizontalHighlightRadarIndicatorEnabled = enabled
        drawVerticalHighlightRadarIndicatorEnabled = enabled
    }
    
    // MARK: NSCopying
    
    open override func copy(with zone: NSZone? = nil) -> Any
    {
        let copy = super.copy(with: zone) as! LineScatterCandleRadarChartDataSet
        copy.drawHorizontalHighlightIndicatorEnabled = drawHorizontalHighlightIndicatorEnabled
        copy.drawVerticalHighlightIndicatorEnabled = drawVerticalHighlightIndicatorEnabled
        copy.drawHorizontalHighlightRadarIndicatorEnabled = drawHorizontalHighlightRadarIndicatorEnabled
        copy.drawVerticalHighlightRadarIndicatorEnabled = drawVerticalHighlightRadarIndicatorEnabled
        return copy
    }
    
}
