//
//  AggregatedBarChartDataProvider.swift
//  Charts
//
//  Created by Maxim Komlev on 5/5/17.
//
//

import Foundation
import CoreGraphics

/// Specifies if the bars will be aggregated into one bar on scaling
/// use barWidth to specify limit of width for bar
@objc
public protocol AggregatedBarChartDataProvider: BarChartDataProvider
{
    var groupMargin: CGFloat { get }
    var groupWidth: CGFloat { get }
}
