//
//  ILineScatterCandleRadarChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 26/2/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation

@objc
public protocol ILineScatterCandleRadarChartDataSet: IBarLineScatterCandleBubbleChartDataSet
{
    // MARK: - Data functions and accessors
    
    // MARK: - Styling functions and accessors
    
    /// Enables / disables the horizontal highlight-indicator. If disabled, the indicator is not drawn.
    /// 启用 / 禁用 水平指示器。如果禁用，指示器不会绘制。
    var drawHorizontalHighlightIndicatorEnabled: Bool { get set }
    
    /// Enables / disables the vertical highlight-indicator. If disabled, the indicator is not drawn.
    /// 启用 / 禁用 垂直指示器。如果禁用，指示器不会绘制。
    var drawVerticalHighlightIndicatorEnabled: Bool { get set }
    
    /// - returns: true if horizontal highlight indicator lines are enabled (drawn)
    /// - returns: true 如果启用水平指示器 （绘制）
    var isHorizontalHighlightIndicatorEnabled: Bool { get }
    
    /// - returns: true if vertical highlight indicator lines are enabled (drawn)
    /// - returns: true 如果启用垂直指示器 （绘制）
    var isVerticalHighlightIndicatorEnabled: Bool { get }
    
    /// Enables / disables both vertical and horizontal highlight-indicators.
    /// 启用 / 禁用 垂直和水平指示器
    /// :param: enabled
    func setDrawHighlightIndicators(enabled: Bool)
}
