//
//  ChartFillFormatter.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 6/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import CoreGraphics

/// Protocol for providing a custom logic to where the filling line of a DataSet should end. If `setFillEnabled(...)` is set to true.
@objc
public protocol ChartFillFormatter
{
    /// - returns: the vertical (y-axis) position where the filled-line of the DataSet should end.
    func getFillLinePosition(dataSet dataSet: LineChartDataSet, data: LineChartData, chartMaxY: Double, chartMinY: Double) -> CGFloat
}
