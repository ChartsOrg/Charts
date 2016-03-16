//
//  ChartDataProvider.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 27/2/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

@objc
public protocol ChartDataProvider
{
    /// - returns: the minimum x-value of the chart, regardless of zoom or translation.
    var chartXMin: Double { get }
    
    /// - returns: the maximum x-value of the chart, regardless of zoom or translation.
    var chartXMax: Double { get }
    
    /// - returns: the minimum y-value of the chart, regardless of zoom or translation.
    var chartYMin: Double { get }
    
    /// - returns: the maximum y-value of the chart, regardless of zoom or translation.
    var chartYMax: Double { get }
    
    var xValCount: Int { get }
    
    var centerOffsets: CGPoint { get }
    
    var data: ChartData? { get }
}