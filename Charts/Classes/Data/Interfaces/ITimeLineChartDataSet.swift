//
//  ITimeLineChartDataSet.swift
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
import CoreGraphics

@objc
public protocol ITimeLineChartDataSet: ILineChartDataSet
{
    // MARK: - Data functions and accessors

    /// - returns: the minimum xNumericVal this DataSet holds
    var xNumericValMin: Double { get }
    
    /// - returns: the maximum y-value this DataSet holds
    var xNumericValMax: Double { get }
    
    /// - returns: the xNumericValue of the Entry object at the given xIndex. Returns NaN if no xNumericValue is at the given x-index.
    func xNumericValForXIndex(x: Int) -> Double
    
    /// TODO: The formatter used to custom format numeric values on the x axis.  Should this go somewhere else like the axis class?
}
