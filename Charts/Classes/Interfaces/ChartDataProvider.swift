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
    var chartXMin: Double { get }
    var chartXMax: Double { get }
    var chartYMin: Double { get }
    var chartYMax: Double { get }
    var xValCount: Int { get }
    var centerOffsets: CGPoint { get }
    var data: ChartData? { get }
}