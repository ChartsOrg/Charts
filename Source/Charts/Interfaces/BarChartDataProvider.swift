//
//  BarChartDataProvider.swift
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

@objc
public protocol BarChartDataProvider: BarLineScatterCandleBubbleChartDataProvider
{
    var barData: BarChartData? { get }
    
    var isDrawBarShadowEnabled: Bool { get }
    var isDrawValueAboveBarEnabled: Bool { get }
    /// if set to true and isDrawValueAboveBarEnabled is false, values those do not fit into the value bar are drawn above their bars, instead of below their top
    var isDrawValueSideFlexible: Bool { get }
    /// distance from top (bottom in negative) for values drawn outside/inside the bar
    var valuesOffset: CGFloat { get }
    var isHighlightFullBarEnabled: Bool { get }
}