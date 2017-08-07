//
//  ILineScatterCandleRadarChartDataSet.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation

@objc
public protocol ILineScatterCandleRadarChartDataSet: IBarLineScatterCandleBubbleChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// Enables / disables the horizontal highlight-indicator. If disabled, the indicator is not drawn.
    /// - returns: `true` if horizontal highlight indicator lines are enabled (drawn)
    var isHorizontalHighlightIndicatorEnabled: Bool { get @objc(setHorizontalHighlightIndicatorEnabled:)set }

    /// Enables / disables the vertical highlight-indicator. If disabled, the indicator is not drawn.
    /// - returns: `true` if vertical highlight indicator lines are enabled (drawn)
    var isVerticalHighlightIndicatorEnabled: Bool { get @objc(setVerticalHighlightIndicatorEnabled:)set }
    
    /// Enables / disables both vertical and horizontal highlight-indicators.
    /// :param: enabled
    func setDrawHighlightIndicators(_ enabled: Bool)
}
