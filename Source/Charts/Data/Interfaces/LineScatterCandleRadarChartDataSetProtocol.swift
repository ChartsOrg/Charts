//
//  LineScatterCandleRadarChartDataSetProtocol.swift
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
public protocol LineScatterCandleRadarChartDataSetProtocol: BarLineScatterCandleBubbleChartDataSetProtocol
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// Enables / disables the horizontal highlight-indicator. If disabled, the indicator is not drawn.
    var drawHorizontalHighlightIndicatorEnabled: Bool { get set }
    
    /// Enables / disables the vertical highlight-indicator. If disabled, the indicator is not drawn.
    var drawVerticalHighlightIndicatorEnabled: Bool { get set }

    /// Enables / disables the horizontal radar highlight-indicator. If disabled, the indicator is not drawn.
    var drawHorizontalHighlightRadarIndicatorEnabled: Bool { get set }

    /// Enables / disables the vertical radar highlight-indicator. If disabled, the indicator is not drawn.
    var drawVerticalHighlightRadarIndicatorEnabled: Bool { get set }
    
    /// `true` if horizontal highlight indicator lines are enabled (drawn)
    var isHorizontalHighlightIndicatorEnabled: Bool { get }
    
    /// `true` if vertical highlight indicator lines are enabled (drawn)
    var isVerticalHighlightIndicatorEnabled: Bool { get }

    /// `true` if horizontal highlight radar indicator lines are enabled (drawn)
    var isHorizontalHighlightRadarIndicatorEnabled: Bool { get }

    /// `true` if vertical highlight radar indicator lines are enabled (drawn)
    var isVerticalHighlightRadarIndicatorEnabled: Bool { get }
    
    /// Enables / disables both vertical and horizontal highlight-indicators.
    /// :param: enabled
    func setDrawHighlightIndicators(_ enabled: Bool)

    /// Enables / disables both vertical and horizontal radar highlight-indicators.
    /// :param: enabled
    func setDrawHighlightRadarIndicators(_ enabled: Bool)
}
