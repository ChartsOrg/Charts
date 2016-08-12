//
//  ChartDataProvider.swift
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
public protocol ChartDataProvider
{
    /// - returns: The minimum x-value of the chart, regardless of zoom or translation.
    var chartXMin: Double { get }
    
    /// - returns: The maximum x-value of the chart, regardless of zoom or translation.
    var chartXMax: Double { get }
    
    /// - returns: The minimum y-value of the chart, regardless of zoom or translation.
    var chartYMin: Double { get }
    
    /// - returns: The maximum y-value of the chart, regardless of zoom or translation.
    var chartYMax: Double { get }
    
    var maxHighlightDistance: CGFloat { get }
    
    var xRange: Double { get }
    
    var centerOffsets: CGPoint { get }
    
    var data: ChartData? { get }
    
    var maxVisibleCount: Int { get }
}